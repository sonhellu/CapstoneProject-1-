from flask import Blueprint, jsonify, request
from ..models import db, Boards, Posts
from ..schemas import post_schema, posts_schema
from ..auth_utils import require_auth

community_bp = Blueprint('community_bp', __name__, url_prefix='/api')

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
    
    # 1. 쿼리 파라미터 받기 (limit)
    # URL 뒤에 ?limit=5 가 있으면 5를, 없으면 기본값 20을 사용
    limit = request.args.get('limit', default=20, type=int)
    
    # 2. 게시판 존재 여부 확인
    if not Boards.query.get(board_id):
        return jsonify({"error": "Board not found"}), 404

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
        post_data = post_schema.dump(post)
        
        # (1) 익명 처리 로직
        # is_anonymous가 True면 작성자 정보를 가립니다.
        if post.is_anonymous:
            post_data['author'] = {"nickname": "익명"}
            post_data['user_id'] = None
            
        # (2) 미리보기(Preview) 텍스트 생성
        # 본문이 너무 길 경우, 홈 화면 카드에서는 앞부분만 보여주는 것이 효율적입니다.
        if len(post_data['content']) > 50:
             post_data['preview'] = post_data['content'][:50] + "..."
        else:
             post_data['preview'] = post_data['content']
             
        result.append(post_data)

    return jsonify(result), 200


@community_bp.route("/board/<int:board_id>/posts", methods=["POST"])
@require_auth # 글 작성은 로그인 필수
def create_post(board_id):
    """
    특정 게시판에 새 글 작성 API
    """
    # 1. 요청 데이터 확인
    data = request.json
    title = data.get("title")
    content = data.get("content")
    is_anonymous = data.get("is_anonymous", False)

    if not title or not content:
        return jsonify({"error": "Title and content are required"}), 400

    # 2. 로그인한 사용자 정보 가져오기 (@require_auth 덕분)
    user = request.user

    # 3. DB 저장
    new_post = Posts(
        board_id=board_id,
        user_id=user.id,
        title=title,
        content=content,
        original_lang=user.main_language, # 작성자의 모국어 자동 저장
        is_anonymous=is_anonymous
    )
    
    db.session.add(new_post)
    db.session.commit()
    
    # 4. 결과 반환
    return post_schema.jsonify(new_post), 201