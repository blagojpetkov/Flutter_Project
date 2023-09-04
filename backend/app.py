from flask import Flask, request, jsonify
import tensorflow as tf
from PIL import Image
import numpy as np


app = Flask(__name__)

model = tf.keras.applications.ResNet50(weights="imagenet")


@app.route('/classify', methods=['POST'])
def classify_image():
    if 'image' not in request.files:
        return jsonify({'error': 'No image provided'}), 400

    image_file = request.files.get('image', '')
    image = Image.open(image_file)

    image = image.resize((224, 224))
    image_array = tf.keras.preprocessing.image.img_to_array(image)
    image_array = tf.expand_dims(image_array, 0)

    image_array = tf.keras.applications.resnet50.preprocess_input(image_array)


    predictions = model.predict(image_array)
    decoded_predictions = tf.keras.applications.resnet50.decode_predictions(predictions)


    top_prediction = decoded_predictions[0][0]
    label = top_prediction[1]
    confidence = top_prediction[2]

    return jsonify({
        'label': label,
        'confidence': float(confidence)
    })

@app.route('/')
def hello_world():  # put application's code here
    return 'Hello World!'


if __name__ == '__main__':
    app.run(debug=True)
