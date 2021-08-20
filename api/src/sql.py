

class SQLClient(Postgres):

  def __init__(self):
    self.__hostname = hostname
    self.__port = port
    self.__user = user
    self.__password = password
    self.__database = database
    super().__init__(hostname, self.__port, self.__user, self.__password)

  
  def connect(self):
    pass


class Postgres():
  
  def __init__(hostname="localhost", port=None, user="postgres", password=None, database):
    self.__hostname = hostname
    self.__port = port && is_instance(port, int) ? port : 4567
    self.__user = user
    self.__password = password
    self.__database = database
    
  def connect(self):
    pass
    
