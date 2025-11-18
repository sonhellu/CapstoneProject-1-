# 🚀 Hướng dẫn chạy API Login/Register

## ✅ Backend đã có sẵn

Backend của bạn đã có 2 API:
- ✅ `POST /api/auth/login` - Đăng nhập
- ✅ `POST /api/auth/register` - Đăng ký

## 📋 Các bước Setup

### Bước 1: Chạy Backend

```bash
cd backend
python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

**Kiểm tra backend đang chạy:**
Mở browser: `http://localhost:8000`

Nếu thấy: `{"message": "Hi-Campus API 서버에 오신 것을 환영합니다!"}` → Backend OK! ✅

---

### Bước 2: Cấu hình Frontend

Mở file: `frontend/lib/services/api_config.dart`

**Nếu test trên Android Emulator:**
```dart
static const String baseUrl = 'http://10.0.2.2:8000';
```

**Nếu test trên iOS Simulator:**
```dart
static const String baseUrl = 'http://localhost:8000';
```

**Nếu test trên điện thoại thật:**
1. Tìm IP máy tính:
   - Mac: `ipconfig getifaddr en0`
   - Windows: `ipconfig` → IPv4 Address

2. Thay URL:
```dart
static const String baseUrl = 'http://192.168.1.XXX:8000';  // Thay XXX
```

---

### Bước 3: Chạy Flutter App

```bash
cd frontend
flutter run
```

---

## 🧪 Test API

### Test Register:
1. Mở Register screen
2. Điền form đầy đủ:
   - Email: `test@example.com`
   - Password: `password123`
   - Nickname: `testuser`
   - Real name: `Test User`
   - Các field khác
3. Nhấn Register

**Kết quả mong đợi:**
- ✅ Thành công → "회원가입이 성공적으로 완료되었습니다."
- ❌ Email trùng → "이미 가입된 이메일입니다."

### Test Login:
1. Dùng email/password vừa register
2. Nhấn Login

**Kết quả mong đợi:**
- ✅ Thành công → Chuyển đến Home screen
- ❌ Sai mật khẩu → "이메일 또는 비밀번호가 올바르지 않습니다."

---

## 🔧 Cấu trúc Backend API

### POST /api/auth/register
**Request:**
```json
{
  "email": "test@example.com",
  "password": "password123",
  "nickname": "testuser",
  "realname": "Test User",
  "main_language": "ko",
  "nationality_iso2": "KR",
  "school_id": 1,
  "department_id": 1,
  "enrollment_year": 2024
}
```

**Response (201):**
```json
{
  "message": "회원가입이 성공적으로 완료되었습니다."
}
```

**Error (409):**
```json
{
  "detail": "이미 가입된 이메일입니다."
}
```

---

### POST /api/auth/login
**Request:**
```json
{
  "email": "test@example.com",
  "password": "password123"
}
```

**Response (200):**
```json
{
  "message": "로그인 성공",
  "user": {
    "id": 1,
    "email": "test@example.com",
    "nickname": "testuser",
    "realname": "Test User",
    ...
  }
}
```

**Error (401):**
```json
{
  "detail": "이메일 또는 비밀번호가 올바르지 않습니다."
}
```

---

## 🐛 Xử lý lỗi thường gặp

### "Không thể kết nối đến server"
✅ **Giải pháp:**
1. Kiểm tra backend đang chạy: `http://localhost:8000`
2. Kiểm tra URL trong `api_config.dart` đúng chưa
3. Với Android emulator, **PHẢI** dùng `10.0.2.2` chứ không phải `localhost`
4. Tắt firewall/antivirus thử

### "Connection timeout"
✅ **Giải pháp:**
1. Tăng timeout trong `api_config.dart`:
```dart
static const Duration connectTimeout = Duration(seconds: 30);
```
2. Kiểm tra mạng

### Database connection error
✅ **Giải pháp:**
1. Kiểm tra file `backend/database.py` có config đúng không
2. Kiểm tra MySQL đang chạy chưa
3. Kiểm tra database và table đã tạo chưa

---

## 📝 Checklist

- [ ] Backend đang chạy (`http://localhost:8000` accessible)
- [ ] Database đã setup và có table `users`
- [ ] URL trong `api_config.dart` đã đúng với môi trường test
- [ ] http package đã được cài (`flutter pub get`)
- [ ] Thử register một user mới thành công
- [ ] Thử login với user vừa tạo thành công

---

## 🎯 Tóm tắt

**Frontend → Backend Flow:**
```
Login Screen 
  → AuthService.login()
    → ApiService.post('/api/auth/login')
      → Backend: auth.py login_user()
        → MySQL: SELECT user
          → Response: user data
            → Save to SharedPreferences
              → Navigate to Home
```

**Đã làm gì:**
1. ✅ Thêm Login API vào backend (`routers/auth.py`)
2. ✅ Tạo schema UserLogin (`schemas.py`)
3. ✅ Tạo ApiService để handle HTTP requests
4. ✅ Tạo AuthService để xử lý login/register logic
5. ✅ Login/Register screens đã connect với API thật

**Tất cả đã sẵn sàng! Chỉ cần:**
1. Chạy backend
2. Đổi URL trong `api_config.dart`
3. Chạy app và test! 🚀

