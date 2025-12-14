# app/routes/school.py (최종 버전)

from flask import Blueprint, jsonify, request
from urllib.parse import quote 
from ..models import Schools, Colleges, Departments
from ..auth_utils import require_auth

school_bp = Blueprint('school_bp', __name__, url_prefix='/api/school')

# -------------------------------------------------------------
# 0. 언어 컬럼 매핑 함수
# -------------------------------------------------------------
def get_language_column(user_lang):
    """
    사용자 언어 코드에 따라 DB에서 읽어올 컬럼 이름을 반환합니다.
    """
    lang_map = {
        'ko': 'name_ko',
        'en': 'name_en',
        'zh': 'name_zh',
        'vi': 'name_vi',
        'ja': 'name_ja',
        'my': 'name_my'
    }
    # 지원 언어가 아니면 기본값 'name_ko'를 반환합니다.
    return lang_map.get(user_lang, 'name_ko') 

# -------------------------------------------------------------
# 1. 학교 홈페이지 번역 링크 제공 API (Yandex 유지)
# -------------------------------------------------------------
@school_bp.route("/my-homepage-translation", methods=["GET"])
@require_auth
def get_my_school_homepage_translation():
    # ... (Yandex 코드는 그대로 유지) ...
    user = request.user 
    school = Schools.query.get(user.school_id)

    if not school or not school.website_url:
        return jsonify({"error": "School website URL not found"}), 404

    user_lang = user.main_language 
    school_url = school.website_url
    encoded_school_url = quote(school_url, safe='')

    final_translation_url = f"https://translate.yandex.com/translate?lang=ko-{user_lang}&url={encoded_school_url}&view=c"

    return jsonify({
        "school_id": school.id,
        "school_name": school.school_name,
        "original_url": school_url,
        "translated_url": final_translation_url,
        "target_language": user_lang
    }), 200

# -------------------------------------------------------------
# 2. 다국어 지원: 단과대학 목록 조회 API (DB 직접 조회)
# -------------------------------------------------------------
@school_bp.route("/colleges", methods=["GET"])
@require_auth 
def get_colleges():
    user = request.user
    user_lang = user.main_language
    
    colleges = Colleges.query.filter_by(school_id=user.school_id).all()
    
    # 사용자 언어에 맞는 컬럼 이름을 가져옵니다.
    name_col = get_language_column(user_lang)

    results = []
    for c in colleges:
        # getattr(객체, 컬럼명, 기본값)을 사용하여 해당 언어의 이름을 가져옵니다.
        # 만약 해당 컬럼(예: name_my)에 데이터가 없으면 'name_ko'를 반환합니다.
        display_name = getattr(c, name_col, c.name_ko) 
        
        results.append({
            "id": c.id,
            "name": display_name 
        })
        
    return jsonify(results), 200

# -------------------------------------------------------------
# 3. 다국어 지원: 학과 목록 조회 API (DB 직접 조회)
# -------------------------------------------------------------
@school_bp.route("/departments", methods=["GET"])
@require_auth
def get_departments():
    user = request.user
    user_lang = user.main_language
    
    college_id = request.args.get("college_id", type=int)
    query = Departments.query.join(Colleges).filter(Colleges.school_id == user.school_id)
    if college_id:
        query = query.filter(Departments.college_id == college_id)
        
    departments = query.all()
    
    name_col = get_language_column(user_lang)
    
    results = []
    for d in departments:
        display_name = getattr(d, name_col, d.name_ko)
        
        results.append({
            "id": d.id,
            "name": display_name
        })

    return jsonify(results), 200
