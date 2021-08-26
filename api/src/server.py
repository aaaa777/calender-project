from flask import *

app = Flask(__name__)
@app.route("/")
def authorization():
  return jsonify({"code": "200", "content":{"id": 123456, "type": "testdata"}})


if __name__ == "__main__":
  app.run(debug=True, host="0.0.0.0", port="80")