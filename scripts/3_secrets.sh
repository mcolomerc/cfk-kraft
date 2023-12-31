#!/bin/sh

echo "Create Secrets..."
kubectl create secret tls ca-pair-sslcerts --cert=./certs/generated/cacerts.pem --key=./certs/generated/rootCAkey.pem -n confluent

kubectl create secret generic tls-kraftcontroller \
  --from-file=fullchain.pem=./certs/generated/kraftcontroller.pem \
  --from-file=cacerts.pem=./certs/generated/cacerts.pem \
  --from-file=privkey.pem=./certs/generated/kraftcontroller-key.pem \
  --namespace confluent

kubectl create secret generic tls-kafka-e \
  --from-file=fullchain.pem=./certs/generated/kafka-server.pem \
  --from-file=cacerts.pem=./certs/generated/cacerts.pem \
  --from-file=privkey.pem=./certs/generated/kafka-server-key.pem \
  --namespace confluent

kubectl create secret generic tls-controlcenter \
  --from-file=fullchain.pem=./certs/generated/controlcenter-server.pem \
  --from-file=cacerts.pem=./certs/generated/cacerts.pem \
  --from-file=privkey.pem=./certs/generated/controlcenter-server-key.pem \
  --namespace confluent

kubectl create secret generic tls-schemaregistry \
  --from-file=fullchain.pem=./certs/generated/schemaregistry-server.pem \
  --from-file=cacerts.pem=./certs/generated/cacerts.pem \
  --from-file=privkey.pem=./certs/generated/schemaregistry-server-key.pem \
  --namespace confluent

kubectl create secret generic tls-connect \
  --from-file=fullchain.pem=./certs/generated/connect-server.pem \
  --from-file=cacerts.pem=./certs/generated/cacerts.pem \
  --from-file=privkey.pem=./certs/generated/connect-server-key.pem \
  --namespace confluent
  
kubectl create secret generic tls-kafkarestproxy \
  --from-file=fullchain.pem=./certs/generated/kafkarestproxy-server.pem \
  --from-file=cacerts.pem=./certs/generated/cacerts.pem \
  --from-file=privkey.pem=./certs/generated/kafkarestproxy-server-key.pem \
  --namespace confluent

kubectl create secret generic tls-ksqldb \
  --from-file=fullchain.pem=./certs/generated/ksqldb-server.pem \
  --from-file=cacerts.pem=./certs/generated/cacerts.pem \
  --from-file=privkey.pem=./certs/generated/ksqldb-server-key.pem \
  --namespace confluent

# Credentials
kubectl create secret generic credential \
  --from-file=plain-users.json=./users/plain-users.json \
  --from-file=plain.txt=./users/plain.txt \
  --from-file=basic.txt=./users/basic.txt \
  --namespace confluent

# Internal client - Uses autogenerated certificates to connect to the cluster, mounting the secret
kubectl create secret generic kafka-client-config-secure  --from-file=./config/internal.properties -n confluent