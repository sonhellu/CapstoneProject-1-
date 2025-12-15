from app import create_app

# 앱 팩토리로부터 앱 인스턴스 생성
app = create_app()

if __name__ == "__main__":
    # Production: debug=False, Development: debug=True
    import os
    debug_mode = os.getenv('FLASK_DEBUG', 'False').lower() == 'true'
    app.run(debug=debug_mode, host='0.0.0.0', port=int(os.getenv('PORT', 5000)))