#!/bin/sh  

# Kafka Client -  
openssl genrsa -out ./certs/generated/privkey-client.pem 2048

openssl req -new -key ./certs/generated/privkey-client.pem \
  -out ./certs/generated/client.csr \
  -subj "/C=US/ST=CA/L=MVT/O=TestOrg/OU=Cloud/CN=kafka-client"

openssl x509 -req \
  -in ./certs/generated/kafka-server.csr \
  -extensions server_ext \
  -CA ./certs/generated/cacerts.pem \
  -CAkey ./certs/generated/rootCAkey.pem \
  -CAcreateserial \
  -out ./certs/generated/fullchain.pem \
  -days 365 \
  -extfile \
  <(echo "[server_ext]"; echo "extendedKeyUsage=serverAuth,clientAuth"; echo "subjectAltName=DNS:*.130.211.58.17.nip.io")


openssl pkcs12 -export -in ./certs/generated/fullchain.pem \
-inkey ./certs/generated/privkey-client.pem -out ./client/generated/client.keystore.p12 \
-name kafka-client -passout pass:mystorepassword
