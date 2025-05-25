from flask import Flask, request, jsonify
from PIL import Image
import numpy as np
import io
import tensorflow as tf

from tensorflow.keras.models import load_model
from tensorflow.keras.preprocessing import image

import logging
import os
from keras.preprocessing import image
from Crypto.Cipher import AES
import base64
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.backends import default_backend
from Crypto.Util.Padding import pad, unpad

logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

app = Flask(__name__)
name="model.keras"
#  modelo pré-treinado
model = load_model(name)


@app.route('/classify', methods=['GET', 'POST'])
def classify_image():
    if 'image' not in request.files:
        return jsonify({'error': 'No image file provided'}), 400
    
    file = request.files['image']

    
    image = Image.open(io.BytesIO(file.read()))
    # Pré-processamento da imagem
    image = image.resize((384, 384))#ConvNeXtLarge input shape
    image_array = np.array(image)
    image_array = np.expand_dims(image_array, axis=0)
    
    # previsão
    predictions = model.predict(image_array)
    
    class_names = ['akiec', 'bcc', 'bkl', 'df', 'mel', 'nv', 'vasc']  
    
    results = [
        {'label': class_names[i], 'probability': float(prob)}
        for i, prob in enumerate(predictions[0])
    ]
    
    return jsonify({'predictions': results})


# Same Key in Flutter
AES_KEY = b'secretpasswordxxxxxxxxxxxxxxxxxx'  # must be equal to keyString in Flutter
iv = b'Sixteen byte IV.'
VALID_TOKEN = "tokenxxxxx"  # Token

@app.route('/process_image', methods=['GET', 'POST'])
def process_image():
    try:

        token = request.headers.get('Authorization')
        if not token or token != VALID_TOKEN:
            response = jsonify({'error': 'Invalid token'}).get_data(as_text=True)
            response_cipher = AES.new(AES_KEY, AES.MODE_CBC)
            response_iv = response_cipher.iv
            encrypted_response = base64.b64encode(response_cipher.encrypt(pad(response.encode('utf-8'), AES.block_size)))

            return jsonify({
                'data': encrypted_response.decode('utf-8'),
                'iv': base64.b64encode(response_iv).decode('utf-8')
            })


        logger.debug("Image received..")
        data = request.json['data']
        encrypted_data = base64.b64decode(data)
        iv = base64.b64decode(request.json['iv'])
        # Decrypt the data
        cipher = AES.new(AES_KEY, AES.MODE_CBC, iv)
        decrypted_data = unpad(cipher.decrypt(encrypted_data), AES.block_size).decode('utf-8')

        # Handle the image file
        file = io.BytesIO(base64.b64decode(decrypted_data))
        image = Image.open(file)

        logger.debug("Image decrypted")
        image = image.resize((384, 384)) #Same Input Shape
        image_array = np.array(image)
        image_array = np.expand_dims(image_array, axis=0)

        predictions = model.predict(image_array)

        class_names = ['akiec', 'bcc', 'bkl', 'df', 'mel', 'nv', 'vasc']

        results = [
            {'label': class_names[i], 'probability': float(prob)}
            for i, prob in enumerate(predictions[0])
        ]

        response = jsonify({'predictions': results}).get_data(as_text=True)
        response_cipher = AES.new(AES_KEY, AES.MODE_CBC)
        response_iv = response_cipher.iv
        encrypted_response = base64.b64encode(response_cipher.encrypt(pad(response.encode('utf-8'), AES.block_size)))

        return jsonify({
            'data': encrypted_response.decode('utf-8'),
            'iv': base64.b64encode(response_iv).decode('utf-8')
        })


    except Exception as e:
        logger.debug(str(e))

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, ssl_context=('./server.crt', './server.key'))
