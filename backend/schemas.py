from pydantic import BaseModel, EmailStr

class UserCreate(BaseModel):
    email: EmailStr             # 이메일 형식인지 자동으로 검증해줍니다.
    password: str
    nickname: str
    realname: str
    main_language: str
    nationality_iso2: str
    school_id: int
    department_id: int
    enrollment_year: int