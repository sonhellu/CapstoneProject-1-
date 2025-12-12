from flask import Blueprint, jsonify, request, current_app
from sqlalchemy.orm import joinedload
from ..database import db
from ..models import Users, Schools, Departments, Language, Country
from ..schemas import user_schema
from ..auth_utils import require_auth

profile_bp = Blueprint('profile_bp', __name__, url_prefix='/api/profile')

# --- 1. Get My Profile API ---
@profile_bp.route("/me", methods=["GET"])
@require_auth  # Login required
def get_my_profile():
    """
    Get logged-in user's profile information
    Returns profile with school name, department name, etc.
    """
    try:
        user = request.user
        # Eager load relationships to avoid lazy loading issues
        # Reload user with relationships to ensure they're available for serialization
        user_with_relations = Users.query.options(
            joinedload(Users.school),
            joinedload(Users.department)
        ).filter_by(id=user.id).first()
        
        if not user_with_relations:
            return jsonify({"error": "User not found"}), 404
        
        # user_schema includes nested information like school name, department name
        return user_schema.jsonify(user_with_relations), 200
    except Exception as e:
        current_app.logger.error(f"Error getting profile: {str(e)}", exc_info=True)
        return jsonify({"error": "Failed to retrieve profile", "details": str(e)}), 500

# --- 2. Get Other User Profile API ---
@profile_bp.route("/<int:user_id>", methods=["GET"])
def get_user_profile(user_id):
    """
    Get public profile information of a specific user (user_id)
    (Login not required, or weak authentication only)
    """
    try:
        user = Users.query.get(user_id)
        if not user:
            return jsonify({"error": "User not found"}), 404
        
        # Sensitive information (password_hash, etc.) is excluded from user_schema, so it's safe
        return user_schema.jsonify(user), 200
    except Exception as e:
        current_app.logger.error(f"Error getting user profile: {str(e)}", exc_info=True)
        return jsonify({"error": "Failed to retrieve user profile"}), 500

# --- 3. Update My Profile API ---
@profile_bp.route("/me", methods=["PUT"])
@require_auth  # Login required
def update_my_profile():
    """
    Update logged-in user's profile information
    """
    try:
        user = request.user
        data = request.json
        
        if not data:
            return jsonify({"error": "Request body is required"}), 400
        
        # 1. Update general fields (Frontend field name -> DB column name mapping)
        if 'username' in data or 'nickname' in data:  # UI: username/nickname -> DB: nickname
            nickname_raw = data.get('username') or data.get('nickname', '')
            nickname_value = str(nickname_raw).strip() if nickname_raw is not None else ''
            if not nickname_value:
                return jsonify({"error": "Nickname cannot be empty"}), 400
            if len(nickname_value) > 100:
                return jsonify({"error": "Nickname must be 100 characters or less"}), 400
            user.nickname = nickname_value
        
        if 'realname' in data or 'Full Name' in data or 'realName' in data:  # UI: Full Name/realName -> DB: realname
            realname_raw = data.get('realname') or data.get('Full Name') or data.get('realName', '')
            realname_value = str(realname_raw).strip() if realname_raw is not None else ''
            if not realname_value:
                return jsonify({"error": "Real name cannot be empty"}), 400
            if len(realname_value) > 100:
                return jsonify({"error": "Real name must be 100 characters or less"}), 400
            user.realname = realname_value
        
        if 'student_id' in data or 'studentId' in data:  # Student ID - optional
            student_id_raw = data.get('student_id') or data.get('studentId', '')
            if student_id_raw is not None:
                student_id = str(student_id_raw).strip()
                user.student_id = student_id if student_id else None
        
        if 'enrollment_year' in data or 'enrollmentYear' in data or 'Year' in data:  # UI: Year -> DB: enrollment_year
            year = data.get('enrollment_year') or data.get('enrollmentYear') or data.get('Year')
            if year:
                try:
                    user.enrollment_year = int(year)
                    if user.enrollment_year < 1900 or user.enrollment_year > 2100:
                        return jsonify({"error": "Invalid enrollment year"}), 400
                except (ValueError, TypeError):
                    return jsonify({"error": "enrollment_year must be a number"}), 400
        
        # 2. Update dropdown (foreign key) fields
        if 'school_id' in data or 'schoolId' in data:
            school_id = data.get('school_id') or data.get('schoolId')
            if school_id:
                try:
                    school_id = int(school_id)
                    # Validate school exists
                    if not Schools.query.get(school_id):
                        return jsonify({"error": f"School with id {school_id} not found"}), 400
                    user.school_id = school_id
                except (ValueError, TypeError):
                    return jsonify({"error": "school_id must be a number"}), 400
        
        if 'department_id' in data or 'departmentId' in data:  # Major
            department_id = data.get('department_id') or data.get('departmentId')
            if department_id:
                try:
                    department_id = int(department_id)
                    # Validate department exists
                    if not Departments.query.get(department_id):
                        return jsonify({"error": f"Department with id {department_id} not found"}), 400
                    user.department_id = department_id
                except (ValueError, TypeError):
                    return jsonify({"error": "department_id must be a number"}), 400
        
        if 'nationality_iso2' in data or 'nationalityIso2' in data:  # Nationality
            iso2_raw = data.get('nationality_iso2') or data.get('nationalityIso2', '')
            if iso2_raw is not None:
                iso2 = str(iso2_raw).strip().upper()
                if iso2:
                    # Validate country exists
                    if not Country.query.get(iso2):
                        return jsonify({"error": f"Country code '{iso2}' not found"}), 400
                    user.nationality_iso2 = iso2
        
        if 'main_language' in data or 'mainLanguage' in data:
            lang_code_raw = data.get('main_language') or data.get('mainLanguage', '')
            if lang_code_raw is not None:
                lang_code = str(lang_code_raw).strip()
                if lang_code:
                    # Validate language exists
                    if not Language.query.get(lang_code):
                        return jsonify({"error": f"Language code '{lang_code}' not found"}), 400
                    user.main_language = lang_code
        
        if 'gender' in data:
            gender = data['gender']
            if isinstance(gender, str):
                gender = gender.strip().lower()
            if gender not in ['male', 'female']:
                return jsonify({"error": "Gender must be 'male' or 'female'"}), 400
            user.gender = gender

        db.session.commit()
        # Reload user with relationships to ensure fresh data
        db.session.refresh(user)
        # Eager load relationships to ensure they're available for serialization
        user_with_relations = Users.query.options(
            joinedload(Users.school),
            joinedload(Users.department)
        ).filter_by(id=user.id).first()
        
        if not user_with_relations:
            return jsonify({"error": "User not found after update"}), 404
        
        # Return updated information to notify frontend that update was successful
        return user_schema.jsonify(user_with_relations), 200
    
    except Exception as e:
        db.session.rollback()
        current_app.logger.error(f"Profile update error: {str(e)}", exc_info=True)
        # Database constraint error (e.g., duplicate nickname) occurred
        return jsonify({"error": "Profile update failed", "details": str(e)}), 500

