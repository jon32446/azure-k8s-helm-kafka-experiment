import os
import time
from json import dumps, loads

from azure.common import AzureMissingResourceHttpError
from azure.cosmosdb.table.models import Entity
from azure.cosmosdb.table.tablebatch import TableBatch
from azure.cosmosdb.table.tableservice import TableService
from kafka import KafkaConsumer, KafkaProducer

# Connect to the Azure Table Storage
secret_path = "/etc/ppap-secret/connection_string"
connection_string = open(secret_path).read()

table_service = TableService(connection_string=connection_string)

# Connect to the payment stream in Kafka
consumer = KafkaConsumer("payment",
                         bootstrap_servers=["kafka.kafka.svc.cluster.local:9092"],
                         auto_offset_reset="earliest",
                         enable_auto_commit=True,
                         group_id="payment-stream-processor",
                         value_deserializer=lambda x: loads(x.decode("utf-8")))

# Process the stream of payment messages, updating the accounts
for message in consumer:
    # TODO: for testing purposes (remove this when account creation is added; replace with check)
    for account in [message.value["from_account"], message.value["to_account"]]:
        try:
            table_service.get_entity("account", "account", account)
        except AzureMissingResourceHttpError:
            table_service.insert_entity(
                "account", {"PartitionKey": "account",
                            "RowKey": account,
                            "balance": 10000.00})

    # Get the current balance of the two accounts
    from_account = table_service.get_entity("account", "account", message.value["from_account"])
    to_account = table_service.get_entity("account", "account", message.value["to_account"])

    # Process the payment on the balances
    from_account.balance -= float(message.value["amount"])
    to_account.balance += float(message.value["amount"])

    # Update the accounts
    with table_service.batch("account") as batch:
        batch.update_entity(from_account)
        batch.update_entity(to_account)

    print(
        f'Processed payment from {message.value["from_account"]} to ' +
        f'{message.value["to_account"]} for amount {message.value["amount"]}')
