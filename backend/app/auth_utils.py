from functools import wraps
import jwt
from flask import request, jsonify, current_app
from .models import Users

def require_auth(func):
    """
    헤더의 'Authorization: Bearer <token>'을 검사하여
    유효한 JWT 토큰일 경우 request.user에 SQLAlchemy 사용자 객체를 주입합니다.
    """
    @wraps(func)
    def wrapper(*args, **kwargs):
        token = None
        auth_header = request.headers.get("Authorization")
        
        if auth_header and auth_header.startswith("Bearer "):
            token = auth_header.split(" ")[1]
        
        if not token:
            return jsonify({"error": "Authorization token is missing"}), 401
        
        try:
            # current_app.config에서 SECRET_KEY를 가져옴
            payload = jwt.decode(token, current_app.config['SECRET_KEY'], algorithms=["HS256"])
            user_id = payload.get("user_id")
            if user_id is None:
                raise jwt.InvalidTokenError
            
            user = Users.query.get(user_id)
            if not user:
                 return jsonify({"error": "User not found"}), 401
            
            request.user = user # SQLAlchemy User 모델 객체 자체를 주입

        except jwt.ExpiredSignatureError:
            return jsonify({"error": "Token has expired"}), 401
        except jwt.InvalidTokenError:
            return jsonify({"error": "Invalid token"}), 401
        
        return func(*args, **kwargs)
    
    return wrapper