from flask import Blueprint, jsonify, request
from ..models import db, Boards, Posts
from ..schemas import post_schema, posts_schema
from ..auth_utils import require_auth

community_bp = Blueprint('community_bp', __name__, url_prefix='/api')

@community_bp.route("/board/<int:board_id>/posts", methods=["GET"])
def get_posts(board_id):
    """특정 게시판의 글 목록 조회 (최신순 20개)"""
    
    if not Boards.query.get(board_id):
        return jsonify({"error": "Board not found"}), 404

    posts = Posts.query.filter_by(board_id=board_id)\
                       .order_by(Posts.created_at.desc())\
                       .limit(20)\
                       .all()
    
    # 익명 처리
    result = []
    for post in posts:
        post_data = post_schema.dump(post)
        if post.is_anonymous:
            post_data['author'] = {"nickname": "익명"}
            post_data['user_id'] = None
        result.append(post_data)

    return jsonify(result), 200


@community_bp.route("/board/<int:board_id>/posts", methods=["POST"])
@require_auth # 로그인 필수
def create_post(board_id):
    """특정 게시판에 새 글 작성"""
    data = request.json
    title = data.get("title")
    content = data.get("content")
    is_anonymous = data.get("is_anonymous", False)

    if not title or not content:
        return jsonify({"error": "Title and content are required"}), 400

    user = request.user

    new_post = Posts(
        board_id=board_id,
        user_id=user.id,
        title=title,
        content=content,
        original_lang=user.main_language,
        is_anonymous=is_anonymous
    )
    
    db.session.add(new_post)
    db.session.commit()
    
    return post_schema.jsonify(new_post), 201