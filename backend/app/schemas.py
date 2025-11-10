from .database import ma
from .models import Users, Posts

class UserSchema(ma.SQLAlchemyAutoSchema):
    class Meta:
        model = Users
        exclude = ('password_hash',) # 비밀번호는 절대 반환 X

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