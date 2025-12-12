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

def _auto_seed_data():
    """Automatically seed initial data if database is empty"""
    try:
        from .models import Schools, Colleges, Departments, Language, Country
        
        # Check if database is empty (no schools exist)
        school_count = Schools.query.count()
        if school_count == 0:
            # Database is empty, seed all data
            _seed_all_data()
        else:
            # Database has data, ensure all required schools (ID 1-15) exist
            _ensure_required_schools()
    except Exception as e:
        # Silently fail - seed data can be run manually if needed
        pass

def _seed_all_data():
    """Seed all initial data (languages, countries, schools, colleges, departments)"""
    try:
        from .models import Schools, Colleges, Departments, Language, Country
        
        # 1. Seed Languages
        languages = [
            Language(code='en', name='English', native_name='English'),
            Language(code='ko', name='Korean', native_name='한국어'),
            Language(code='vi', name='Vietnamese', native_name='Tiếng Việt'),
            Language(code='zh', name='Chinese', native_name='中文'),
            Language(code='ja', name='Japanese', native_name='日本語'),
            Language(code='my', name='Myanmar', native_name='မြန်မာ'),
        ]
        for lang in languages:
            if not Language.query.get(lang.code):
                db.session.add(lang)
        
        # 2. Seed Countries
        countries = [
            Country(iso2='US', name='United States'),
            Country(iso2='KR', name='South Korea'),
            Country(iso2='VN', name='Vietnam'),
            Country(iso2='CN', name='China'),
            Country(iso2='JP', name='Japan'),
            Country(iso2='MM', name='Myanmar'),
        ]
        for country in countries:
            if not Country.query.get(country.iso2):
                db.session.add(country)
        
        # 3. Seed Schools (ID 1-15)
        schools = [
            (1, 'Keimyung University', 'https://www.kmu.ac.kr'),
            (2, 'Seoul National University', 'https://www.snu.ac.kr'),
            (3, 'Korea University', 'https://www.korea.ac.kr'),
            (4, 'Yonsei University', 'https://www.yonsei.ac.kr'),
            (5, 'KAIST', 'https://www.kaist.ac.kr'),
            (6, 'Sungkyunkwan University', 'https://www.skku.edu'),
            (7, 'Hongik University', 'https://www.hongik.ac.kr'),
            (8, 'Hanyang University', 'https://www.hanyang.ac.kr'),
            (9, 'Chung-Ang University', 'https://www.cau.ac.kr'),
            (10, 'Kyung Hee University', 'https://www.khu.ac.kr'),
            (11, 'Ewha Womans University', 'https://www.ewha.ac.kr'),
            (12, 'Sogang University', 'https://www.sogang.ac.kr'),
            (13, 'Pusan National University', 'https://www.pnu.ac.kr'),
            (14, 'Inha University', 'https://www.inha.ac.kr'),
            (15, 'Other University', ''),
        ]
        for school_id, school_name, website_url in schools:
            if not Schools.query.get(school_id):
                db.session.add(Schools(id=school_id, school_name=school_name, website_url=website_url))
        
        db.session.flush()  # Ensure schools are available for departments
        
        # 4. Seed Colleges and Departments for each school
        all_schools = Schools.query.all()
        department_names = [
            'Computer Science', 'Business Administration', 'Engineering', 'Liberal Arts', 'Medicine',
            'Law', 'Fine Arts', 'Music', 'Physical Education', 'Natural Sciences',
            'International Studies', 'Media & Communication', 'Architecture', 'Culinary Arts',
            'Early Childhood Education', 'Environmental Science', 'Psychology', 'Economics',
            'Information Technology', 'Theater & Film',
        ]
        
        for school in all_schools:
            # Create default college if none exist
            default_college = Colleges.query.filter_by(school_id=school.id, college_name='General College').first()
            if not default_college:
                default_college = Colleges(school_id=school.id, college_name='General College')
                db.session.add(default_college)
                db.session.flush()
            
            # Add departments
            for dept_name in department_names:
                existing = Departments.query.filter_by(
                    school_id=school.id,
                    department_name=dept_name
                ).first()
                if not existing:
                    dept = Departments(
                        school_id=school.id,
                        college_id=default_college.id,
                        department_name=dept_name
                    )
                    db.session.add(dept)
        
        db.session.commit()
    except Exception as e:
        db.session.rollback()
        pass

def _ensure_required_schools():
    """Ensure all required schools (ID 1-15) exist in database"""
    try:
        from .models import Schools
        
        required_schools = [
            (1, 'Keimyung University', 'https://www.kmu.ac.kr'),
            (2, 'Seoul National University', 'https://www.snu.ac.kr'),
            (3, 'Korea University', 'https://www.korea.ac.kr'),
            (4, 'Yonsei University', 'https://www.yonsei.ac.kr'),
            (5, 'KAIST', 'https://www.kaist.ac.kr'),
            (6, 'Sungkyunkwan University', 'https://www.skku.edu'),
            (7, 'Hongik University', 'https://www.hongik.ac.kr'),
            (8, 'Hanyang University', 'https://www.hanyang.ac.kr'),
            (9, 'Chung-Ang University', 'https://www.cau.ac.kr'),
            (10, 'Kyung Hee University', 'https://www.khu.ac.kr'),
            (11, 'Ewha Womans University', 'https://www.ewha.ac.kr'),
            (12, 'Sogang University', 'https://www.sogang.ac.kr'),
            (13, 'Pusan National University', 'https://www.pnu.ac.kr'),
            (14, 'Inha University', 'https://www.inha.ac.kr'),
            (15, 'Other University', ''),
        ]
        
        for school_id, school_name, website_url in required_schools:
            school = Schools.query.get(school_id)
            if not school:
                school = Schools(id=school_id, school_name=school_name, website_url=website_url)
                db.session.add(school)
            elif school.school_name != school_name:
                school.school_name = school_name
                school.website_url = website_url
        
        db.session.commit()
    except Exception as e:
        db.session.rollback()
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
        # Auto-seed: Seed initial data if database is empty
        _auto_seed_data()
    
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