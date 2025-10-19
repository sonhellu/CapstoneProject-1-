from fastapi import FastAPI
from routers import auth # 우리가 만든 auth.py 파일을 불러옵니다.

# FastAPI 앱 생성
app = FastAPI()

# '/api/auth' 경로로 들어오는 요청들을 auth.py 파일의 router가 처리하도록 등록
app.include_router(auth.router)

@app.get("/")
def read_root():
    return {"message": "Hi-Campus API 서버에 오신 것을 환영합니다!"}