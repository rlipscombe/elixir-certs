# elixir-certs

Certificate Authority, in Elixir, using 'x509' library.

## Example Usage

```bash
./certs self-signed \
    --out-cert ca.crt --out-key ca.key \
    --template root-ca \
    --subject '/CN=My Root CA'

./certs create-cert \
    --issuer-cert ca.crt --issuer-key ca.key \
    --out-cert server.crt --out-key server.key \
    --template server \
    --subject '/CN=server'
```

## Requirements

- Elixir >= 1.12.0. We use `Mix.install/2`.
- Erlang >= 24.0.2. Fixes https://github.com/erlang/otp/issues/4861.

## Dependencies

These are managed by `Mix.install/2` at the top of the script; I mention them here for interest:

- https://hex.pm/packages/x509
- https://hex.pm/packages/optimus
