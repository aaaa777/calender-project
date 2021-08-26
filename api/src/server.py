from flask import *
from sql import Postgres

app = Flask(__name__)
sql = Postgres(
  hostname="db",
  port=5432,
  user="postgres",
  password="p0579r35qlpw",
  database="calender"
)
sql.connect()


@app.route("/")
def authorization():
  return jsonify({"code": "200", "content":{"id": 123456, "type": "testdata"}})


@app.route("/create")
def update():
  return sql.create_account(123, 456, 'test@test.test', 'password')


@app.route("/get")
def select():
  return sql.get_account_info(85999720841233)

@app.route("/exec", methods=["GET", "POST"])
def execute():
    if request.method == "GET":
        return """
        <form action="/exec" method="POST">
        <input name="sql"></input>
        </form>"""
    else:
        return """
        実行結果: {}
        <form action="/exec" method="POST">
        <input name="sql"></input>
        </form>""".format(str(sql.execute(str(request.form["sql"]))))



if __name__ == "__main__":
  app.run(debug=True, host="0.0.0.0", port="80")