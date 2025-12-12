from flask import Flask, jsonify
from flask_cors import CORS
from .config import Config
from .database import db, ma
import os

def _ensure_student_id_column():
    """Ensure student_id column exists in users table (for existing databases)"""
    try:
        database_url = os.getenv("DATABASE_URL", "")
        is_postgresql = database_url.startswith("postgresql://") or database_url.startswith("postgres://")
        
        # Check if column exists
        if is_postgresql:
            result = db.session.execute(db.text("""
                SELECT 1 FROM information_schema.columns 
                WHERE table_name = 'users' AND column_name = 'student_id'
            """))
            exists = result.fetchone() is not None
        else:
            # MySQL
            result = db.session.execute(db.text("SHOW COLUMNS FROM users LIKE 'student_id'"))
            exists = result.fetchone() is not None
        
        if not exists:
            if is_postgresql:
                db.session.execute(db.text("ALTER TABLE users ADD COLUMN student_id VARCHAR(50)"))
            else:
                db.session.execute(db.text("ALTER TABLE users ADD COLUMN student_id VARCHAR(50) NULL AFTER realname"))
            db.session.commit()
    except Exception as e:
        db.session.rollback()
        # Ignore if column already exists
        pass

def create_app():
    """애플리케이션 팩토리 함수"""
    
    app = Flask(__name__)
    
    # CORS 설정 - cho phép frontend gọi API
    CORS(app, resources={r"/api/*": {"origins": "*"}})
    
    # 1. 설정 로드
    app.config.from_object(Config)
    
    # 2. DB 및 Marshmallow 초기화
    db.init_app(app)
    ma.init_app(app)

    # 3. 모델 임포트 (DB 생성 명령어에 필요 - phải import trước khi gọi db.create_all())
    from . import models
    
    # 4. 서버가 시작될 때 자동으로 테이블 생성
    with app.app_context():
        db.create_all()
        # Auto-migrate: Add student_id column if it doesn't exist (for existing databases)
        _ensure_student_id_column()
    
    # 5. 블루프린트(기능별 파일) 등록
    from .routes.auth import auth_bp
    from .routes.school import school_bp
    from .routes.community import community_bp
    from .routes.matching import matching_bp
    from .routes.options import options_bp
    from .routes.profile import profile_bp
    
    app.register_blueprint(auth_bp)
    app.register_blueprint(school_bp)
    app.register_blueprint(community_bp)
    app.register_blueprint(matching_bp)
    app.register_blueprint(options_bp)
    app.register_blueprint(profile_bp)
    
    # 6. (선택) 간단한 루트 엔드포인트
    @app.route("/")
    def read_root():
        return jsonify({"message": "Hi-Campus API 서버 (분리된 구조)"})

    # 7. (선택) DB 테이블 생성용 CLI 명령어
    @app.cli.command("init-db")
    def init_db():
        db.create_all()

    return app