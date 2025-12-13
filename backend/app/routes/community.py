from flask import Blueprint, jsonify, request, current_app
from ..models import db, Boards, Posts
from ..schemas import post_schema, posts_schema
from ..auth_utils import require_auth
import requests
import urllib.parse

community_bp = Blueprint('community_bp', __name__, url_prefix='/api')

@community_bp.route("/boards", methods=["GET"])
def get_boards():
    """
    모든 게시판 목록 조회 API (테스트용)
    """
    try:
        boards = Boards.query.order_by(Boards.order_index.asc()).all()
        
        result = []
        for board in boards:
            result.append({
                "id": board.id,
                "board_name": board.board_name,
                "description": board.description,
                "community_id": board.community_id,
                "order_index": board.order_index
            })
        
        return jsonify(result), 200
    except Exception as e:
        current_app.logger.error(f"Get boards error: {str(e)}", exc_info=True)
        return jsonify({"error": f"Failed to get boards: {str(e)}"}), 500

@community_bp.route("/board/<int:board_id>/posts", methods=["GET"])
def get_posts(board_id):
    """
    특정 게시판의 글 목록 조회 API
    
    [Query Parameters]
    - limit: 가져올 게시글의 개수 (기본값: 20)
    
    [사용 예시]
    1. 홈 화면 (최신글 5개 미리보기): 
       GET /api/board/1/posts?limit=5
       
    2. 게시판 전체보기 화면 (기본 20개): 
       GET /api/board/1/posts
    """
    try:
        # 1. 쿼리 파라미터 받기 (limit)
        # URL 뒤에 ?limit=5 가 있으면 5를, 없으면 기본값 20을 사용
        try:
            limit = request.args.get('limit', default=20, type=int)
            if limit < 1 or limit > 100:
                limit = 20
        except (ValueError, TypeError):
            limit = 20
        
        # 2. 게시판 존재 여부 확인
        board = Boards.query.get(board_id)
        if not board:
            return jsonify({
                "error": "Board not found",
                "message": f"Board with id {board_id} does not exist. Use GET /api/boards to see available boards."
            }), 404

        # 3. DB 조회
        # 해당 게시판(board_id)의 글을 작성일(created_at) 역순(최신순)으로 정렬하고
        # limit 개수만큼만 가져옵니다.
        posts = Posts.query.filter_by(board_id=board_id)\
                           .order_by(Posts.created_at.desc())\
                           .limit(limit)\
                           .all()
        
        # 4. 데이터 직렬화 (JSON 변환) 및 가공
        result = []
        for post in posts:
            try:
                post_data = post_schema.dump(post)
                
                # (1) 익명 처리 로직
                # is_anonymous가 True면 작성자 정보를 가립니다.
                if post.is_anonymous:
                    post_data['author'] = {"nickname": "익명"}
                    post_data['user_id'] = None
                    
                # (2) 미리보기(Preview) 텍스트 생성
                # 본문이 너무 길 경우, 홈 화면 카드에서는 앞부분만 보여주는 것이 효율적입니다.
                if len(post_data.get('content', '')) > 50:
                     post_data['preview'] = post_data['content'][:50] + "..."
                else:
                     post_data['preview'] = post_data.get('content', '')
                     
                result.append(post_data)
            except Exception as e:
                current_app.logger.error(f"Error serializing post {post.id}: {str(e)}")
                continue

        return jsonify(result), 200
    except Exception as e:
        current_app.logger.error(f"Get posts error: {str(e)}", exc_info=True)
        return jsonify({"error": f"Failed to get posts: {str(e)}"}), 500


