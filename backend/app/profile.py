# app/routes/profile.py

from flask import Blueprint, jsonify, request
from ..models import db, Users # Users 모델 필요
from ..schemas import user_schema # UserSchema 필요
from ..auth_utils import require_auth # 인증 데코레이터 필요

profile_bp = Blueprint('profile_bp', __name__, url_prefix='/api/profile')

# --- 1. 내 프로필 조회 API ---
@profile_bp.route("/me", methods=["GET"])
@require_auth # 로그인 필수
def get_my_profile():
    """
    로그인한 사용자 본인의 프로필 정보를 반환합니다.
    """
    user = request.user 
    # user_schema가 학교명, 학과명 등 중첩된 정보까지 포함하여 반환합니다.
    return user_schema.jsonify(user), 200

# --- 2. 타인 프로필 조회 API (커뮤니티 기능 확장) ---
@profile_bp.route("/<int:user_id>", methods=["GET"])
def get_user_profile(user_id):
    """
    특정 사용자(user_id)의 공개 프로필 정보를 반환합니다.
    (로그인 불필요, 또는 약한 인증만 필요)
    """
    user = Users.query.get(user_id)
    if not user:
        return jsonify({"error": "User not found"}), 404
    
    # 민감 정보(password_hash 등)가 user_schema에서 제외되었으므로 안전합니다.
    return user_schema.jsonify(user), 200


# --- 3. 프로필 수정 API ---
@profile_bp.route("/me", methods=["PUT"])
@require_auth # 로그인 필수
def update_my_profile():
    """
    로그인한 사용자의 프로필 정보를 수정합니다. (image_70a041.png)
    """
    user = request.user
    data = request.json # 프론트엔드에서 받은 JSON 데이터
    
    # 1. 일반 필드 업데이트 (프론트엔드 필드명 -> DB 컬럼명 매핑)
    if 'username' in data: # UI: username -> DB: nickname
        user.nickname = data['username']
    if 'Full Name' in data: # UI: Full Name -> DB: realname (성명)
        user.realname = data['Full Name']
    if 'Year' in data: # UI: Year -> DB: enrollment_year
        user.enrollment_year = data['Year']
        
    # 2. 드롭다운 (외래 키) 필드 업데이트 (UI에서 선택 가능하므로)
    if 'school_id' in data:
        user.school_id = data['school_id']
    if 'department_id' in data: # Major
        user.department_id = data['department_id']
    if 'nationality_iso2' in data: # Nationality
        user.nationality_iso2 = data['nationality_iso2']

    try:
        db.session.commit()
        # 수정된 최신 정보를 반환하여 프론트엔드에 업데이트되었음을 알림
        return user_schema.jsonify(user), 200
    except Exception as e:
        db.session.rollback()
        # 데이터베이스 제약 조건 오류(예: 중복된 닉네임) 발생 시
        return jsonify({"error": "Profile update failed due to data constraints", "details": str(e)}), 500