source .env

rm kafka.properties
printf "      bootstrap.servers=$BROKER_URL:$BROKER_PORT\n" >> kafka.properties
printf "      security.protocol=SASL_SSL\n" >> kafka.properties
printf "      sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule   required username='$API_KEY'   password='$API_SECRET';\n" >> kafka.properties
printf "      ssl.endpoint.identification.algorithm=https\n" >> kafka.properties
printf "      sasl.mechanism=PLAIN\n" >> kafka.properties

rm creds-client-kafka-sasl-user.txt
printf "username=$API_KEY\n" >> creds-client-kafka-sasl-user.txt
printf "password=$API_SECRET\n" >> creds-client-kafka-sasl-user.txt

kubectl create secret tls ca-pair-sslcerts --cert=ca.pem --key=ca-key.pem
kubectl create secret generic cloud-plain --from-file=plain.txt=creds-client-kafka-sasl-user.txt
kubectl create secret generic control-center-user --from-file=basic.txt=creds-control-center-users.txt
kubectl create secret generic kafka-client-config-secure --from-file=kafka.properties -n confluent

helm upgrade --set cloudKafkaURL=$BROKER_URL --set cloudKafkaPort=$BROKER_PORT \
  kafkaconnect ./charts/kafka-connect-standalone --install
