from fastapi import APIRouter, HTTPException, Depends
from schemas import UserCreate # 우리가 만든 데이터 형식
from database import get_db_connection
import bcrypt
import mysql.connector

# /api/auth 라는 경로로 API를 그룹화합니다.
router = APIRouter(prefix="/api/auth")

@router.post("/register", status_code=201) # POST 요청을 받고, 성공 시 201 코드를 반환
def register_user(user_data: UserCreate):
    """
    신규 사용자 회원가입 API
    - Pydantic 모델(UserCreate)을 통해 요청 본문의 유효성을 검사합니다.
    - 비밀번호를 해싱하여 데이터베이스에 저장합니다.
    - 이메일 중복 시 409 Conflict 에러를 반환합니다.
    """
    conn = get_db_connection()
    if conn is None:
        raise HTTPException(status_code=500, detail="데이터베이스에 연결할 수 없습니다.")
    
    cursor = conn.cursor()

    # 1. 비밀번호를 암호화합니다.
    hashed_password = bcrypt.hashpw(user_data.password.encode('utf-8'), bcrypt.gensalt())

    # 2. DB에 사용자 정보를 저장하는 SQL 쿼리
    query = """
    INSERT INTO users (
        email, password_hash, nickname, realname, main_language, 
        nationality_iso2, school_id, department_id, enrollment_year
    ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
    """
    values = (
        user_data.email,
        hashed_password.decode('utf-8'), # DB에 저장하기 위해 문자열로 변환
        user_data.nickname,
        user_data.realname,
        user_data.main_language,
        user_data.nationality_iso2,
        user_data.school_id,
        user_data.department_id,
        user_data.enrollment_year
    )

    try:
        cursor.execute(query, values)
        conn.commit() # 변경사항을 DB에 최종 반영
    except mysql.connector.IntegrityError as err:
        # 이메일(UNIQUE 제약조건)이 중복될 경우 발생하는 에러
        raise HTTPException(status_code=409, detail="이미 가입된 이메일입니다.")
    except Exception as e:
        # 그 외 다른 에러 처리
        raise HTTPException(status_code=500, detail=f"서버 오류: {e}")
    finally:
        cursor.close()
        conn.close()

    return {"message": "회원가입이 성공적으로 완료되었습니다."}