@community_bp.route("/board/<int:board_id>/posts", methods=["POST"])
@require_auth # 글 작성은 로그인 필수
def create_post(board_id):
    """
    특정 게시판에 새 글 작성 API
    """
    try:
        # 1. 요청 데이터 확인
        data = request.json
        if not data:
            return jsonify({"error": "Request body is required"}), 400
            
        title = data.get("title")
        content = data.get("content")
        is_anonymous = data.get("is_anonymous", False)

        if not title or not content:
            return jsonify({"error": "Title and content are required"}), 400

        # Validate title and content length
        if len(title.strip()) == 0:
            return jsonify({"error": "Title cannot be empty"}), 400
        if len(content.strip()) == 0:
            return jsonify({"error": "Content cannot be empty"}), 400

        # 2. Validate board exists
        board = Boards.query.get(board_id)
        if not board:
            return jsonify({"error": f"Board with id {board_id} not found"}), 404

        # 3. 로그인한 사용자 정보 가져오기 (@require_auth 덕분)
        user = request.user

        # 4. DB 저장
        new_post = Posts(
            board_id=board_id,
            user_id=user.id,
            title=title.strip(),
            content=content.strip(),
            original_lang=user.main_language, # 작성자의 모국어 자동 저장
            is_anonymous=is_anonymous
        )
        
        db.session.add(new_post)
        db.session.commit()
        
        # 5. 결과 반환
        return post_schema.jsonify(new_post), 201
    except Exception as e:
        db.session.rollback()
        current_app.logger.error(f"Create post error: {str(e)}", exc_info=True)
        return jsonify({"error": f"Failed to create post: {str(e)}"}), 500


@community_bp.route("/translate", methods=["POST", "OPTIONS"])
def translate_text():
    # Handle OPTIONS preflight request
    if request.method == "OPTIONS":
        return jsonify({}), 200
    """
    Translate text to target language using MyMemory Translation API (free)
    
    Request body:
    {
        "text": "Text to translate",
        "target_language": "vi",  # Optional, defaults to user's language preference
        "source_language": "auto"  # Optional, defaults to "auto" (auto-detect)
    }
    
    Supported languages: en, ko, vi, zh, ja, my
    """
    try:
        data = request.json
        if not data:
            return jsonify({"error": "Request body is required"}), 400
        
        text = data.get("text", "").strip()
        if not text:
            return jsonify({"error": "Text to translate is required"}), 400
        
        # Get target language (default to 'en' if not provided)
        target_lang = data.get("target_language", "en")
        source_lang = data.get("source_language", "auto")
        
        # Map language codes to MyMemory format
        # MyMemory uses ISO 639-1 codes
        lang_map = {
            'en': 'en',
            'ko': 'ko',
            'vi': 'vi',
            'zh': 'zh',
            'ja': 'ja',
            'my': 'my',
        }
        
        # Validate target language
        if target_lang not in lang_map:
            return jsonify({"error": f"Unsupported target language: {target_lang}"}), 400
        
        target_lang_code = lang_map[target_lang]
        
        # Handle source language
        if source_lang == "auto":
            source_lang_code = "auto"
        else:
            source_lang_code = lang_map.get(source_lang, "auto")
        
        # MyMemory Translation API (free, no API key required for basic usage)
        # Limit: 1000 words per day for free tier
        api_url = "https://api.mymemory.translated.net/get"
        
        params = {
            'q': text,
            'langpair': f'{source_lang_code}|{target_lang_code}'
        }
        
        try:
            response = requests.get(api_url, params=params, timeout=10)
            response.raise_for_status()
            
            result = response.json()
            
            # Check if translation was successful
            if result.get('responseStatus') == 200:
                translated_text = result.get('responseData', {}).get('translatedText', text)
                
                return jsonify({
                    "translated_text": translated_text,
                    "source_language": source_lang_code,
                    "target_language": target_lang_code,
                    "original_text": text
                }), 200
            else:
                # Fallback: return original text if translation fails
                current_app.logger.warning(f"Translation API returned error: {result.get('responseStatus')}")
                return jsonify({
                    "translated_text": text,
                    "source_language": source_lang_code,
                    "target_language": target_lang_code,
                    "original_text": text,
                    "warning": "Translation service temporarily unavailable"
                }), 200
                
        except requests.exceptions.RequestException as e:
            current_app.logger.error(f"Translation API request error: {str(e)}", exc_info=True)
            # Fallback: return original text
            return jsonify({
                "translated_text": text,
                "source_language": source_lang_code,
                "target_language": target_lang_code,
                "original_text": text,
                "warning": "Translation service unavailable, showing original text"
            }), 200
            
    except Exception as e:
        current_app.logger.error(f"Translate text error: {str(e)}", exc_info=True)
        return jsonify({"error": f"Failed to translate text: {str(e)}"}), 500