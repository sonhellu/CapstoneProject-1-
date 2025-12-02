import os

class Config:
    """Flask 애플리케이션 설정"""
    
    # DB 설정 - Sử dụng environment variables từ Render.com
    DB_USER = os.getenv("DB_USER", "root")
    DB_PASS = os.getenv("DB_PASS", "1234")
    DB_HOST = os.getenv("DB_HOST", "127.0.0.1")
    DB_PORT = os.getenv("DB_PORT", "3306")
    DB_NAME = os.getenv("DB_NAME", "hi_campus")
    
    # Hỗ trợ cả internal database URL từ Render (nếu có)
    DATABASE_URL = os.getenv("DATABASE_URL")
    if DATABASE_URL:
        # Render cung cấp DATABASE_URL dạng: mysql://user:pass@host:port/dbname
        # Cần chuyển đổi sang format SQLAlchemy
        if DATABASE_URL.startswith("mysql://"):
            SQLALCHEMY_DATABASE_URI = DATABASE_URL.replace("mysql://", "mysql+pymysql://", 1) + "?charset=utf8mb4"
        else:
            SQLALCHEMY_DATABASE_URI = DATABASE_URL
    else:
        # Fallback về cách cũ
        SQLALCHEMY_DATABASE_URI = f"mysql+pymysql://{DB_USER}:{DB_PASS}@{DB_HOST}:{DB_PORT}/{DB_NAME}?charset=utf8mb4"
    
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    
    # JWT 비밀 키 (매우 중요!) - Nên set trong Render Environment Variables
    SECRET_KEY = os.getenv("SECRET_KEY", "my-super-secret-key-for-hi-campus-project-123!")
    
    # Flask settings
    DEBUG = os.getenv("FLASK_DEBUG", "False").lower() == "true"