from flask import Flask
from flask_json import FlaskJSON, as_json
import datetime

# Create the Flask WSGI application
app = Flask(__name__)
# Add Flask-JSON extension to the app
FlaskJSON(app)


@app.route('/')
def get_root():
    return "Try /time\n"


@app.route('/time')
@as_json
def get_time():
    return {"now": datetime.datetime.now()}


if __name__ == '__main__':
    app.run()
