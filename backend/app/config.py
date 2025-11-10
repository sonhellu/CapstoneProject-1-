import os

class Config:
    """Flask 애플리케이션 설정"""
    
    # DB 설정
    DB_USER = os.getenv("DB_USER", "root")
    DB_PASS = os.getenv("DB_PASS", "1234") # 본인 비밀번호로 수정
    DB_HOST = os.getenv("DB_HOST", "127.0.0.1")
    DB_NAME = os.getenv("DB_NAME", "hi_campus")
    
    SQLALCHEMY_DATABASE_URI = f"mysql+pymysql://{DB_USER}:{DB_PASS}@{DB_HOST}/{DB_NAME}?charset=utf8mb4"
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    
    # JWT 비밀 키 (매우 중요!)
    SECRET_KEY = os.getenv("SECRET_KEY", "my-super-secret-key-for-hi-campus-project-123!")