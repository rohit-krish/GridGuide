from flask import Flask, request, jsonify
import base64
from PIL import Image
import io
from datetime import datetime

app = Flask(__name__)


@app.route('/endpoint', methods=['POST'])
def endpoint():
    global count
    string = request.form['string']
    bytes_data = base64.b64decode(string)
    image = Image.open(io.BytesIO(bytes_data))
    image.save(f'./uploaded-images/{datetime.now().time()}.jpg')
    return jsonify({})


if __name__ == '__main__':
    app.run(debug=False, port=5000, host='192.168.43.21')
