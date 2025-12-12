from .database import ma
from .models import Users, Posts, Schools, Departments

class SchoolSchema(ma.SQLAlchemyAutoSchema):
    class Meta:
        model = Schools
        fields = ('id', 'school_name', 'website_url')

class DepartmentSchema(ma.SQLAlchemyAutoSchema):
    class Meta:
        model = Departments
        fields = ('id', 'department_name')

class UserSchema(ma.SQLAlchemyAutoSchema):
    school = ma.Nested(SchoolSchema, dump_only=True)
    department = ma.Nested(DepartmentSchema, dump_only=True)
    
    class Meta:
        model = Users
        # Exclude password_hash only, let SQLAlchemyAutoSchema auto-detect other fields
        exclude = ('password_hash',)
        include_fk = True  # Include foreign keys like school_id, department_id, etc.

class PostSchema(ma.SQLAlchemyAutoSchema):
    # author 필드를 닉네임만 나오도록 수정
    author = ma.Nested(UserSchema, only=("nickname",))
    
    class Meta:
        model = Posts
        include_fk = True # board_id, user_id 포함

# 스키마 인스턴스 생성
user_schema = UserSchema()
post_schema = PostSchema()
posts_schema = PostSchema(many=True)