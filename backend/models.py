from .database import db
from datetime import datetime

class Language(db.Model):
    __tablename__ = "language"
    code = db.Column(db.String(10), primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    native_name = db.Column(db.String(100), nullable=False)

class Country(db.Model):
    __tablename__ = "country"
    iso2 = db.Column(db.CHAR(2), primary_key=True)
    name = db.Column(db.String(100), nullable=False)

class Schools(db.Model):
    __tablename__ = "schools"
    id = db.Column(db.BigInteger, primary_key=True, autoincrement=True)
    school_name = db.Column(db.String(200), nullable=False)
    website_url = db.Column(db.String(255), nullable=True)

class Colleges(db.Model):
    __tablename__ = "colleges"
    id = db.Column(db.BigInteger, primary_key=True, autoincrement=True)
    school_id = db.Column(db.BigInteger, db.ForeignKey('schools.id'), nullable=False)
    college_name = db.Column(db.String(200), nullable=False)

class Departments(db.Model):
    __tablename__ = "departments"
    id = db.Column(db.BigInteger, primary_key=True, autoincrement=True)
    school_id = db.Column(db.BigInteger, db.ForeignKey('schools.id'), nullable=False)
    college_id = db.Column(db.BigInteger, db.ForeignKey('colleges.id'), nullable=False)
    department_name = db.Column(db.String(200), nullable=False)
    college = db.relationship('Colleges', backref=db.backref('departments'))

class Users(db.Model):
    __tablename__ = "users"
    id = db.Column(db.BigInteger, primary_key=True, autoincrement=True)
    email = db.Column(db.String(255), unique=True, nullable=False)
    password_hash = db.Column(db.String(255), nullable=False)
    nickname = db.Column(db.String(100), nullable=False)
    realname = db.Column(db.String(100), nullable=False)
    gender = db.Column(db.Enum('male', 'female'), nullable=False)
    main_language = db.Column(db.String(10), db.ForeignKey('language.code'), nullable=False)
    nationality_iso2 = db.Column(db.CHAR(2), db.ForeignKey('country.iso2'), nullable=False)
    school_id = db.Column(db.BigInteger, db.ForeignKey('schools.id'), nullable=False)
    department_id = db.Column(db.BigInteger, db.ForeignKey('departments.id'), nullable=False)
    enrollment_year = db.Column(db.SmallInteger, nullable=False)
    is_helper = db.Column(db.Boolean)
    department = db.relationship('Departments', backref=db.backref('students'))
    school = db.relationship('Schools', backref=db.backref('students')) # 편의를 위해 추가

class HelperProfiles(db.Model):
    __tablename__ = "helper_profiles"
    id = db.Column(db.BigInteger, primary_key=True, autoincrement=True)
    user_id = db.Column(db.BigInteger, db.ForeignKey('users.id'), nullable=False, unique=True)
    intro = db.Column(db.String(500))
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

class HelperLanguages(db.Model):
    __tablename__ = "helper_languages"
    id = db.Column(db.BigInteger, primary_key=True, autoincrement=True)
    user_id = db.Column(db.BigInteger, db.ForeignKey('users.id'), nullable=False)
    language_code = db.Column(db.String(10), db.ForeignKey('language.code'), nullable=False)

class Communities(db.Model):
    __tablename__ = "communities"
    id = db.Column(db.BigInteger, primary_key=True, autoincrement=True)
    school_id = db.Column(db.BigInteger, db.ForeignKey('schools.id'), nullable=False)
    community_name = db.Column(db.String(200), nullable=False)
    nationality_iso2 = db.Column(db.CHAR(2), db.ForeignKey('country.iso2'), nullable=False)

class Boards(db.Model):
    __tablename__ = "boards"
    id = db.Column(db.BigInteger, primary_key=True, autoincrement=True)
    community_id = db.Column(db.BigInteger, db.ForeignKey('communities.id'), nullable=False)
    board_name = db.Column(db.String(200), nullable=False)
    description = db.Column(db.String(500))
    order_index = db.Column(db.Integer, default=0)

class Posts(db.Model):
    __tablename__ = "posts"
    id = db.Column(db.BigInteger, primary_key=True, autoincrement=True)
    board_id = db.Column(db.BigInteger, db.ForeignKey('boards.id'), nullable=False)
    user_id = db.Column(db.BigInteger, db.ForeignKey('users.id'), nullable=False)
    title = db.Column(db.String(200), nullable=False)
    content = db.Column(db.Text, nullable=False)
    original_lang = db.Column(db.String(10), db.ForeignKey('language.code'))
    is_anonymous = db.Column(db.Boolean, default=False)
    like_count = db.Column(db.Integer, default=0)
    comment_count = db.Column(db.Integer, default=0)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    author = db.relationship('Users', backref=db.backref('posts'))

class MatchRequests(db.Model):
    __tablename__ = "match_requests"
    id = db.Column(db.BigInteger, primary_key=True, autoincrement=True)
    requester_user_id = db.Column(db.BigInteger, db.ForeignKey('users.id'), nullable=False)
    preferred_college_id = db.Column(db.BigInteger, db.ForeignKey('colleges.id'))
    preferred_gender = db.Column(db.Enum('male', 'female', 'any'), default='any')
    notes = db.Column(db.String(500))
    status = db.Column(db.Enum('pending', 'offered', 'accepted', 'rejected', 'cancelled'), default='pending')
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    # 요청자 정보 (매칭 수락 시 school_id를 알기 위해)
    requester = db.relationship('Users', backref=db.backref('match_requests'))

class Matches(db.Model):
    __tablename__ = "matches"
    id = db.Column(db.BigInteger, primary_key=True, autoincrement=True)
    mentor_user_id = db.Column(db.BigInteger, db.ForeignKey('users.id'), nullable=False)
    mentee_user_id = db.Column(db.BigInteger, db.ForeignKey('users.id'), nullable=False)
    school_id = db.Column(db.BigInteger)
    request_id = db.Column(db.BigInteger, db.ForeignKey('match_requests.id'))
    status = db.Column(db.Enum('active', 'completed', 'cancelled'), default='active')
    started_at = db.Column(db.DateTime, default=datetime.utcnow)
    ended_at = db.Column(db.DateTime)

class Conversations(db.Model):
    __tablename__ = "conversations"
    id = db.Column(db.BigInteger, primary_key=True, autoincrement=True)
    match_id = db.Column(db.BigInteger, db.ForeignKey('matches.id'), unique=True, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

class ConversationParticipants(db.Model):
    __tablename__ = "conversation_participants"
    id = db.Column(db.BigInteger, primary_key=True, autoincrement=True)
    conversation_id = db.Column(db.BigInteger, db.ForeignKey('conversations.id'), nullable=False)
    user_id = db.Column(db.BigInteger, db.ForeignKey('users.id'), nullable=False)
    last_read_at = db.Column(db.DateTime)

class Messages(db.Model):
    __tablename__ = "messages"
    id = db.Column(db.BigInteger, primary_key=True, autoincrement=True)
    conversation_id = db.Column(db.BigInteger, db.ForeignKey('conversations.id'), nullable=False)
    sender_user_id = db.Column(db.BigInteger, db.ForeignKey('users.id'), nullable=False)
    content = db.Column(db.Text, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)