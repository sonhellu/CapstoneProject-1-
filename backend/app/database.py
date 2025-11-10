from flask_sqlalchemy import SQLAlchemy
from flask_marshmallow import Marshmallow

# db와 ma 객체를 생성만 하고 초기화는 __init__.py에서 진행
db = SQLAlchemy()
ma = Marshmallow()