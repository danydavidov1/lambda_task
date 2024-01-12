import os
import awsgi
from flask import (
    Flask,
    jsonify,
)
URL_PATH = os.getenv('URL_PATH')

app = Flask(__name__)

@app.route(f'/{URL_PATH}')
def index():
    return jsonify(status=200, message='Hello Flask!')


def lambda_handler(event, context):
    return awsgi.response(app, event, context)



# import json

# def lambda_handler(event, context):
#     response_data = {
#         "statusCode": 200,
#         "body": json.dumps({'result': "test"}),
#     }
#     return response_data