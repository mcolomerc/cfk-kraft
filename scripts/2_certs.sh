#!/bin/sh

openssl genrsa -out ./certs/generated/rootCAkey.pem 2048

openssl req -x509 -new -nodes -key ./certs/generated/rootCAkey.pem -days 3650 -out ./certs/generated/cacerts.pem -subj "/C=US/ST=CA/L=MVT/O=TestOrg/OU=Cloud/CN=TestCA"
 
openssl x509 -in ./certs/generated/cacerts.pem -text -noout 
 
cfssl gencert -ca=./certs/generated/cacerts.pem -ca-key=./certs/generated/rootCAkey.pem -config=./certs/ca-config.json -profile=server ./certs/kraftcontroller-server-domain.json | cfssljson -bare ./certs/generated/kraftcontroller
 
cfssl gencert -ca=./certs/generated/cacerts.pem \
-ca-key=./certs/generated/rootCAkey.pem \
-config=./certs/ca-config.json \
-profile=server ./certs/kafka-server-domain.json | cfssljson -bare ./certs/generated/kafka-server
 
cfssl gencert -ca=./certs/generated/cacerts.pem \
-ca-key=./certs/generated/rootCAkey.pem \
-config=./certs/ca-config.json \
-profile=server ./certs/controlcenter-server-domain.json | cfssljson -bare ./certs/generated/controlcenter-server
 
cfssl gencert -ca=./certs/generated/cacerts.pem \
-ca-key=./certs/generated/rootCAkey.pem \
-config=./certs/ca-config.json \
-profile=server ./certs/schemaregistry-server-domain.json | cfssljson -bare ./certs/generated/schemaregistry-server
 
cfssl gencert -ca=./certs/generated/cacerts.pem \
-ca-key=./certs/generated/rootCAkey.pem \
-config=./certs/ca-config.json \
-profile=server ./certs/connect-server-domain.json | cfssljson -bare ./certs/generated/connect-server
 
cfssl gencert -ca=./certs/generated/cacerts.pem \
-ca-key=./certs/generated/rootCAkey.pem \
-config=./certs/ca-config.json \
-profile=server ./certs/ksqldb-server-domain.json | cfssljson -bare ./certs/generated/ksqldb-server
 
cfssl gencert -ca=./certs/generated/cacerts.pem \
-ca-key=./certs/generated/rootCAkey.pem \
-config=./certs/ca-config.json \
-profile=server ./certs/kafkarestproxy-server-domain.json | cfssljson -bare ./certs/generated/kafkarestproxy-server 

cfssl gencert -ca=./certs/generated/cacerts.pem \
-ca-key=./certs/generated/rootCAkey.pem \
-config=./certs/ca-config.json \
-profile=server ./certs/user.json | cfssljson -bare ./certs/generated/user

openssl pkcs12 -export \
    -in ./certs/generated/user.pem \
    -inkey ./certs/generated/user-key.pem \
    -out ./certs/generated/user.p12

# Kafka Client -  
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
  <(echo "[server_ext]"; echo "extendedKeyUsage=serverAuth,clientAuth"; echo "subjectAltName=DNS:*.$DOMAIN") 

openssl pkcs12 -export -in ./certs/generated/fullchain.pem \
-inkey ./certs/generated/privkey-client.pem -out ./client/generated/client.keystore.p12 \
-name kafka-client -passout pass:mystorepassword
 
 
# Validation
echo "Validating the certificates"
openssl x509 -in ./certs/generated/kafka-server.pem -text -noout

openssl x509 -in ./certs/generated/controlcenter-server.pem -text -noout

openssl x509 -in ./certs/generated/schemaregistry-server.pem -text -noout

openssl x509 -in ./certs/generated/connect-server.pem -text -noout

openssl x509 -in ./certs/generated/ksqldb-server.pem -text -noout

openssl x509 -in ./certs/generated/kafkarestproxy-server.pem -text -noout
