from flask import Flask, request
from flask_json import FlaskJSON, as_json
from kafka import KafkaProducer
from json import loads, dumps
import datetime

# Create the Flask WSGI application
app = Flask(__name__)
# Add Flask-JSON extension to the app
FlaskJSON(app)


@app.route('/')
def get_root():
    return "Try /time or /payment\n"


@app.route('/time')
@as_json
def get_time():
    return {"now": datetime.datetime.now()}


@app.route('/payment', methods=['GET', 'POST'])
@as_json
def post_pay():
    if request.method == 'GET':
        return {"usage": "POST from_account, to_account, amount"}
    elif request.method == 'POST':
        # Get all the fields needed
        message = {key: request.form[key] for key in [
            "from_account", "to_account", "amount"
        ]}
        message["timestamp"] = datetime.datetime.utcnow()

        # Publish payment message to Kafka
        producer = KafkaProducer(
            bootstrap_servers=['kafka.kafka.svc.cluster.local:9092'],
            value_serializer=lambda x: dumps(x).encode('utf-8'))
        producer.send('payment', value=message)

        # Return
        return {"status": "payment successful"}


if __name__ == '__main__':
    app.run()
