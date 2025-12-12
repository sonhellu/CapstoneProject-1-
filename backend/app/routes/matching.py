from flask import Blueprint, jsonify, request, current_app
from ..models import (db, Users, Departments, HelperProfiles, HelperLanguages, 
                       MatchRequests, Matches, Conversations, ConversationParticipants, Messages)
from ..auth_utils import require_auth

matching_bp = Blueprint('matching_bp', __name__, url_prefix='/api')

# 1) 매칭 요청 생성
@matching_bp.route("/match_requests", methods=["POST"])
@require_auth # 로그인 필수
def create_match_request():
    try:
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
    except Exception as e:
        db.session.rollback()
        current_app.logger.error(f"Create match request error: {str(e)}", exc_info=True)
        return jsonify({"error": f"Failed to create match request: {str(e)}"}), 500


# 2) 도우미 후보 검색 (오류 수정됨)
@matching_bp.route("/match_requests/<int:request_id>/find_helpers", methods=["GET"])
@require_auth 
def find_helpers_for_request(request_id):
    try:
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

        try:
            limit = int(request.args.get("limit", 10))
            if limit < 1 or limit > 100:
                limit = 10
        except (ValueError, TypeError):
            limit = 10
            
        helpers = q.limit(limit).all()
        
        results = [{"id": h.id, "nickname": h.nickname} for h in helpers]
        return jsonify(results), 200
    except Exception as e:
        current_app.logger.error(f"Find helpers error: {str(e)}", exc_info=True)
        return jsonify({"error": f"Failed to find helpers: {str(e)}"}), 500


# 3) 매칭 제안(offer) 생성
@matching_bp.route("/match_requests/<int:request_id>/offer", methods=["POST"])
@require_auth
def offer_match(request_id):
    try:
        data = request.json or {}
        mentor_user_id = data.get("mentor_user_id")
        if not mentor_user_id:
            return jsonify({"error": "mentor_user_id required"}), 400

        mr = MatchRequests.query.get(request_id)
        if not mr:
            return jsonify({"error": "request not found"}), 404
        
        # Validate mentor_user_id exists and is a helper
        mentor = Users.query.get(mentor_user_id)
        if not mentor:
            return jsonify({"error": "Mentor user not found"}), 404
        if not mentor.is_helper:
            return jsonify({"error": "Mentor must be a helper"}), 400
        
        mr.status = "offered"
        db.session.commit()
        return jsonify({"request_id": mr.id, "status": mr.status, "offered_to": mentor_user_id}), 200
    except Exception as e:
        db.session.rollback()
        current_app.logger.error(f"Offer match error: {str(e)}", exc_info=True)
        return jsonify({"error": f"Failed to offer match: {str(e)}"}), 500


# 4) 매칭 수락 및 대화방 생성
@matching_bp.route("/match_requests/<int:request_id>/accept", methods=["POST"])
@require_auth 
def accept_match(request_id):
    try:
        mr = MatchRequests.query.get(request_id)
        if not mr:
            return jsonify({"error": "request not found"}), 404
        if mr.status != 'offered':
            return jsonify({"error": "invalid request status, must be 'offered'"}), 400

        data = request.json or {}
        mentor_user_id = data.get("mentor_user_id")
        if not mentor_user_id:
             return jsonify({"error": "mentor_user_id required for accept"}), 400

        # Validate mentor_user_id exists and is a helper
        mentor = Users.query.get(mentor_user_id)
        if not mentor:
            return jsonify({"error": "Mentor user not found"}), 404
        if not mentor.is_helper:
            return jsonify({"error": "Mentor must be a helper"}), 400

        # Get requester to access school_id
        requester = Users.query.get(mr.requester_user_id)
        if not requester:
            return jsonify({"error": "Requester user not found"}), 404

        # Use transaction for all operations
        match = Matches(
            mentor_user_id=mentor_user_id,
            mentee_user_id=mr.requester_user_id,
            school_id=requester.school_id,  # Fixed: use requester instead of mr.requester
            request_id=mr.id,
            status='active'
        )
        db.session.add(match)
        
        mr.status = 'accepted'
        
        conv = Conversations(match_id=match.id)
        db.session.add(conv)
        
        p1 = ConversationParticipants(conversation_id=conv.id, user_id=mentor_user_id)
        p2 = ConversationParticipants(conversation_id=conv.id, user_id=mr.requester_user_id)
        db.session.add_all([p1, p2])
        
        # Single commit for all operations
        db.session.commit()

        return jsonify({"match_id": match.id, "conversation_id": conv.id}), 201
    except Exception as e:
        db.session.rollback()
        current_app.logger.error(f"Accept match error: {str(e)}", exc_info=True)
        return jsonify({"error": f"Failed to accept match: {str(e)}"}), 500


