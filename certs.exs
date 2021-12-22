# Important: run this with the wrapper script, so that umask is set correctly.

Mix.install([{:x509, "~> 0.8.3"}, {:optimus, "~> 0.2"}])

defmodule Certs do
  def main(argv) do
    opts =
      Optimus.new!(
        name: "certs",
        allow_unknown_args: false,
        parse_double_dash: true,
        subcommands: [
          self_signed: [
            name: "self-signed",
            about: "Create a self-signed certificate",
            options: [
              subject: [
                long: "--subject",
                value_name: "SUBJECT",
                required: true,
                parser: :string
              ],
              out_cert: [
                long: "--out-cert",
                value_name: "OUT_CRT",
                required: true,
                parser: :string
              ],
              out_key: [
                long: "--out-key",
                value_name: "OUT_KEY",
                required: true,
                parser: :string
              ],
              template: [
                long: "--template",
                value_name: "TEMPLATE",
                required: true,
                parser: :string
              ]
            ]
          ],
          create_cert: [
            name: "create-cert",
            options: [
              subject: [
                long: "--subject",
                value_name: "SUBJECT",
                required: true,
                parser: :string
              ],
              issuer_cert: [
                long: "--issuer-cert",
                value_name: "ISSUER_CRT",
                required: true,
                parser: :string
              ],
              issuer_key: [
                long: "--issuer-key",
                value_name: "ISSUER_KEY",
                required: true,
                parser: :string
              ],
              out_cert: [
                long: "--out-cert",
                value_name: "OUT_CRT",
                required: true,
                parser: :string
              ],
              out_key: [
                long: "--out-key",
                value_name: "OUT_KEY",
                required: true,
                parser: :string
              ],
              template: [
                long: "--template",
                value_name: "TEMPLATE",
                required: true,
                parser: :string
              ]
            ]
          ]
        ]
      )

    case Optimus.parse!(opts, argv) do
      {[:self_signed],
       %Optimus.ParseResult{
         options: %{subject: subject, out_cert: out_cert, out_key: out_key, template: template}
       }} ->
        ca_key = X509.PrivateKey.new_ec(:secp256r1)

        ca_crt =
          X509.Certificate.self_signed(ca_key, subject, template: template(template, subject))

        File.write!(out_key, X509.PrivateKey.to_pem(ca_key), [:exclusive])
        File.chmod!(out_key, 0o400)

        File.write!(out_cert, X509.Certificate.to_pem(ca_crt), [:exclusive])
        File.chmod!(out_cert, 0o444)

      {[:create_cert],
       %Optimus.ParseResult{
         options: %{
           subject: subject,
           issuer_cert: issuer_cert,
           issuer_key: issuer_key,
           out_cert: out_cert,
           out_key: out_key,
           template: template
         }
       }} ->
        issuer_cert = File.read!(issuer_cert) |> X509.Certificate.from_pem!()
        issuer_key = File.read!(issuer_key) |> X509.PrivateKey.from_pem!()

        key = X509.PrivateKey.new_ec(:secp256r1)
        pub = X509.PublicKey.derive(key)

        crt =
          X509.Certificate.new(pub, subject, issuer_cert, issuer_key,
            template: template(template, subject)
          )

        File.write!(out_key, X509.PrivateKey.to_pem(key), [:exclusive])
        File.chmod!(out_key, 0o400)

        File.write!(out_cert, X509.Certificate.to_pem(crt), [:exclusive])
        File.chmod!(out_cert, 0o444)
    end
  end

  defp template("root-ca", _subject), do: :root_ca

  defp template("server", subject) do
    commonName =
      X509.RDNSequence.new(subject)
      |> X509.RDNSequence.get_attr(:commonName)

    import X509.Certificate.Extension

    %X509.Certificate.Template{
      # 1 year, plus a 30 days grace period
      validity: 365 + 30,
      hash: :sha256,
      extensions: [
        basic_constraints: basic_constraints(false),
        key_usage: key_usage([:digitalSignature, :keyEncipherment]),
        ext_key_usage: ext_key_usage([:serverAuth, :clientAuth]),
        subject_key_identifier: true,
        authority_key_identifier: true,
        subject_alt_name: subject_alt_name(commonName)
      ]
    }
  end
end

Certs.main(System.argv())

# vim: set ft=elixir
