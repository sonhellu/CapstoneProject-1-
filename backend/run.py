from app import create_app

# 앱 팩토리로부터 앱 인스턴스 생성
app = create_app()

if __name__ == "__main__":
    app.run(debug=True, port=5000)