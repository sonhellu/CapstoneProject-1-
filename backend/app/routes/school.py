from flask import Blueprint, jsonify, request, current_app
from urllib.parse import quote
from ..models import Schools
from ..auth_utils import require_auth

school_bp = Blueprint('school_bp', __name__, url_prefix='/api/school')

@school_bp.route("/my-homepage-translation", methods=["GET"])
@require_auth
def get_my_school_homepage_translation():
    """
    (Yandex 버전) Google/Bing/Papago의 차단 이슈를 우회하기 위해
    URL 방식 번역을 지원하는 Yandex Translate를 사용합니다.
    """
    try:
        user = request.user 
        
        # Validate user has school_id
        if not user.school_id:
            return jsonify({"error": "User does not have a school assigned"}), 400
            
        school = Schools.query.get(user.school_id)

        if not school:
            return jsonify({"error": "School not found"}), 404
        if not school.website_url:
            return jsonify({"error": "School website URL not found"}), 404

        # 1. 언어 코드 매핑 (Yandex는 표준 ISO 코드를 따름)
        user_lang = user.main_language
        if not user_lang:
            return jsonify({"error": "User main language not set"}), 400
        
        # 2. 학교 URL 인코딩
        school_url = school.website_url
        encoded_school_url = quote(school_url, safe='')

        # 3. Yandex 번역 URL 생성
        # 형식: https://translate.yandex.com/translate?lang=ko-{대상언어}&url={URL}&view=c
        final_translation_url = f"https://translate.yandex.com/translate?lang=ko-{user_lang}&url={encoded_school_url}&view=c"

        return jsonify({
            "school_id": school.id,
            "school_name": school.school_name,
            "original_url": school_url,
            "translated_url": final_translation_url, # Yandex URL 반환
            "target_language": user_lang
        }), 200
    except Exception as e:
        current_app.logger.error(f"Get school translation error: {str(e)}", exc_info=True)
        return jsonify({"error": f"Failed to get school translation: {str(e)}"}), 500
