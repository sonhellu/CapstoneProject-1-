from flask import Blueprint, jsonify, request
from ..models import Schools
from ..auth_utils import require_auth

school_bp = Blueprint('school_bp', __name__, url_prefix='/api/school')

@school_bp.route("/my-homepage-translation", methods=["GET"])
@require_auth # 로그인 필수
def get_my_school_homepage_translation():
    """로그인한 사용자의 학교 홈페이지 번역 URL 반환"""
    
    user = request.user 
    school = Schools.query.get(user.school_id)

    if not school or not school.website_url:
        return jsonify({"error": "School website URL not found"}), 404

    user_lang = user.main_language
    school_url = school.website_url
    
    final_translation_url = f"https://translate.google.com/translate?sl=auto&tl={user_lang}&u={school_url}"

    return jsonify({
        "school_id": school.id,
        "school_name": school.school_name,
        "original_url": school_url,
        "translated_url": final_translation_url,
        "target_language": user_lang
    }), 200