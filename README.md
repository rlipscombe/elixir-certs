
```bash
./certs self-signed --out-cert ca.crt --out-key ca.key --template root-ca --rdn '/CN=My Root CA'
./certs create-cert --issuer-cert ca.crt --issuer-key ca.key --out-cert server.crt --out-key server.key --template server --rdn '/CN=server'
```
