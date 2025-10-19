import mysql.connector
from mysql.connector import errorcode

# 보안을 위해 다른 파일에 분리하거나 환경 변수를 사용하는 것이 좋습니다.
DB_CONFIG = {
    'host': '127.0.0.1',
    'user': 'root',
    'password': '1234',
    'db': 'hi_campus',
    'charset': 'utf8mb4'
}

def get_db_connection():
    """데이터베이스 커넥션을 생성하고 반환하는 함수"""
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        return conn
    except mysql.connector.Error as err:
        if err.errno == errorcode.ER_ACCESS_DENIED_ERROR:
            print("사용자 이름 또는 비밀번호가 잘못되었습니다.")
        elif err.errno == errorcode.ER_BAD_DB_ERROR:
            print("데이터베이스가 존재하지 않습니다.")
        else:
            print(err)
        return None