#============================================================================
# Create a Kafka cluster
#============================================================================

# Create a namespace for Kafka
kubectl create namespace kafka

# Add the bitnami repo to helm
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Use helm to install Kafka
helm install kafka bitnami/kafka \
    --namespace kafka

#============================================================================
# Optional checks
#============================================================================

# Don't run any further if the script is executed
return 0 2>/dev/null  # this will work if the script is sourced like . ./create-kafka.sh
exit 0                # otherwise, this will exit the shell if executed like ./create-kafka.sh

# Create a client pod that we can use to access Kafka from within the cluster
kubectl run kafka-client --restart='Never' --image docker.io/bitnami/kafka:2.6.0-debian-10-r0 --namespace default --command -- sleep infinity
kubectl exec -it kafka-client bash

# From within the pod, check that topics can be listed:
cd /opt/bitnami/kafka/bin
./kafka-topics.sh --list --bootstrap-server kafka.kafka.svc.cluster.local:9092

# Send a test message
./kafka-console-producer.sh --bootstrap-server kafka.kafka.svc.cluster.local:9092 --topic test
>this is a test message
>^C   # Ctrl+C

# Receive the test message
./kafka-console-consumer.sh --bootstrap-server kafka.kafka.svc.cluster.local:9092 --topic test --from-beginning
this is a test message
^C   # Ctrl+C
