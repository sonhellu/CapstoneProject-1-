from flask import Blueprint, jsonify, request
from ..models import (db, Users, Departments, HelperProfiles, HelperLanguages, 
                       MatchRequests, Matches, Conversations, ConversationParticipants, Messages)
from ..auth_utils import require_auth

matching_bp = Blueprint('matching_bp', __name__, url_prefix='/api')

# 1) 매칭 요청 생성
@matching_bp.route("/match_requests", methods=["POST"])
@require_auth # 로그인 필수
def create_match_request():
    data = request.json or {}
    user = request.user 
    
    if user.is_helper:
        return jsonify({"error": "Helpers (Koreans) cannot request matching"}), 403
    
    existing_request = MatchRequests.query.filter_by(
        requester_user_id=user.id, 
        status='pending'
    ).first()
    
    if existing_request:
        return jsonify({"error": "You already have a pending match request"}), 409

    mr = MatchRequests(
        requester_user_id=user.id,
        preferred_college_id=data.get("preferred_college_id"),
        preferred_gender=data.get("preferred_gender", "any"),
        notes=data.get("notes"),
        status="pending"
    )
    db.session.add(mr)
    db.session.commit()
    return jsonify({"id": mr.id, "status": mr.status}), 201


# 2) 도우미 후보 검색 (오류 수정됨)
@matching_bp.route("/match_requests/<int:request_id>/find_helpers", methods=["GET"])
@require_auth 
def find_helpers_for_request(request_id):
    mr = MatchRequests.query.get(request_id)
    if not mr:
        return jsonify({"error": "request not found"}), 404

    requester = Users.query.get(mr.requester_user_id)
    requester_lang = requester.main_language if requester else None
    
    q = db.session.query(Users).join(HelperProfiles, HelperProfiles.user_id == Users.id)
    q = q.filter(Users.is_helper == True)
    
    if requester_lang:
        q = q.join(HelperLanguages, HelperLanguages.user_id == Users.id)
        q = q.filter(HelperLanguages.language_code == requester_lang)

    if mr.preferred_gender and mr.preferred_gender != "any":
        q = q.filter(Users.gender == mr.preferred_gender)

    if mr.preferred_college_id:
        q = q.join(Departments, Users.department_id == Departments.id)
        q = q.filter(Departments.college_id == mr.preferred_college_id)

    limit = int(request.args.get("limit", 10))
    helpers = q.limit(limit).all()
    
    results = [{"id": h.id, "nickname": h.nickname} for h in helpers]
    return jsonify(results), 200


# 3) 매칭 제안(offer) 생성
@matching_bp.route("/match_requests/<int:request_id>/offer", methods=["POST"])
@require_auth
def offer_match(request_id):
    data = request.json or {}
    mentor_user_id = data.get("mentor_user_id")
    if not mentor_user_id:
        return jsonify({"error": "mentor_user_id required"}), 400

    mr = MatchRequests.query.get(request_id)
    if not mr:
        return jsonify({"error": "request not found"}), 404
    
    mr.status = "offered"
    db.session.commit()
    return jsonify({"request_id": mr.id, "status": mr.status, "offered_to": mentor_user_id}), 200


# 4) 매칭 수락 및 대화방 생성
@matching_bp.route("/match_requests/<int:request_id>/accept", methods=["POST"])
@require_auth 
def accept_match(request_id):
    mr = MatchRequests.query.get(request_id)
    if not mr:
        return jsonify({"error": "request not found"}), 404
    if mr.status != 'offered':
        return jsonify({"error": "invalid request status, must be 'offered'"}), 400

    data = request.json or {}
    mentor_user_id = data.get("mentor_user_id")
    if not mentor_user_id:
         return jsonify({"error": "mentor_user_id required for accept"}), 400

    match = Matches(
        mentor_user_id=mentor_user_id,
        mentee_user_id=mr.requester_user_id,
        school_id=mr.requester.school_id, 
        request_id=mr.id,
        status='active'
    )
    db.session.add(match)
    
    mr.status = 'accepted'
    db.session.commit() 

    conv = Conversations(match_id=match.id)
    db.session.add(conv)
    db.session.commit() 

    p1 = ConversationParticipants(conversation_id=conv.id, user_id=mentor_user_id)
    p2 = ConversationParticipants(conversation_id=conv.id, user_id=mr.requester_user_id)
    db.session.add_all([p1, p2])
    
    db.session.commit()

    return jsonify({"match_id": match.id, "conversation_id": conv.id}), 201


# 5) 메시지 전송
@matching_bp.route("/conversations/<int:conv_id>/messages", methods=["POST"])
@require_auth
def send_message(conv_id):
    user = request.user
    data = request.json or {}
    content = data.get("content")
    if not content:
        return jsonify({"error": "content required"}), 400

    participant = ConversationParticipants.query.filter_by(
        conversation_id=conv_id, 
        user_id=user.id
    ).first()
    
    if not participant:
        return jsonify({"error": "You are not a participant in this conversation"}), 403

    msg = Messages(
        conversation_id=conv_id, 
        sender_user_id=user.id, 
        content=content
    )
    db.session.add(msg)
    db.session.commit()
    
    return jsonify({"message_id": msg.id, "created_at": msg.created_at.isoformat()}), 201


# 6) 대화 메시지 조회
@matching_bp.route("/conversations/<int:conv_id>/messages", methods=["GET"])
@require_auth
def get_messages(conv_id):
    user = request.user
    
    participant = ConversationParticipants.query.filter_by(
        conversation_id=conv_id, 
        user_id=user.id
    ).first()
    if not participant:
        return jsonify({"error": "You are not a participant in this conversation"}), 403

    msgs = Messages.query.filter_by(conversation_id=conv_id)\
                         .order_by(Messages.created_at.asc())\
                         .all()
    
    out = [{"id": m.id, "sender_user_id": m.sender_user_id, "content": m.content,
            "created_at": m.created_at.isoformat()} for m in msgs]
    
    return jsonify(out), 200