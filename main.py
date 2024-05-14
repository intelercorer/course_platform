import psycopg2
from psycopg2.extras import DictCursor
from GUI import Authorization, Registration, AuthorMain, Editing, Adding, EditCourse, StudentMain
class Database:
    def __init__(self, dbname, user, password, host='localhost', port=5432):
        self.dbname = dbname
        self.user = user
        self.password = password
        self.host = host
        self.port = port
        self.connection = None
        self.cursor = None

    def connect(self):
        try:
            self.connection = psycopg2.connect(
                dbname=self.dbname,
                user=self.user,
                password=self.password,
                host=self.host,
                port=self.port
            )
            self.cursor = self.connection.cursor(cursor_factory=DictCursor)
            print("Connected to the database")
        except Exception as e:
            print(f"Unable to connect to the database: {e}")

    def disconnect(self):
        if self.connection:
            self.cursor.close()
            self.connection.close()
            print("Disconnected from the database")

    def execute_query(self, query):
        try:
            self.cursor.execute(query)
            self.connection.commit()
            print("Query executed successfully")
        except Exception as e:
            print(f"Query execution error: {e}")
            self.connection.rollback()
            raise e

    def fetch_data(self, query):
        try:
            self.cursor.execute(query)
            rows = self.cursor.fetchall()
            return rows
        except Exception as e:
            print(f"Error fetching data: {e}")
            self.connection.rollback()
            raise e


if __name__ == "__main__":
    db = Database(
        dbname='platform',
        user='client',
        password='1234',
        host='localhost',
        port=5432
    )
    db.connect()

    new_window, login = Authorization(db)
    while new_window != '':
        if new_window == 'Authorization':
            new_window, login = Authorization(db)
        elif new_window == 'Registration':
            new_window = Registration(db)
        elif new_window == 'authors':
            new_window, login, table_name, title = AuthorMain(db, login)
        elif new_window == 'Editing':
            new_window, login = Editing(db, login, table_name)
        elif new_window == 'AddCourse':
            new_window, login = Adding(db, login)
        elif new_window == 'EditCourse':
            new_window, login = EditCourse(db, title, login)
        elif new_window == 'students':
            new_window = StudentMain(db)
        else: new_window = ''

    db.disconnect()
