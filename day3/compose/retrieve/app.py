# Server to return jsons from the folder by file name

from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/retrieve/<filename>', methods=['GET'])
def retrieve(filename):
    try:
        with open(f'./data/{filename}.json', 'r') as file:
            data = file.read()
            return jsonify(data)
    except FileNotFoundError:
        return jsonify({'error': 'File not found'}), 404

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
