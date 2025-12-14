from app import create_app

# 앱 팩토리로부터 앱 인스턴스 생성
app = create_app()
socketio = app.socketio

if __name__ == "__main__":
    # Production: debug=False, Development: debug=True
    import os
    debug_mode = os.getenv('FLASK_DEBUG', 'False').lower() == 'true'
    # Use socketio.run() instead of app.run() to support WebSocket
    socketio.run(app, debug=debug_mode, host='0.0.0.0', port=int(os.getenv('PORT', 5000)))