import psycopg2


class Postgres(object):

  def __init__(self, hostname="localhost", port=5432, user="postgres", password=None, database="postgres"):
    self.__hostname = hostname
    self.__port = port
    self.__user = user
    self.__password = password
    self.__database = database
    super().__init__(hostname, self.__port, self.__user, self.__password)

  
  def connect(self):
    self.__connection = psycopg2.connect("host={} port={} dbname={} user={} password={}".format(self.__hostname, self.__port, self.__database, self.__user, self.__password))


  def create_account(self, name_id, name, mail, password):
    sql = "call CreateAccount('{}', '{}', '{}', '{}');"
    cur = self.__connection.cursor()
    cur.execute(sql.format(name_id, name, mail, password))
    res = cur.fetchone()
    
    for r in res:
      return r
    
  def get_account_info(self, account_id):
    sql = "call GetAccount({});"
    cur = self.__connection.cursor()
    cur.execute(sql.format(account_id))
    res = cur.fetchall()
    
    for r in res:
      return r

  def execute(self, sql):
    cur = self.__connection.cursor()
    cur.execute(sql)
    res = cur.fetchall()

    return res


class SQLClient(Postgres):

  def __init__(self, hostname, port, user, password, database):
    super().__init__(hostname, port, user, password, database)
    self.__hostname = super().__hostname
    self.__port = super().__port
    self.__user = super().__user
    self.__password = super().__password
    self.__database = super().__database
  
  def __init__(hostname="localhost", port=None, user="postgres", password=None, database):
    self.__hostname = hostname
    self.__port = port && is_instance(port, int) ? port : 4567
    self.__user = user
    self.__password = password
    self.__database = database
    
  def connect(self):
    pass
    
