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
    data = request.json
    
    required_fields = [
        'email', 'password', 'nickname', 'realname', 'gender', 
        'main_language', 'nationality_iso2', 'school_id', 
        'department_id', 'enrollment_year'
    ]
    if not all(field in data for field in required_fields):
        return jsonify({"error": "Missing required fields"}), 400

    if Users.query.filter_by(email=data['email']).first():
        return jsonify({"error": "Email already registered"}), 409

    hashed_password = bcrypt.hashpw(
        data['password'].encode('utf-8'), 
        bcrypt.gensalt()
    ).decode('utf-8')

    new_user = Users(
        email=data['email'],
        password_hash=hashed_password,
        nickname=data['nickname'],
        realname=data['realname'],
        gender=data['gender'],
        main_language=data['main_language'],
        nationality_iso2=data['nationality_iso2'],
        school_id=data['school_id'],
        department_id=data['department_id'],
        enrollment_year=data['enrollment_year']
    )
    
    db.session.add(new_user)
    db.session.commit()
    
    return jsonify({"message": "User registered successfully"}), 201


@auth_bp.route("/login", methods=["POST"])
def login():
    """로그인 API - JWT 토큰 발급"""
    data = request.json
    email = data.get("email")
    password = data.get("password")

    if not email or not password:
        return jsonify({"error": "Email and password are required"}), 400

    user = Users.query.filter_by(email=email).first()

    if not user or not bcrypt.checkpw(password.encode('utf-8'), user.password_hash.encode('utf-8')):
        return jsonify({"error": "Invalid email or password"}), 401

    token_payload = {
        "user_id": user.id,
        "sub": user.email,
        "iat": datetime.now(timezone.utc),
        "exp": datetime.now(timezone.utc) + timedelta(days=1)
    }
    
    access_token = jwt.encode(token_payload, current_app.config['SECRET_KEY'], algorithm="HS256")

    return jsonify({"access_token": access_token, "token_type": "bearer"}), 200