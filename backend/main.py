from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routers import auth

# FastAPI 앱 생성
app = FastAPI()

# Cấu hình CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  
    allow_credentials=True,
    allow_methods=["*"], 
    allow_headers=["*"], 
)

# '/api/auth' 경로로 들어오는 요청들을 auth.py 파일의 router가 처리하도록 등록
app.include_router(auth.router)

@app.get("/")
def read_root():
    return {"message": "Hi-Campus API 서버에 오신 것을 환영합니다!"}