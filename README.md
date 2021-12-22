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
