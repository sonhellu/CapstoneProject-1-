# app/routes/school.py

from flask import Blueprint, jsonify, request
from urllib.parse import quote 
from ..models import Schools, Colleges, Departments
from ..auth_utils import require_auth
from ..schemas import user_schema
# import requests # 실시간 번역 로직(translate_text)을 넣으려면 필요

school_bp = Blueprint('school_bp', __name__, url_prefix='/api/school')

# -------------------------------------------------------------
# 1. 학교 홈페이지 번역 링크 제공 API
# -------------------------------------------------------------
@school_bp.route("/my-homepage-translation", methods=["GET"])
@require_auth
def get_my_school_homepage_translation():
    """
    (Yandex 버전) Google/Bing/Papago의 차단 이슈를 우회하기 위해
    URL 방식 번역을 지원하는 Yandex Translate 링크를 제공합니다.
    """
    
    user = request.user 
    school = Schools.query.get(user.school_id)

    if not school or not school.website_url:
        return jsonify({"error": "School website URL not found"}), 404

    # 1. 언어 코드 매핑
    # Yandex는 표준 ISO 코드를 따르므로, DB의 main_language 코드를 그대로 사용합니다.
    user_lang = user.main_language 
    
    # 2. 학교 URL 인코딩
    school_url = school.website_url
    encoded_school_url = quote(school_url, safe='')

    # 3. Yandex 번역 URL 생성
    # 형식: https://translate.yandex.com/translate?lang=ko-{대상언어}&url={URL}&view=c
    # 한국 학교 홈페이지(원본 언어 ko)를 유저 언어(user_lang)로 번역하도록 설정합니다.
    final_translation_url = f"https://translate.yandex.com/translate?lang=ko-{user_lang}&url={encoded_school_url}&view=c"

    return jsonify({
        "school_id": school.id,
        "school_name": school.school_name,
        "original_url": school_url,
        "translated_url": final_translation_url, # Yandex URL 반환
        "target_language": user_lang
    }), 200

# -------------------------------------------------------------
# 2. 다국어 지원: 단과대학 목록 조회 API
# (실시간 번역 함수는 편의를 위해 여기에 정의하지 않았습니다. 
# 만약 사용한다면, 이전에 논의했던 translate_text 함수를 별도로 정의해야 합니다.)
# -------------------------------------------------------------
@school_bp.route("/colleges", methods=["GET"])
@require_auth 
def get_colleges():
    """
    현재 로그인한 사용자의 학교에 속한 모든 단과대학 목록을 반환합니다.
    (현재 DB 구조를 반영하여 단일 'name' 컬럼을 사용한다고 가정합니다.)
    """
    user = request.user
    
    # 만약 유저 언어에 맞게 번역해야 한다면:
    # 1. user_lang = user.main_language 를 가져옵니다.
    # 2. DB에서 가져온 name(한국어)을 translate_text(name, user_lang)로 번역합니다.
    
    colleges = Colleges.query.filter_by(school_id=user.school_id).all()
    
    # 현재는 DB에 'name' 컬럼만 있다고 가정하고, 그 이름을 그대로 반환합니다.
    results = [{
        "id": c.id,
        "name": c.name # DB에 저장된 이름 (대부분 한국어일 것)
    } for c in colleges]
    
    return jsonify(results), 200

# -------------------------------------------------------------
# 3. 다국어 지원: 학과 목록 조회 API
# -------------------------------------------------------------
@school_bp.route("/departments", methods=["GET"])
@require_auth
def get_departments():
    """
    현재 로그인한 사용자의 학교에 속한 모든 학과 목록을 반환합니다.
    """
    user = request.user
    
    # college_id를 쿼리 파라미터로 받아 해당 단과대학의 학과만 필터링할 수도 있습니다.
    college_id = request.args.get("college_id", type=int)

    query = Departments.query.join(Colleges).filter(Colleges.school_id == user.school_id)
    
    if college_id:
        query = query.filter(Departments.college_id == college_id)
        
    departments = query.all()
    
    # 현재는 DB에 'name' 컬럼만 있다고 가정하고, 그 이름을 그대로 반환합니다.
    results = [{
        "id": d.id,
        "name": d.name # DB에 저장된 이름
    } for d in departments]

    return jsonify(results), 200
