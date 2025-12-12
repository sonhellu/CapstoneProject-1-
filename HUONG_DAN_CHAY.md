# Hướng Dẫn Chạy Ứng Dụng Hi-Campus

## 📋 Yêu Cầu

- Python 3.8+ (cho backend)
- Flutter SDK (cho frontend)
- MySQL hoặc PostgreSQL database
- Node.js (nếu cần)

---

## 🔧 Bước 1: Setup Backend

### 1.1. Cài đặt dependencies

```bash
cd backend
pip install -r requirements.txt
```

### 1.2. Cấu hình Database

Tạo file `.env` trong thư mục `backend/` (hoặc set environment variables):

```bash
# Cho local development (MySQL)
DB_USER=root
DB_PASS=1234
DB_HOST=127.0.0.1
DB_NAME=hi_campus

# Hoặc cho Render (PostgreSQL) - sẽ tự động dùng DATABASE_URL
DATABASE_URL=postgresql://user:password@host:port/database

# SECRET_KEY (bắt buộc)
SECRET_KEY=your-secret-key-here
```

**Tạo SECRET_KEY:**
```bash
cd backend
python3 generate_secret_key.py
# Copy key và set vào environment variable
```

### 1.3. Seed dữ liệu vào Database

```bash
cd backend
python3 seed_data.py
```

Kết quả mong đợi:
```
🌱 Starting to seed database...
📝 Seeding Languages...
  ✅ Added language: en - English
  ...
✅ All data seeded successfully!
```

### 1.4. Chạy Backend Server

```bash
cd backend
python3 run.py
```

Backend sẽ chạy tại: `http://127.0.0.1:5000`

**Kiểm tra backend:**
```bash
curl http://127.0.0.1:5000/
# Kết quả: {"message": "Hi-Campus API 서버 (분리된 구조)"}
```

---

## 📱 Bước 2: Setup Frontend

### 2.1. Cài đặt dependencies

```bash
cd frontend
flutter pub get
```

### 2.2. Cấu hình API URL

File `frontend/lib/services/api_config.dart`:
- Đã set mặc định: `https://hicampus.onrender.com` (production)
- Để dùng local: Set `_isProduction = false`

### 2.3. Chạy Frontend

```bash
cd frontend
flutter run
```

Hoặc chạy trên device cụ thể:
```bash
flutter run -d chrome        # Web
flutter run -d ios           # iOS
flutter run -d android       # Android
```

---

## ✅ Bước 3: Test Đăng Ký

### 3.1. Mở app và vào màn hình đăng ký

### 3.2. Điền thông tin:

- **Email**: `test@example.com`
- **Password**: `password123`
- **Real Name**: `Test User`
- **Gender**: Chọn Male hoặc Female
- **Nickname**: `testuser`
- **Main Language**: Chọn từ dropdown (từ API)
- **Nationality**: Chọn từ dropdown (từ API)
- **School ID**: Có thể để trống hoặc nhập số
- **University**: Chọn từ dropdown (từ API)
- **Department**: Sẽ tự động load khi chọn University (từ API)
- **Enrollment Year**: Chọn năm

### 3.3. Submit đăng ký

Nếu thành công, bạn sẽ thấy thông báo và được chuyển về màn hình đăng nhập.

---

## 🔍 Kiểm Tra API Endpoints

### Test các API options:

```bash
# Get schools
curl http://127.0.0.1:5000/api/options/schools

# Get languages
curl http://127.0.0.1:5000/api/options/languages

# Get countries
curl http://127.0.0.1:5000/api/options/countries

# Get departments (cần school_id)
curl "http://127.0.0.1:5000/api/options/departments?school_id=5917654"
```

---

## 🐛 Troubleshooting

### Lỗi: "School with id X not found"
- **Nguyên nhân**: Chưa seed dữ liệu
- **Giải pháp**: Chạy `python3 seed_data.py`

### Lỗi: "Cannot connect to server"
- **Nguyên nhân**: Backend chưa chạy hoặc sai URL
- **Giải pháp**: 
  - Kiểm tra backend đang chạy: `curl http://127.0.0.1:5000/`
  - Kiểm tra `api_config.dart` có đúng URL không

### Lỗi: "ModuleNotFoundError"
- **Nguyên nhân**: Chưa cài dependencies
- **Giải pháp**: `pip install -r requirements.txt`

### Lỗi: Database connection
- **Nguyên nhân**: Database chưa được tạo hoặc sai thông tin
- **Giải pháp**: 
  - Tạo database: `CREATE DATABASE hi_campus;`
  - Kiểm tra thông tin trong `.env` hoặc environment variables

---

## 📝 Lưu Ý

1. **Backend phải chạy trước** khi test frontend
2. **Phải seed dữ liệu** trước khi đăng ký
3. **SECRET_KEY** phải được set (bắt buộc cho JWT)
4. **CORS** đã được cấu hình để cho phép frontend gọi API

---

## 🚀 Deploy lên Render

### Backend:
1. Push code lên GitHub
2. Tạo Web Service trên Render
3. Link PostgreSQL database
4. Set environment variables:
   - `SECRET_KEY`
   - `PYTHON_VERSION=3.11`
   - `FLASK_DEBUG=False`

### Frontend:
- Cập nhật `api_config.dart` với URL Render
- Build và deploy (hoặc dùng Flutter Web)

---

## ✅ Checklist

- [ ] Backend dependencies đã cài
- [ ] Database đã tạo và cấu hình
- [ ] SECRET_KEY đã set
- [ ] Dữ liệu đã seed (`seed_data.py`)
- [ ] Backend server đang chạy
- [ ] Frontend dependencies đã cài (`flutter pub get`)
- [ ] API URL đã cấu hình đúng
- [ ] Frontend app đang chạy
- [ ] Test đăng ký thành công

---

Chúc bạn thành công! 🎉

