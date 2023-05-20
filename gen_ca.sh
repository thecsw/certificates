#!/bin/sh

ROOT_CERT_TTL=3650 # in days

# create the root ca key
# some systems, like linux redis expect strong rsa and not ec
openssl genrsa -out ca.key 4096

# convert the private key to PKCS#1
openssl pkcs8 -topk8 -inform PEM -outform PEM -in ca.key -nocrypt -out ca.pem

# create a cert sign request
openssl req -new -nodes -key ca.key -config ./configs/ca_csr.txt -nameopt utf8 -utf8 -out ca.csr

# self-sign the cert
openssl req -x509 -nodes -in ca.csr -days ${ROOT_CERT_TTL} -key ca.key -config ./configs/ca_csr.txt -extensions req_ext -nameopt utf8 -utf8 -out ca.crt

# generate a der as well
openssl x509 -outform der -in ca.crt -out ca.der

# move all of them to ca
mkdir ca
mv ca.* ca