# 5) 메시지 전송
@matching_bp.route("/conversations/<int:conv_id>/messages", methods=["POST"])
@require_auth
def send_message(conv_id):
    try:
        user = request.user
        data = request.json or {}
        content = data.get("content")
        if not content:
            return jsonify({"error": "content required"}), 400

        # Validate content length
        if len(content.strip()) == 0:
            return jsonify({"error": "content cannot be empty"}), 400

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
    except Exception as e:
        db.session.rollback()
        current_app.logger.error(f"Send message error: {str(e)}", exc_info=True)
        return jsonify({"error": f"Failed to send message: {str(e)}"}), 500


# 6) 대화 메시지 조회 (개선: sender 정보 포함)
@matching_bp.route("/conversations/<int:conv_id>/messages", methods=["GET"])
@require_auth
def get_messages(conv_id):
    try:
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
        
        # Include sender information
        out = []
        for m in msgs:
            sender = Users.query.get(m.sender_user_id)
            out.append({
                "id": m.id,
                "sender_user_id": m.sender_user_id,
                "sender_nickname": sender.nickname if sender else "Unknown",
                "content": m.content,
                "created_at": m.created_at.isoformat(),
                "is_sent_by_me": m.sender_user_id == user.id
            })
        
        return jsonify(out), 200
    except Exception as e:
        current_app.logger.error(f"Get messages error: {str(e)}", exc_info=True)
        return jsonify({"error": f"Failed to get messages: {str(e)}"}), 500


# 7) 사용자의 모든 대화 목록 조회
@matching_bp.route("/conversations", methods=["GET"])
@require_auth
def get_conversations():
    """Get all conversations for the logged-in user with last message and unread count"""
    try:
        user = request.user
        
        # Get all conversations where user is a participant
        participants = ConversationParticipants.query.filter_by(user_id=user.id).all()
        conversation_ids = [p.conversation_id for p in participants]
        
        if not conversation_ids:
            return jsonify([]), 200
        
        conversations = Conversations.query.filter(Conversations.id.in_(conversation_ids)).all()
        
        result = []
        for conv in conversations:
            # Get the other participant (not the current user)
            other_participant = ConversationParticipants.query.filter(
                ConversationParticipants.conversation_id == conv.id,
                ConversationParticipants.user_id != user.id
            ).first()
            
            if not other_participant:
                continue
            
            other_user = Users.query.get(other_participant.user_id)
            if not other_user:
                continue
            
            # Get last message
            last_message = Messages.query.filter_by(conversation_id=conv.id)\
                                         .order_by(Messages.created_at.desc())\
                                         .first()
            
            # Get unread count (messages after last_read_at)
            current_participant = ConversationParticipants.query.filter_by(
                conversation_id=conv.id,
                user_id=user.id
            ).first()
            
            unread_count = 0
            if current_participant and current_participant.last_read_at:
                unread_count = Messages.query.filter(
                    Messages.conversation_id == conv.id,
                    Messages.sender_user_id != user.id,
                    Messages.created_at > current_participant.last_read_at
                ).count()
            elif current_participant:
                # If never read, count all messages from others
                unread_count = Messages.query.filter(
                    Messages.conversation_id == conv.id,
                    Messages.sender_user_id != user.id
                ).count()
            
            result.append({
                "id": conv.id,
                "match_id": conv.match_id,
                "other_user": {
                    "id": other_user.id,
                    "nickname": other_user.nickname,
                    "realname": other_user.realname,
                },
                "last_message": {
                    "id": last_message.id,
                    "content": last_message.content,
                    "sender_user_id": last_message.sender_user_id,
                    "created_at": last_message.created_at.isoformat() if last_message else None
                } if last_message else None,
                "unread_count": unread_count,
                "created_at": conv.created_at.isoformat()
            })
        
        # Sort by last message time (most recent first)
        result.sort(key=lambda x: (
            x["last_message"]["created_at"] if x["last_message"] else x["created_at"]
        ), reverse=True)
        
        return jsonify(result), 200
    except Exception as e:
        current_app.logger.error(f"Get conversations error: {str(e)}", exc_info=True)
        return jsonify({"error": f"Failed to get conversations: {str(e)}"}), 500


# 8) 대화 읽음 표시
@matching_bp.route("/conversations/<int:conv_id>/read", methods=["PUT"])
@require_auth
def mark_conversation_read(conv_id):
    """Mark all messages in conversation as read by updating last_read_at"""
    try:
        user = request.user
        
        participant = ConversationParticipants.query.filter_by(
            conversation_id=conv_id,
            user_id=user.id
        ).first()
        
        if not participant:
            return jsonify({"error": "You are not a participant in this conversation"}), 403
        
        # Update last_read_at to current time
        from datetime import datetime
        participant.last_read_at = datetime.utcnow()
        db.session.commit()
        
        return jsonify({
            "conversation_id": conv_id,
            "last_read_at": participant.last_read_at.isoformat()
        }), 200
    except Exception as e:
        db.session.rollback()
        current_app.logger.error(f"Mark conversation read error: {str(e)}", exc_info=True)
        return jsonify({"error": f"Failed to mark conversation as read: {str(e)}"}), 500