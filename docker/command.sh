#!/bin/bash

# Generate CAcert
openssl genrsa -out rootCA.key 2048
openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 3650 -out rootCA.pem -subj "/C=VN/ST=VN/L=HN/O=FPT/CN=*apps.fpt.com
E=hungtn29@fpt.com"

# Create an openssl.cnf file. Replacing DNS.1 and IP.1 with the hostname and IP of the server:
cat <<EOF > openssl.cnf
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = reg.example.com
IP.1 = 12.345.678.9
EOF

# Create key and certificates.
openssl genrsa -out ssl.key 2048
openssl req -new -key ssl.key -out ssl.csr -subj "/CN=*apps.fpt.com" -config openssl.cnf
openssl x509 -req -in ssl.csr -CA rootCA.pem -CAkey rootCA.key -CAcreateserial -out ssl.cert -days 3560 -extensions v3_req -extfile openssl.cnf

# Copy cert to configure folder
scp ssl.* root@reg.example.com:/mnt/web/config/

# Copy cert and trust cert to hosts
cp rootCA* /etc/pki/ca-trust/source/anchors/

ls /etc/pki/ca-trust/source/anchors/
sudo update-ca-certificates

trust list