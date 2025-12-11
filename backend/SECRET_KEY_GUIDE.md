# SECRET_KEY Setup Guide

## 🔑 SECRET_KEY đã được generate

**SECRET_KEY của bạn:**
```
58ryhl77vgizZbGxgBRpB5Q94hfwVwRjvKVFEuGhCKc
```

⚠️ **QUAN TRỌNG:** Giữ key này bí mật! Không commit vào git!

---

## Cách sử dụng SECRET_KEY

### 1. Trên Render (Production)

1. Vào Render Dashboard → Web Service → Environment
2. Click "Add Environment Variable"
3. Thêm:
   - **Key:** `SECRET_KEY`
   - **Value:** `58ryhl77vgizZbGxgBRpB5Q94hfwVwRjvKVFEuGhCKc`
4. Click "Save Changes"
5. Render sẽ tự động restart service

### 2. Local Development (Optional)

Nếu muốn dùng .env file cho local:

1. Tạo file `.env` trong thư mục `backend/`:
```bash
cd backend
touch .env
```

2. Thêm vào file `.env`:
```
SECRET_KEY=58ryhl77vgizZbGxgBRpB5Q94hfwVwRjvKVFEuGhCKc
```

3. Install python-dotenv (nếu chưa có):
```bash
pip install python-dotenv
```

4. Update `backend/app/config.py` để load .env:
```python
from dotenv import load_dotenv
load_dotenv()  # Load .env file
```

**Lưu ý:** File `.env` đã được thêm vào `.gitignore` nên sẽ không bị commit.

---

## Generate SECRET_KEY mới

Nếu cần generate SECRET_KEY mới:

```bash
cd backend
python3 generate_secret_key.py
```

Hoặc dùng Python trực tiếp:
```bash
python3 -c "import secrets; print(secrets.token_urlsafe(32))"
```

---

## Kiểm tra SECRET_KEY đang được sử dụng

### Trên Render:
1. Vào Web Service → Environment
2. Tìm `SECRET_KEY` trong danh sách environment variables

### Local:
```bash
# Kiểm tra environment variable
echo $SECRET_KEY

# Hoặc trong Python
python3 -c "import os; print('SECRET_KEY:', os.getenv('SECRET_KEY', 'Not set'))"
```

---

## Security Best Practices

1. ✅ **KHÔNG** commit SECRET_KEY vào git
2. ✅ **KHÔNG** hardcode SECRET_KEY trong code
3. ✅ Sử dụng environment variables
4. ✅ Generate key mới cho mỗi môi trường (dev, staging, production)
5. ✅ Rotate key định kỳ nếu bị lộ

---

## Troubleshooting

### Lỗi: "SECRET_KEY not set"
- Kiểm tra environment variable đã được set chưa
- Trên Render: Vào Environment tab và kiểm tra
- Local: Export variable: `export SECRET_KEY=your-key`

### Lỗi: "Invalid token" khi login
- Có thể SECRET_KEY đã thay đổi
- Cần login lại để lấy token mới với key mới

---

## Current SECRET_KEY

```
58ryhl77vgizZbGxgBRpB5Q94hfwVwRjvKVFEuGhCKc
```

Copy key này và paste vào Render Environment Variables.

