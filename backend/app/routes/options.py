from flask import Blueprint, jsonify, request, current_app
from ..models import Schools, Departments, Language, Country, Colleges
from ..database import db

options_bp = Blueprint('options_bp', __name__, url_prefix='/api/options')

@options_bp.route("/schools", methods=["GET"])
def get_schools():
    """Get list of all schools for registration dropdown"""
    try:
        schools = Schools.query.order_by(Schools.school_name).all()
        
        result = [
            {
                'id': school.id,
                'name': school.school_name,
                'website_url': school.website_url
            }
            for school in schools
        ]
        
        return jsonify({
            'schools': result,
            'count': len(result)
        }), 200
    
    except Exception as e:
        current_app.logger.error(f"Get schools error: {str(e)}", exc_info=True)
        return jsonify({"error": f"Failed to get schools: {str(e)}"}), 500

@options_bp.route("/departments", methods=["GET"])
def get_departments():
    """Get list of departments filtered by school_id"""
    try:
        school_id = request.args.get('school_id', type=int)
        
        if not school_id:
            return jsonify({"error": "school_id parameter is required"}), 400
        
        # Get all departments for the school
        departments = Departments.query.filter_by(school_id=school_id).order_by(Departments.department_name).all()
        
        result = [
            {
                'id': dept.id,
                'name': dept.department_name,
                'school_id': dept.school_id,
                'college_id': dept.college_id,
                'college_name': dept.college.college_name if dept.college else None
            }
            for dept in departments
        ]
        
        return jsonify({
            'departments': result,
            'count': len(result),
            'school_id': school_id
        }), 200
    
    except Exception as e:
        current_app.logger.error(f"Get departments error: {str(e)}", exc_info=True)
        return jsonify({"error": f"Failed to get departments: {str(e)}"}), 500

@options_bp.route("/languages", methods=["GET"])
def get_languages():
    """Get list of all languages for registration dropdown"""
    try:
        languages = Language.query.order_by(Language.name).all()
        
        result = [
            {
                'code': lang.code,
                'name': lang.name,
                'native_name': lang.native_name
            }
            for lang in languages
        ]
        
        return jsonify({
            'languages': result,
            'count': len(result)
        }), 200
    
    except Exception as e:
        current_app.logger.error(f"Get languages error: {str(e)}", exc_info=True)
        return jsonify({"error": f"Failed to get languages: {str(e)}"}), 500

@options_bp.route("/countries", methods=["GET"])
def get_countries():
    """Get list of all countries for registration dropdown"""
    try:
        countries = Country.query.order_by(Country.name).all()
        
        result = [
            {
                'iso2': country.iso2,
                'name': country.name
            }
            for country in countries
        ]
        
        return jsonify({
            'countries': result,
            'count': len(result)
        }), 200
    
    except Exception as e:
        current_app.logger.error(f"Get countries error: {str(e)}", exc_info=True)
        return jsonify({"error": f"Failed to get countries: {str(e)}"}), 500

@options_bp.route("/colleges", methods=["GET"])
def get_colleges():
    """Get list of colleges filtered by school_id"""
    try:
        school_id = request.args.get('school_id', type=int)
        
        if not school_id:
            return jsonify({"error": "school_id parameter is required"}), 400
        
        colleges = Colleges.query.filter_by(school_id=school_id).order_by(Colleges.college_name).all()
        
        result = [
            {
                'id': college.id,
                'name': college.college_name,
                'school_id': college.school_id
            }
            for college in colleges
        ]
        
        return jsonify({
            'colleges': result,
            'count': len(result),
            'school_id': school_id
        }), 200
    
    except Exception as e:
        current_app.logger.error(f"Get colleges error: {str(e)}", exc_info=True)
        return jsonify({"error": f"Failed to get colleges: {str(e)}"}), 500

