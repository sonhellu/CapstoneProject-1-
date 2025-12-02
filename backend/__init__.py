from flask import Flask, jsonify
from .config import Config
from .database import db, ma

def create_app():
    """애플리케이션 팩토리 함수"""
    
    app = Flask(__name__)
    
    # 1. 설정 로드
    app.config.from_object(Config)
    
    # 2. DB 및 Marshmallow 초기화
    db.init_app(app)
    ma.init_app(app)
    
    # 3. 블루프린트(기능별 파일) 등록
    from .routes.auth import auth_bp
    from .routes.school import school_bp
    from .routes.community import community_bp
    from .routes.matching import matching_bp
    
    app.register_blueprint(auth_bp)
    app.register_blueprint(school_bp)
    app.register_blueprint(community_bp)
    app.register_blueprint(matching_bp)
    
    # 4. 모델 임포트 (DB 생성 명령어에 필요)
    from . import models
    
    # 5. (선택) 간단한 루트 엔드포인트
    @app.route("/")
    def read_root():
        return jsonify({"message": "Hi-Campus API 서버 (분리된 구조)"})

    # 6. (선택) DB 테이블 생성용 CLI 명령어
    @app.cli.command("init-db")
    def init_db():
        db.create_all()
        print("Database tables created.")

    return app