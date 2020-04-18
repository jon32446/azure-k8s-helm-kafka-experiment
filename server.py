from flask import Flask
from flask_json import FlaskJSON, as_json
import datetime
app = Flask(__name__)
FlaskJSON(app)


@app.route('/')
def get_root():
    return "Try /time"


@app.route('/time')
@as_json
def get_time():
    return {"now": datetime.datetime.now()}


if __name__ == '__main__':
    app.run()
