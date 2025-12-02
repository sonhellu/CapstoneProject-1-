# Hướng dẫn Deploy Backend lên Render.com

## Bước 1: Chuẩn bị Repository

Đảm bảo code đã được push lên GitHub/GitLab repository.

## Bước 2: Tạo Web Service trên Render

1. Đăng nhập vào [Render.com](https://render.com)
2. Click **"New +"** → Chọn **"Web Service"**
3. Kết nối repository của bạn
4. Cấu hình như sau:

### Basic Settings:
- **Name**: `hi-campus-backend` (hoặc tên bạn muốn)
- **Region**: Chọn region gần nhất (Singapore, US, etc.)
- **Branch**: `main` (hoặc branch bạn muốn deploy)
- **Root Directory**: `backend` (quan trọng!)
- **Runtime**: `Python 3`
- **Build Command**: `pip install -r requirements.txt`
- **Start Command**: `gunicorn run:app --bind 0.0.0.0:$PORT`

### Environment Variables:
Thêm các biến môi trường sau trong Render Dashboard:

```
DB_USER=your_db_user
DB_PASS=your_db_password
DB_HOST=your_db_host
DB_PORT=3306
DB_NAME=hi_campus
SECRET_KEY=your-super-secret-jwt-key-change-this
FLASK_DEBUG=False
```

**Lưu ý**: Nếu bạn dùng Render PostgreSQL thay vì MySQL, cần:
- Thay đổi `DATABASE_URL` (Render tự động tạo)
- Cập nhật `requirements.txt` để dùng `psycopg2` thay vì `PyMySQL`

## Bước 3: Tạo Database trên Render (MySQL)

1. Click **"New +"** → Chọn **"MySQL"**
2. Cấu hình:
   - **Name**: `hi-campus-db`
   - **Database**: `hi_campus`
   - **User**: (Render tự tạo)
   - **Region**: Cùng region với Web Service
3. Sau khi tạo xong, copy thông tin kết nối:
   - Internal Database URL (dùng cho Web Service)
   - Hoặc các thông tin riêng lẻ: Host, Port, User, Password

## Bước 4: Kết nối Database với Web Service

1. Vào Web Service → **"Environment"** tab
2. Thêm các biến môi trường từ Database:
   - `DATABASE_URL` (nếu Render cung cấp)
   - Hoặc `DB_HOST`, `DB_USER`, `DB_PASS`, `DB_NAME`, `DB_PORT`

## Bước 5: Khởi tạo Database

Sau khi deploy thành công, bạn cần chạy migration để tạo tables:

### Option 1: Sử dụng Render Shell
1. Vào Web Service → **"Shell"** tab
2. Chạy lệnh:
```bash
flask init-db
```

### Option 2: Sử dụng SQL Script
1. Vào Database → **"Connect"** tab
2. Kết nối và chạy script từ `setup_database.sql`

## Bước 6: Kiểm tra Deployment

1. Sau khi deploy xong, Render sẽ cung cấp URL: `https://your-app-name.onrender.com`
2. Test endpoint: `https://your-app-name.onrender.com/`
3. Nên thấy response: `{"message": "Hi-Campus API 서버 (분리된 구조)"}`

## Bước 7: Cập nhật Frontend API Config

Cập nhật `frontend/lib/services/api_config.dart` với URL mới:

```dart
static const String baseUrl = 'https://your-app-name.onrender.com';
```

## Troubleshooting

### Lỗi kết nối database:
- Kiểm tra environment variables đã đúng chưa
- Đảm bảo Web Service và Database cùng region
- Kiểm tra firewall settings

### Lỗi build:
- Kiểm tra `requirements.txt` có đầy đủ dependencies
- Kiểm tra Python version trong `runtime.txt`

### Lỗi 500 Internal Server Error:
- Xem logs trong Render Dashboard
- Kiểm tra database connection
- Kiểm tra SECRET_KEY đã được set

## Lưu ý quan trọng:

1. **Free tier**: Render sẽ sleep service sau 15 phút không dùng. Request đầu tiên sẽ mất ~30s để wake up.
2. **Database**: Nếu dùng MySQL free tier, có giới hạn về storage và connections.
3. **Environment Variables**: Không commit SECRET_KEY vào git. Luôn dùng environment variables.
4. **CORS**: Đã cấu hình CORS cho phép tất cả origins. Nên giới hạn trong production.

