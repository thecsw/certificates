#!/bin/sh

if [ "$#" -lt 1 ]
then
    echo "need either client or server"
    exit 1
fi
if [ "$1" != "client" ] && [ "$1" != "server" ]; then
    echo "invalid argument: $1"
    exit 1
fi

name=$1

# create the root key
openssl ecparam -out ${name}.key -name prime256v1 -param_enc named_curve -genkey

# convert the private key to PKCS#1
openssl pkcs8 -topk8 -inform PEM -outform PEM -in ${name}.key -nocrypt -out ${name}.pem

# create a cert sign request
openssl req -new -nodes -key ${name}.key -config ./configs/${name}.txt -out ${name}.csr -extensions v3_req

# sign the cert with our ca
openssl x509 -req -days 360 -in ${name}.csr -CA ./ca/ca.crt -CAkey ./ca/ca.key -CAcreateserial -extfile ./configs/${name}.txt -extensions v3_req -out ${name}.crt

# let's rename the default .srl into this cert
mv .srl ${name}.srl

# dump the new cert
openssl x509 -in ${name}.crt -text -noout

# verify it immediately
openssl verify -CAfile ./ca/ca.crt ./${name}.crt

# generate a der as well
openssl x509 -outform der -in ${name}.crt -out ${name}.der

# push it all into a new dir
mkdir ${name}
mv ${name}.* ${name}
