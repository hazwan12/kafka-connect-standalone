
## Install Kubectl
```
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl
```

## Install Helm
```
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm
```

## Install GCloud
```
sudo apt-get install apt-transport-https ca-certificates gnupg
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
sudo apt-get update && sudo apt-get install google-cloud-cli
```

## Setup GCloud
```
gcloud init --no-launch-browser
```

## Create Namespace and Set
```
kubectl create namespace confluent
kubectl config set-context --current --namespace confluent
```

## Install Confluent Operator
```
helm repo add confluentinc https://packages.confluent.io/helm
helm repo update
helm upgrade --install confluent-operator confluentinc/confluent-for-kubernetes
```

## Generate SSL
```
openssl genrsa -out ca-key.pem 2048
openssl req -new -key ca-key.pem -x509 \
  -days 1000 \
  -out ca.pem \
  -subj "/C=US/ST=CA/L=MountainView/O=Confluent/OU=Operator/CN=TestCA"
```

## Generate Secrets from SSL
```
kubectl create secret tls ca-pair-sslcerts --cert=ca.pem --key=ca-key.pem
kubectl create secret generic cloud-plain --from-file=plain.txt=creds-client-kafka-sasl-user.txt
kubectl create secret generic control-center-user --from-file=basic.txt=creds-control-center-users.txt
kubectl create secret generic kafka-client-config-secure --from-file=kafka.properties -n confluent
```

## Deploy Connect and Control Center
kubectl apply -f confluent-platform.yaml
