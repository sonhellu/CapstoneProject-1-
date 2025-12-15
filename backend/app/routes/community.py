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
        
        # If no boards exist, try to seed them
        if not boards:
            current_app.logger.warning("No boards found, attempting to seed...")
            _ensure_boards_exist()
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


def _ensure_boards_exist():
    """Helper function to ensure boards exist in database"""
    try:
        from ..models import Communities, Schools, Country
        
        # Ensure school_id=1 exists
        school_1 = Schools.query.get(1)
        if not school_1:
            school_1 = Schools(id=1, school_name='Keimyung University', website_url='https://www.kmu.ac.kr')
            db.session.add(school_1)
            db.session.flush()
        
        # Ensure country 'KR' exists
        country_kr = Country.query.get('KR')
        if not country_kr:
            country_kr = Country(iso2='KR', name='South Korea')
            db.session.add(country_kr)
            db.session.flush()
        
        # Get or create default community
        default_community = Communities.query.filter_by(
            school_id=1,
            nationality_iso2='KR'
        ).first()
        
        if not default_community:
            default_community = Communities(
                school_id=1,
                community_name='Default Community',
                nationality_iso2='KR'
            )
            db.session.add(default_community)
            db.session.flush()
        
        # Create boards if they don't exist
        boards_data = [
            (1, '공지게시판', 'Notice Board', 1),
            (2, '자유게시판', 'Free Board', 2),
            (3, '정보게시판', 'Info Board', 3),
            (4, '홍보게시판', 'Promo Board', 4),
        ]
        
        for board_id, board_name_ko, board_name_en, order_idx in boards_data:
            existing_board = Boards.query.get(board_id)
            if not existing_board:
                board = Boards(
                    id=board_id,
                    community_id=default_community.id,
                    board_name=board_name_ko,
                    description=f'{board_name_en} - Community discussion board',
                    order_index=order_idx
                )
                db.session.add(board)
                current_app.logger.info(f"Created board {board_id}: {board_name_ko}")
        
        db.session.commit()
        current_app.logger.info("Boards seeding completed")
    except Exception as e:
        db.session.rollback()
        current_app.logger.error(f"Failed to seed boards: {str(e)}", exc_info=True)
        raise

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
        original_lang = data.get("original_lang")  # Ngôn ngữ được chọn từ frontend

        if not title or not content:
            return jsonify({"error": "Title and content are required"}), 400

        # Validate title and content length
        if len(title.strip()) == 0:
            return jsonify({"error": "Title cannot be empty"}), 400
        if len(content.strip()) == 0:
            return jsonify({"error": "Content cannot be empty"}), 400

        # 2. Validate board exists - if not, try to create it
        board = Boards.query.get(board_id)
        if not board:
            # Try to seed the board if it doesn't exist
            try:
                _ensure_boards_exist()
                board = Boards.query.get(board_id)
                if not board:
                    return jsonify({"error": f"Board with id {board_id} not found"}), 404
            except Exception as seed_error:
                current_app.logger.error(f"Failed to auto-create board: {str(seed_error)}", exc_info=True)
                return jsonify({"error": f"Board with id {board_id} not found"}), 404

        # 3. 로그인한 사용자 정보 가져오기 (@require_auth 덕분)
        user = request.user

        # 4. Validate và xác định original_lang
        # Nếu frontend gửi original_lang, dùng nó; nếu không, dùng main_language của user
        if original_lang:
            # Validate language code
            valid_languages = ['en', 'ko', 'vi', 'zh', 'ja', 'my']
            if original_lang not in valid_languages:
                return jsonify({"error": f"Invalid language code: {original_lang}"}), 400
            final_lang = original_lang
        else:
            # Fallback to user's main language
            final_lang = user.main_language

        # 5. DB 저장
        new_post = Posts(
            board_id=board_id,
            user_id=user.id,
            title=title.strip(),
            content=content.strip(),
            original_lang=final_lang,  # Sử dụng ngôn ngữ được chọn hoặc main_language
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


@community_bp.route("/posts/all", methods=["GET"])
def get_all_posts():
    """
    모든 게시판의 모든 글 목록 조회 API (News Tab용)
    
    [Query Parameters]
    - limit: 가져올 게시글의 개수 (기본값: 50)
    - original_lang: 필터링할 언어 코드 (선택적, 예: 'ko', 'en', 'vi')
    
    [사용 예시]
    GET /api/posts/all?limit=50
    GET /api/posts/all?limit=50&original_lang=vi
    """
    try:
        # 1. 쿼리 파라미터 받기 (limit, original_lang)
        try:
            limit = request.args.get('limit', default=50, type=int)
            if limit < 1 or limit > 200:
                limit = 50
        except (ValueError, TypeError):
            limit = 50
        
        original_lang = request.args.get('original_lang', type=str)
        
        # 2. DB 조회 - 모든 게시판의 글을 작성일(created_at) 역순(최신순)으로 정렬
        query = Posts.query
        
        # Filter theo original_lang nếu có
        if original_lang:
            query = query.filter_by(original_lang=original_lang)
        
        posts = query.order_by(Posts.created_at.desc()).limit(limit).all()
        
        # 3. 데이터 직렬화 (JSON 변환) 및 가공
        result = []
        for post in posts:
            try:
                post_data = post_schema.dump(post)
                
                # (1) 익명 처리 로직
                if post.is_anonymous:
                    post_data['author'] = {"nickname": "익명"}
                    post_data['user_id'] = None
                
                # (2) 미리보기(Preview) 텍스트 생성
                if len(post_data.get('content', '')) > 100:
                    post_data['preview'] = post_data['content'][:100] + "..."
                else:
                    post_data['preview'] = post_data.get('content', '')
                
                # (3) 게시판 정보 추가 (board_name)
                board = Boards.query.get(post.board_id)
                if board:
                    post_data['board_name'] = board.board_name
                
                result.append(post_data)
            except Exception as e:
                current_app.logger.error(f"Error serializing post {post.id}: {str(e)}")
                continue

        return jsonify(result), 200
    except Exception as e:
        current_app.logger.error(f"Get all posts error: {str(e)}", exc_info=True)
        return jsonify({"error": f"Failed to get all posts: {str(e)}"}), 500


@community_bp.route("/posts/<int:post_id>", methods=["DELETE", "OPTIONS"])
@require_auth
def delete_post(post_id):
    """
    Xóa bài viết (chỉ người tạo mới có thể xóa)
    
    [사용 예시]
    DELETE /api/posts/123
    """
    # Handle OPTIONS preflight request
    if request.method == "OPTIONS":
        return jsonify({}), 200
    
    try:
        # 1. Tìm bài viết
        post = Posts.query.get(post_id)
        if not post:
            return jsonify({"error": "Post not found"}), 404
        
        # 2. Kiểm tra quyền (chỉ người tạo mới có thể xóa)
        user = request.user
        if post.user_id != user.id:
            return jsonify({"error": "You can only delete your own posts"}), 403
        
        # 3. Xóa bài viết (soft delete hoặc hard delete)
        # Ở đây dùng hard delete, nếu muốn soft delete thì thêm field deleted_at
        db.session.delete(post)
        db.session.commit()
        
        # 4. Clear cache
        # Có thể clear cache cho board đó nếu cần
        
        return jsonify({"message": "Post deleted successfully"}), 200
    except Exception as e:
        db.session.rollback()
        current_app.logger.error(f"Delete post error: {str(e)}", exc_info=True)
        return jsonify({"error": f"Failed to delete post: {str(e)}"}), 500


@community_bp.route("/posts/<int:post_id>/translate", methods=["GET", "OPTIONS"])
@require_auth
def translate_post(post_id):
    """
    Tự động dịch bài viết dựa trên original_lang của bài viết và main_language của user
    
    [사용 예시]
    GET /api/posts/123/translate
    
    Response:
    {
        "title": "Translated title",
        "content": "Translated content",
        "original_lang": "ko",
        "target_lang": "vi"
    }
    """
    # Handle OPTIONS preflight request
    if request.method == "OPTIONS":
        return jsonify({}), 200
    
    try:
        # 1. Tìm bài viết
        post = Posts.query.get(post_id)
        if not post:
            return jsonify({"error": "Post not found"}), 404
        
        # 2. Lấy thông tin user - Query lại từ DB để đảm bảo có main_language mới nhất
        user_id = request.user.id
        from ..models import Users
        db_user = Users.query.get(user_id)
        if not db_user:
            return jsonify({"error": "User not found"}), 404
        
        # 3. Xác định source và target language
        # Thử detect language từ text nếu original_lang không có hoặc không chính xác
        if post.original_lang:
            source_lang = post.original_lang
        else:
            # Detect language từ title và content
            sample_text = (post.title or "") + " " + (post.content[:200] if post.content else "")
            source_lang = _detect_language(sample_text)
        
        target_lang = db_user.main_language or "en"  # Lấy từ DB, fallback to English if not set
        
        # Đảm bảo target_lang là lowercase và hợp lệ
        if target_lang:
            target_lang = target_lang.lower().strip()
        else:
            target_lang = "en"
        
        # Validate target language
        valid_target_languages = ['en', 'ko', 'vi', 'zh', 'ja', 'my']
        if target_lang not in valid_target_languages:
            current_app.logger.warning(f"Invalid target_lang '{target_lang}' from user {user_id}, defaulting to 'en'")
            target_lang = "en"
        
        current_app.logger.info(f"Translating post {post_id}: {source_lang} -> {target_lang} (user_id: {user_id}, main_language from DB: '{db_user.main_language}')")
        current_app.logger.info(f"Post title: {post.title[:50]}...")
        current_app.logger.info(f"Post content length: {len(post.content) if post.content else 0}")
        
        # 4. Nếu source và target giống nhau, không cần dịch
        if source_lang == target_lang:
            current_app.logger.info(f"Source and target languages are the same ({source_lang}), returning original")
            return jsonify({
                "title": post.title,
                "content": post.content,
                "original_lang": source_lang,
                "target_lang": target_lang,
                "message": "Source and target languages are the same"
            }), 200
        
        # 5. Dịch title và content
        translation_results = []
        texts_to_translate = [post.title, post.content]
        
        for idx, text in enumerate(texts_to_translate):
            if not text or len(text.strip()) == 0:
                current_app.logger.warning(f"Text {idx} (title=0, content=1) is empty, skipping translation")
                translation_results.append(text)
                continue
                
            try:
                # Gọi internal translate function
                current_app.logger.info(f"Translating text {idx} (title=0, content=1), length: {len(text)}")
                translation_result = _translate_text_internal(
                    text=text,
                    source_lang=source_lang,
                    target_lang=target_lang
                )
                translated_text = translation_result.get("translated_text", text)
                current_app.logger.info(f"Translation {idx} result length: {len(translated_text) if translated_text else 0}")
                translation_results.append(translated_text if translated_text else text)
            except Exception as e:
                current_app.logger.error(f"Translation failed for text {idx}: {str(e)}", exc_info=True)
                translation_results.append(text)  # Fallback to original text
        
        # Đảm bảo có đủ 2 kết quả (title và content)
        translated_title = translation_results[0] if len(translation_results) > 0 else post.title
        translated_content = translation_results[1] if len(translation_results) > 1 else post.content
        
        # Đảm bảo content không bao giờ là None
        if translated_content is None:
            translated_content = post.content or ""
        
        response_data = {
            "title": translated_title,
            "content": translated_content,
            "original_lang": source_lang,
            "target_lang": target_lang,
            "original_title": post.title,
            "original_content": post.content
        }
        
        current_app.logger.info(f"Translation complete. Title length: {len(str(response_data['title']))}, Content length: {len(str(response_data['content']))}")
        current_app.logger.info(f"Translated title preview: {str(translated_title)[:100]}...")
        current_app.logger.info(f"Translated content preview: {str(translated_content)[:100]}...")
        
        return jsonify(response_data), 200
        
    except Exception as e:
        current_app.logger.error(f"Translate post error: {str(e)}", exc_info=True)
        return jsonify({"error": f"Failed to translate post: {str(e)}"}), 500


def _detect_language(text):
    """
    Simple language detection based on character patterns
    Returns language code: 'ko', 'zh', 'ja', 'vi', 'en', 'my'
    """
    if not text or len(text.strip()) == 0:
        return "en"
    
    # Korean characters: Hangul syllable range (AC00-D7AF)
    korean_count = sum(1 for c in text if '\uAC00' <= c <= '\uD7AF')
    
    # Chinese characters: CJK Unified Ideographs (4E00-9FFF)
    chinese_count = sum(1 for c in text if '\u4E00' <= c <= '\u9FFF')
    
    # Japanese Hiragana (3040-309F) and Katakana (30A0-30FF)
    japanese_count = sum(1 for c in text if '\u3040' <= c <= '\u309F' or '\u30A0' <= c <= '\u30FF')
    
    # Myanmar characters (1000-109F)
    myanmar_count = sum(1 for c in text if '\u1000' <= c <= '\u109F')
    
    # Vietnamese: diacritics (Latin Extended Additional 1E00-1EFF)
    vietnamese_indicators = ['ă', 'â', 'ê', 'ô', 'ơ', 'ư', 'đ', 'à', 'á', 'ả', 'ã', 'ạ', 'è', 'é', 'ẻ', 'ẽ', 'ẹ']
    vietnamese_count = sum(1 for c in text.lower() if c in vietnamese_indicators)
    
    text_length = len(text)
    
    # Calculate ratios
    if text_length > 0:
        korean_ratio = korean_count / text_length
        chinese_ratio = chinese_count / text_length
        japanese_ratio = japanese_count / text_length
        myanmar_ratio = myanmar_count / text_length
        vietnamese_ratio = vietnamese_count / text_length
        
        # Determine language based on highest ratio
        if korean_ratio > 0.1:
            return "ko"
        elif chinese_ratio > 0.1:
            return "zh"
        elif japanese_ratio > 0.1:
            return "ja"
        elif myanmar_ratio > 0.1:
            return "my"
        elif vietnamese_ratio > 0.05:  # Lower threshold for Vietnamese
            return "vi"
    
    # Default to English if no clear indicators
    return "en"


def _translate_text_internal(text, source_lang, target_lang):
    """
    Helper function để dịch text (tái sử dụng logic từ translate_text route)
    Có auto-detect language: nếu translation từ source_lang fail, thử các source languages khác
    Hỗ trợ text dài bằng cách chia thành chunks và dịch từng chunk
    """
    # Map language codes to MyMemory format
    lang_map = {
        'en': 'en',
        'ko': 'ko',
        'vi': 'vi',
        'zh': 'zh',
        'ja': 'ja',
        'my': 'my',
    }
    
    # Validate languages
    if target_lang not in lang_map:
        raise ValueError(f"Unsupported target language: {target_lang}")
    if source_lang not in lang_map:
        raise ValueError(f"Unsupported source language: {source_lang}")
    
    source_lang_code = lang_map[source_lang]
    target_lang_code = lang_map[target_lang]
    
    # Don't translate if source and target are the same
    if source_lang_code == target_lang_code:
        return {
            "translated_text": text,
            "source_language": source_lang_code,
            "target_language": target_lang_code,
        }
    
    # Split long text into chunks and translate separately
    # LibreTranslate can handle longer chunks, but we split for reliability
    MAX_CHUNK_SIZE = 1000  # Increased for LibreTranslate (can handle up to ~2000 chars)
    text_length = len(text)
    
    if text_length <= MAX_CHUNK_SIZE:
        # Short text: translate directly
        return _translate_text_chunk(text, source_lang_code, target_lang_code, source_lang)
    else:
        # Long text: split into chunks and translate each
        current_app.logger.info(f"Text is long ({text_length} chars), splitting into chunks...")
        chunks = _split_text_into_chunks(text, MAX_CHUNK_SIZE)
        current_app.logger.info(f"Split into {len(chunks)} chunks")
        
        translated_chunks = []
        detected_source = source_lang_code
        
        for i, chunk in enumerate(chunks):
            current_app.logger.info(f"Translating chunk {i+1}/{len(chunks)} (length: {len(chunk)})")
            # Detect source language for this chunk if original is unclear
            chunk_source = source_lang_code
            if source_lang_code == "en" or not source_lang_code:  # If source is unclear, detect from chunk
                detected_lang = _detect_language(chunk)
                chunk_source = detected_lang
                current_app.logger.info(f"Detected language for chunk {i+1}: {detected_lang}")
            
            chunk_result = _translate_text_chunk(chunk, chunk_source, target_lang_code, source_lang)
            translated_chunks.append(chunk_result.get("translated_text", chunk))
            # Use detected source from first successful chunk
            if i == 0 and "source_language" in chunk_result:
                detected_source = chunk_result["source_language"]
        
        # Join all translated chunks
        translated_text = "".join(translated_chunks)
        
        return {
            "translated_text": translated_text,
            "source_language": detected_source,
            "target_language": target_lang_code,
        }


def _split_text_into_chunks(text, max_size):
    """
    Split text into chunks, trying to break at sentence boundaries when possible
    """
    if len(text) <= max_size:
        return [text]
    
    chunks = []
    current_chunk = ""
    
    # Try to split by newlines first (preserve paragraph structure)
    paragraphs = text.split('\n')
    
    for para in paragraphs:
        # If adding this paragraph would exceed limit, save current chunk and start new one
        if len(current_chunk) + len(para) + 1 > max_size and current_chunk:
            chunks.append(current_chunk)
            current_chunk = ""
        
        # If single paragraph is too long, split it by sentences
        if len(para) > max_size:
            # Split by sentence endings (Korean: . ! ? | Vietnamese: . ! ?)
            sentences = []
            current_sentence = ""
            
            for char in para:
                current_sentence += char
                if char in ['.', '!', '?', '。', '！', '？']:
                    if len(current_sentence) > max_size:
                        # Even sentence is too long, split by character
                        while len(current_sentence) > max_size:
                            chunks.append(current_sentence[:max_size])
                            current_sentence = current_sentence[max_size:]
                    sentences.append(current_sentence)
                    current_sentence = ""
            
            if current_sentence:
                sentences.append(current_sentence)
            
            # Add sentences to chunks
            for sentence in sentences:
                if len(current_chunk) + len(sentence) > max_size and current_chunk:
                    chunks.append(current_chunk)
                    current_chunk = ""
                current_chunk += sentence
        else:
            current_chunk += para
        
        # Add newline if not last paragraph
        if para != paragraphs[-1]:
            current_chunk += '\n'
    
    if current_chunk:
        chunks.append(current_chunk)
    
    return chunks


def _translate_text_chunk(chunk, source_lang_code, target_lang_code, original_source_lang):
    """
    Translate a single chunk of text using LibreTranslate (preferred) or MyMemory
    LibreTranslate handles longer text better than MyMemory
    """
    # List of source languages to try (start with provided source_lang, then try others)
    source_langs_to_try = [source_lang_code]
    # Add other common source languages to try if initial translation fails
    for lang in ['ko', 'en', 'vi', 'zh', 'ja', 'my']:
        if lang != source_lang_code and lang != target_lang_code:
            source_langs_to_try.append(lang)
    
    # Try LibreTranslate first (handles longer text better)
    libre_url = "https://libretranslate.de/translate"
    
    for try_source in source_langs_to_try:
        if try_source == target_lang_code:
            continue  # Skip if same as target
        
        try:
            current_app.logger.info(f"Trying LibreTranslate chunk: {try_source} -> {target_lang_code} (length: {len(chunk)})")
            libre_params = {
                'q': chunk,
                'source': try_source,
                'target': target_lang_code,
                'format': 'text'
            }
            
            libre_response = requests.post(libre_url, data=libre_params, timeout=20)
            if libre_response.status_code == 200:
                libre_result = libre_response.json()
                libre_translated = libre_result.get('translatedText', '').strip()
                current_app.logger.info(f"LibreTranslate response for {try_source}: translated length={len(libre_translated) if libre_translated else 0}, original length={len(chunk)}")
                
                if libre_translated and libre_translated != chunk and len(libre_translated) > 0:
                    current_app.logger.info(f"LibreTranslate successful with source: {try_source}")
                    return {
                        "translated_text": libre_translated,
                        "source_language": try_source,
                        "target_language": target_lang_code,
                    }
                else:
                    current_app.logger.warning(f"LibreTranslate returned same text or empty for {try_source}")
            else:
                current_app.logger.warning(f"LibreTranslate returned status {libre_response.status_code} for {try_source}")
        except requests.exceptions.RequestException as e:
            current_app.logger.warning(f"LibreTranslate request error for {try_source}: {str(e)}")
            # Continue to try MyMemory
            
        # Try MyMemory as fallback
        try:
            current_app.logger.info(f"Trying MyMemory for {try_source} -> {target_lang_code}")
            api_url = "https://api.mymemory.translated.net/get"
            params = {
                'q': chunk,
                'langpair': f'{try_source}|{target_lang_code}'
            }
            
            response = requests.get(api_url, params=params, timeout=15)
            response.raise_for_status()
            
            result = response.json()
            response_status = result.get('responseStatus', 0)
            
            if response_status == 200:
                translated_text = result.get('responseData', {}).get('translatedText', '').strip()
                current_app.logger.info(f"MyMemory response for {try_source}: translated length={len(translated_text) if translated_text else 0}")
                
                if translated_text and translated_text != chunk and len(translated_text) > 0:
                    current_app.logger.info(f"MyMemory successful with source: {try_source}")
                    return {
                        "translated_text": translated_text,
                        "source_language": try_source,
                        "target_language": target_lang_code,
                    }
        except requests.exceptions.RequestException as e:
            current_app.logger.warning(f"MyMemory request error for {try_source}: {str(e)}")
            continue  # Try next source language
    
    # All translation attempts failed for this chunk
    current_app.logger.error(f"All translation attempts failed for chunk (length: {len(chunk)}, source: {source_lang_code}, target: {target_lang_code})")
    current_app.logger.error(f"Chunk preview: {chunk[:100]}...")
    return {
        "translated_text": chunk,
        "source_language": source_lang_code,
        "target_language": target_lang_code,
        "warning": "Could not translate chunk - all translation services failed"
    }


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
        
        # Handle source language - MyMemory doesn't support "auto" well
        # We need to detect or guess the source language
        if source_lang == "auto":
            # Simple heuristic: if target is not English, assume source might be English or Korean
            # In production, use a proper language detection service
            # For now, try English first, then Korean if that doesn't work
            source_lang_code = "en" if target_lang_code != "en" else "ko"
        else:
            source_lang_code = lang_map.get(source_lang, "en")
        
        # Don't translate if source and target are the same
        if source_lang_code == target_lang_code:
            return jsonify({
                "translated_text": text,
                "source_language": source_lang_code,
                "target_language": target_lang_code,
                "original_text": text,
                "warning": "Source and target languages are the same"
            }), 200
        
        # MyMemory Translation API (free, no API key required for basic usage)
        # Limit: 1000 words per day for free tier
        api_url = "https://api.mymemory.translated.net/get"
        
        # Try multiple source languages if auto-detect is needed
        source_languages_to_try = [source_lang_code]
        if source_lang == "auto":
            # Try common source languages for this app
            if target_lang_code == "vi":
                source_languages_to_try = ["en", "ko", "zh", "ja"]
            elif target_lang_code == "ko":
                source_languages_to_try = ["en", "vi", "zh", "ja"]
            elif target_lang_code == "en":
                source_languages_to_try = ["ko", "vi", "zh", "ja"]
            else:
                source_languages_to_try = ["en", "ko"]
        
        # Try each source language until we get a good translation
        for try_source in source_languages_to_try:
            if try_source == target_lang_code:
                continue  # Skip if same as target
                
            params = {
                'q': text,
                'langpair': f'{try_source}|{target_lang_code}'
            }
            
            try:
                current_app.logger.info(f"Trying translation: {try_source} -> {target_lang_code}")
                response = requests.get(api_url, params=params, timeout=10)
                response.raise_for_status()
                
                result = response.json()
                response_status = result.get('responseStatus', 0)
                
                current_app.logger.info(f"MyMemory API response status: {response_status}")
            
                if response_status == 200:
                    translated_text = result.get('responseData', {}).get('translatedText', '').strip()
                    
                    current_app.logger.info(f"Translated text: {translated_text[:100] if translated_text else 'empty'}...")
                    
                    # Check if translation is actually different from original
                    if translated_text and translated_text != text:
                        current_app.logger.info(f"Translation successful with source: {try_source}")
                        return jsonify({
                            "translated_text": translated_text,
                            "source_language": try_source,  # Use the successful source
                            "target_language": target_lang_code,
                            "original_text": text
                        }), 200
                    else:
                        current_app.logger.warning(f"Translation returned same text for {try_source}, trying next...")
                        continue  # Try next source language
                else:
                    current_app.logger.warning(f"Translation failed for {try_source} (status: {response_status}), trying next...")
                    continue  # Try next source language
                    
            except requests.exceptions.RequestException as e:
                current_app.logger.warning(f"Request failed for {try_source}: {str(e)}, trying next...")
                continue  # Try next source language
        
        # If all source languages failed, try LibreTranslate as fallback
        current_app.logger.error(f"All MyMemory translation attempts failed for text: {text[:50]}...")
        
        # Try LibreTranslate as fallback
        try:
            current_app.logger.info("Trying LibreTranslate as fallback...")
            libre_url = "https://libretranslate.de/translate"
            # Try with first source language from our list
            fallback_source = source_languages_to_try[0] if source_languages_to_try else "en"
            libre_params = {
                'q': text,
                'source': fallback_source,
                'target': target_lang_code,
                'format': 'text'
            }
            
            libre_response = requests.post(libre_url, data=libre_params, timeout=10)
            if libre_response.status_code == 200:
                libre_result = libre_response.json()
                libre_translated = libre_result.get('translatedText', '').strip()
                if libre_translated and libre_translated != text:
                    current_app.logger.info("LibreTranslate translation successful")
                    return jsonify({
                        "translated_text": libre_translated,
                        "source_language": fallback_source,
                        "target_language": target_lang_code,
                        "original_text": text
                    }), 200
        except Exception as libre_error:
            current_app.logger.warning(f"LibreTranslate fallback also failed: {str(libre_error)}")
        
        # Final fallback: return original text with warning
        return jsonify({
            "translated_text": text,
            "source_language": source_languages_to_try[0] if source_languages_to_try else "en",  # Use actual code, not "auto"
            "target_language": target_lang_code,
            "original_text": text,
            "warning": "Could not translate - all translation services unavailable or text may already be in target language"
        }), 200
                
    except requests.exceptions.RequestException as e:
            current_app.logger.error(f"Translation API request error: {str(e)}", exc_info=True)
            
            # Try alternative translation service (LibreTranslate) as fallback
            try:
                current_app.logger.info("Trying LibreTranslate as fallback...")
                libre_url = "https://libretranslate.de/translate"
                libre_params = {
                    'q': text,
                    'source': source_lang_code,
                    'target': target_lang_code,
                    'format': 'text'
                }
                
                libre_response = requests.post(libre_url, data=libre_params, timeout=10)
                if libre_response.status_code == 200:
                    libre_result = libre_response.json()
                    libre_translated = libre_result.get('translatedText', '').strip()
                    if libre_translated and libre_translated != text:
                        current_app.logger.info("LibreTranslate translation successful")
                        return jsonify({
                            "translated_text": libre_translated,
                            "source_language": source_lang_code,
                            "target_language": target_lang_code,
                            "original_text": text
                        }), 200
            except Exception as libre_error:
                current_app.logger.warning(f"LibreTranslate fallback also failed: {str(libre_error)}")
            
            # Final fallback: return original text
            return jsonify({
                "translated_text": text,
                "source_language": source_lang_code,  # Use actual code, not "auto"
                "target_language": target_lang_code,
                "original_text": text,
                "warning": "Translation service unavailable, showing original text"
            }), 200
            
    except Exception as e:
        current_app.logger.error(f"Translate text error: {str(e)}", exc_info=True)
        return jsonify({"error": f"Failed to translate text: {str(e)}"}), 500