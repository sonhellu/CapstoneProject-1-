from flask import Blueprint, request, jsonify, current_app
from ..database import db
from ..models import Users
import bcrypt
import jwt
from datetime import datetime, timedelta, timezone

# 'auth_bp'라는 이름의 블루프린트 생성
auth_bp = Blueprint('auth_bp', __name__, url_prefix='/api/auth')

@auth_bp.route("/register", methods=["POST"])
def register():
    """회원가입 API"""
    try:
        data = request.json
        
        if not data:
            return jsonify({"error": "Request body is required"}), 400
        
        required_fields = [
            'email', 'password', 'nickname', 'realname', 'gender', 
            'main_language', 'nationality_iso2', 'school_id', 
            'department_id', 'enrollment_year'
        ]
        if not all(field in data for field in required_fields):
            return jsonify({"error": "Missing required fields"}), 400

        # Validate email format
        email = data['email'].strip().lower()
        if '@' not in email or '.' not in email.split('@')[1]:
            return jsonify({"error": "Invalid email format"}), 400

        # Validate password length
        if len(data['password']) < 6:
            return jsonify({"error": "Password must be at least 6 characters"}), 400

        # Validate enrollment_year is a number
        try:
            enrollment_year = int(data['enrollment_year'])
            if enrollment_year < 1900 or enrollment_year > 2100:
                return jsonify({"error": "Invalid enrollment year"}), 400
        except (ValueError, TypeError):
            return jsonify({"error": "enrollment_year must be a number"}), 400

        # Kiểm tra email đã tồn tại
        if Users.query.filter_by(email=email).first():
            return jsonify({"error": "Email already registered"}), 409

        # Validate foreign keys trước khi tạo user
        from ..models import Schools, Departments, Language, Country
        
        if not Schools.query.get(data['school_id']):
            return jsonify({"error": f"School with id {data['school_id']} not found"}), 400
        
        if not Departments.query.get(data['department_id']):
            return jsonify({"error": f"Department with id {data['department_id']} not found"}), 400
        
        if not Language.query.get(data['main_language']):
            return jsonify({"error": f"Language code '{data['main_language']}' not found"}), 400
        
        if not Country.query.get(data['nationality_iso2']):
            return jsonify({"error": f"Country code '{data['nationality_iso2']}' not found"}), 400

        # Validate gender
        if data['gender'] not in ['male', 'female']:
            return jsonify({"error": "Gender must be 'male' or 'female'"}), 400

        hashed_password = bcrypt.hashpw(
            data['password'].encode('utf-8'), 
            bcrypt.gensalt()
        ).decode('utf-8')

        new_user = Users(
            email=email,
            password_hash=hashed_password,
            nickname=data['nickname'].strip(),
            realname=data['realname'].strip(),
            gender=data['gender'],
            main_language=data['main_language'],
            nationality_iso2=data['nationality_iso2'].upper(),
            school_id=data['school_id'],
            department_id=data['department_id'],
            enrollment_year=enrollment_year
        )
        
        db.session.add(new_user)
        db.session.commit()
        
        return jsonify({"message": "User registered successfully"}), 201
    
    except Exception as e:
        db.session.rollback()
        # Log error để debug
        current_app.logger.error(f"Registration error: {str(e)}", exc_info=True)
        return jsonify({"error": f"Registration failed: {str(e)}"}), 500
@auth_bp.route("/login", methods=["POST"])
def login():
    """로그인 API - JWT 토큰 발급"""
    try:
        data = request.json
        
        if not data:
            return jsonify({"error": "Request body is required"}), 400
        
        email = data.get("email", "").strip().lower()
        password = data.get("password")

        if not email or not password:
            return jsonify({"error": "Email and password are required"}), 400

        user = Users.query.filter_by(email=email).first()

        if not user:
            return jsonify({"error": "Invalid email or password"}), 401
        
        if not user.password_hash:
            current_app.logger.error(f"User {user.id} has no password hash")
            return jsonify({"error": "Invalid user data"}), 500

        if not bcrypt.checkpw(password.encode('utf-8'), user.password_hash.encode('utf-8')):
            return jsonify({"error": "Invalid email or password"}), 401

        token_payload = {
            "user_id": user.id,
            "sub": user.email,
            "iat": datetime.now(timezone.utc),
            "exp": datetime.now(timezone.utc) + timedelta(days=1)
        }
        
        access_token = jwt.encode(token_payload, current_app.config['SECRET_KEY'], algorithm="HS256")

        return jsonify({"access_token": access_token, "token_type": "bearer"}), 200
    
    except Exception as e:
        current_app.logger.error(f"Login error: {str(e)}", exc_info=True)
        return jsonify({"error": f"Login failed: {str(e)}"}), 500