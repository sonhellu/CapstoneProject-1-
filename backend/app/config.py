# app/config.py
import os

class Config:
    # 1. Render에서 제공하는 DB 주소(DATABASE_URL)가 있으면 그걸 쓰고(PostgreSQL),
    # 2. 없으면 우리가 쓰던 로컬 주소(MySQL)를 씁니다.
    SQLALCHEMY_DATABASE_URI = os.getenv("DATABASE_URL")
    
    # Convert postgres:// to postgresql:// (SQLAlchemy requirement)
    if SQLALCHEMY_DATABASE_URI and SQLALCHEMY_DATABASE_URI.startswith("postgres://"):
        SQLALCHEMY_DATABASE_URI = SQLALCHEMY_DATABASE_URI.replace("postgres://", "postgresql://", 1)

    if not SQLALCHEMY_DATABASE_URI:
        # 로컬 개발용 (MySQL)
        DB_USER = os.getenv("DB_USER", "root")
        DB_PASS = os.getenv("DB_PASS", "1234")
        DB_HOST = os.getenv("DB_HOST", "127.0.0.1")
        DB_NAME = os.getenv("DB_NAME", "hi_campus")
        SQLALCHEMY_DATABASE_URI = f"mysql+pymysql://{DB_USER}:{DB_PASS}@{DB_HOST}/{DB_NAME}?charset=utf8mb4"

    SQLALCHEMY_TRACK_MODIFICATIONS = False

    # 비밀 키 설정
    SECRET_KEY = os.getenv("SECRET_KEY", "dev-key-please-change")

    # AI API 키
    OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")