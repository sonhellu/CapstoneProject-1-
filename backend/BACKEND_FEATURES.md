# Backend Features - Hi-Campus API

## Tổng quan

Backend được xây dựng bằng **Flask** (Python) và deploy trên **Render.com**.

**URL Production**: https://hi-campus-backend.onrender.com

**Framework**: Flask + SQLAlchemy + Marshmallow

**Database**: MySQL (trên Render)

**Authentication**: JWT Token (hết hạn sau 1 ngày)

---

## Cấu trúc Backend

### Entry Point
- **File chính**: `run.py` → Gọi `app/__init__.py`
- **Procfile**: `gunicorn run:app` (cho Render)
- **Port**: 5000 (local), dynamic (Render)

### Application Factory
File: `app/__init__.py`
- Tạo Flask app
- Khởi tạo database (SQLAlchemy)
- Đăng ký 4 blueprints (routes)
- CLI command: `flask init-db`

### Database Models
File: `app/models.py`

**Tables:**
1. `language` - Danh sách ngôn ngữ
2. `country` - Danh sách quốc gia
3. `schools` - Trường học
4. `colleges` - Khoa
5. `departments` - Bộ môn
6. `users` - Người dùng
7. `helper_profiles` - Profile của helper (người hỗ trợ)
8. `helper_languages` - Ngôn ngữ mà helper biết
9. `communities` - Cộng đồng
10. `boards` - Bảng tin
11. `posts` - Bài viết
12. `match_requests` - Yêu cầu kết nối
13. `matches` - Kết nối thành công
14. `conversations` - Cuộc trò chuyện
15. `conversation_participants` - Người tham gia trò chuyện
16. `messages` - Tin nhắn

---

## Chức năng Backend

### 1. 🔐 Authentication (`/api/auth`)

#### Đăng ký
- **Endpoint**: `POST /api/auth/register`
- **File**: `app/routes/auth.py`
- **Chức năng**: Tạo tài khoản mới
- **Input**: 
  - email (unique)
  - password (sẽ được hash bằng bcrypt)
  - nickname
  - realname
  - gender (male/female)
  - main_language
  - nationality_iso2
  - school_id
  - department_id
  - enrollment_year
- **Output**: `{message: "User registered successfully"}`
- **Errors**: 
  - 400: Thiếu fields
  - 409: Email đã tồn tại

#### Đăng nhập
- **Endpoint**: `POST /api/auth/login`
- **File**: `app/routes/auth.py`
- **Chức năng**: Xác thực và tạo JWT token
- **Input**: email, password
- **Output**: `{access_token, token_type: "bearer"}`
- **Token**: Hết hạn sau 1 ngày
- **Errors**:
  - 400: Thiếu email/password
  - 401: Sai email/password

---

### 2. 📝 Community (`/api`)

#### Xem danh sách bài viết
- **Endpoint**: `GET /api/board/<board_id>/posts?limit=20`
- **File**: `app/routes/community.py`
- **Chức năng**: Lấy danh sách bài viết trong board
- **Query Params**: 
  - `limit` (mặc định: 20)
- **Features**:
  - Sắp xếp theo thời gian (mới nhất trước)
  - Ẩn danh (anonymous) - ẩn thông tin tác giả
  - Tạo preview text (rút gọn > 50 ký tự)
- **Output**: Array of posts
- **Auth**: Không cần

#### Tạo bài viết
- **Endpoint**: `POST /api/board/<board_id>/posts`
- **File**: `app/routes/community.py`
- **Chức năng**: Tạo bài viết mới
- **Auth**: ✅ Cần token (`@require_auth`)
- **Input**: 
  - title
  - content
  - is_anonymous (optional, default: false)
- **Auto**: Lưu ngôn ngữ gốc của tác giả
- **Output**: Post object
- **Errors**:
  - 400: Thiếu title/content
  - 401: Chưa đăng nhập

---

### 3. 🏫 School (`/api/school`)

#### Lấy URL dịch trang chủ trường
- **Endpoint**: `GET /api/school/my-homepage-translation`
- **File**: `app/routes/school.py`
- **Chức năng**: Tạo Google Translate URL cho trang chủ trường
- **Auth**: ✅ Cần token (`@require_auth`)
- **Logic**: 
  - Lấy school_id từ user
  - Lấy website_url từ Schools table
  - Tạo Google Translate URL với ngôn ngữ của user
- **Output**: 
  ```json
  {
    "school_id": 1,
    "school_name": "Keimyung University",
    "original_url": "https://www.kmu.ac.kr",
    "translated_url": "https://translate.google.com/translate?sl=auto&tl=vi&u=https://www.kmu.ac.kr",
    "target_language": "vi"
  }
  ```
- **Errors**:
  - 404: Không tìm thấy school hoặc website_url

---

### 4. 🤝 Matching (`/api`)

#### 4.1. Tạo yêu cầu kết nối
- **Endpoint**: `POST /api/match_requests`
- **File**: `app/routes/matching.py`
- **Chức năng**: Mentee tạo yêu cầu tìm helper
- **Auth**: ✅ Cần token
- **Giới hạn**: 
  - Chỉ mentee (is_helper = False)
  - Không cho phép nhiều pending request
- **Input**:
  - preferred_college_id (optional)
  - preferred_gender (optional: male/female/any)
  - notes (optional)
- **Output**: `{id, status: "pending"}`
- **Errors**:
  - 403: Helper không thể tạo request
  - 409: Đã có pending request

#### 4.2. Tìm helper phù hợp
- **Endpoint**: `GET /api/match_requests/<request_id>/find_helpers?limit=10`
- **File**: `app/routes/matching.py`
- **Chức năng**: Tìm danh sách helper phù hợp
- **Auth**: ✅ Cần token
- **Bộ lọc**:
  - Helper có ngôn ngữ của requester
  - Gender (nếu có preferred_gender)
  - College (nếu có preferred_college_id)
- **Query Params**: `limit` (mặc định: 10)
- **Output**: Array of helpers `[{id, nickname}]`

#### 4.3. Đề xuất kết nối (Offer)
- **Endpoint**: `POST /api/match_requests/<request_id>/offer`
- **File**: `app/routes/matching.py`
- **Chức năng**: Admin/Helper đề xuất helper cho mentee
- **Auth**: ✅ Cần token
- **Input**: `mentor_user_id`
- **Action**: Chuyển status → "offered"
- **Output**: `{request_id, status, offered_to}`

#### 4.4. Chấp nhận kết nối
- **Endpoint**: `POST /api/match_requests/<request_id>/accept`
- **File**: `app/routes/matching.py`
- **Chức năng**: Mentee chấp nhận offer
- **Auth**: ✅ Cần token
- **Input**: `mentor_user_id`
- **Actions**:
  1. Tạo Match record
  2. Tạo Conversation
  3. Thêm 2 ConversationParticipants
  4. Chuyển status → "accepted"
- **Output**: `{match_id, conversation_id}`
- **Errors**:
  - 400: Status không phải "offered"

#### 4.5. Gửi tin nhắn
- **Endpoint**: `POST /api/conversations/<conv_id>/messages`
- **File**: `app/routes/matching.py`
- **Chức năng**: Gửi tin nhắn trong conversation
- **Auth**: ✅ Cần token
- **Validation**: Chỉ participant mới gửi được
- **Input**: `content`
- **Output**: `{message_id, created_at}`
- **Errors**:
  - 400: Thiếu content
  - 403: Không phải participant

#### 4.6. Xem tin nhắn
- **Endpoint**: `GET /api/conversations/<conv_id>/messages`
- **File**: `app/routes/matching.py`
- **Chức năng**: Lấy danh sách tin nhắn
- **Auth**: ✅ Cần token
- **Validation**: Chỉ participant mới xem được
- **Output**: Array of messages (sắp xếp theo thời gian)
- **Errors**:
  - 403: Không phải participant

---

## Authentication & Authorization

### JWT Token
File: `app/auth_utils.py`

#### Decorator: `@require_auth`
- Kiểm tra header: `Authorization: Bearer <token>`
- Decode JWT token
- Lấy user_id từ token
- Query user từ database
- Gán `request.user` = User object
- Sử dụng trong routes cần authentication

**Errors:**
- 401: Token missing
- 401: Token expired
- 401: Invalid token
- 401: User not found

---

## Database Schema

### Users Table
```python
id: BigInteger (PK)
email: String(255) UNIQUE
password_hash: String(255)
nickname: String(100)
realname: String(100)
gender: Enum('male', 'female')
main_language: String(10) FK → language.code
nationality_iso2: CHAR(2) FK → country.iso2
school_id: BigInteger FK → schools.id
department_id: BigInteger FK → departments.id
enrollment_year: SmallInteger
is_helper: Boolean
```

### Posts Table
```python
id: BigInteger (PK)
board_id: BigInteger FK → boards.id
user_id: BigInteger FK → users.id
title: String(200)
content: Text
original_lang: String(10) FK → language.code
is_anonymous: Boolean (default: False)
like_count: Integer (default: 0)
comment_count: Integer (default: 0)
created_at: DateTime
updated_at: DateTime
```

### Matches & Conversations
```python
Matches:
- mentor_user_id FK → users.id
- mentee_user_id FK → users.id
- status: Enum('active', 'completed', 'cancelled')

Conversations:
- match_id FK → matches.id (unique)

Messages:
- conversation_id FK → conversations.id
- sender_user_id FK → users.id
- content: Text
- created_at: DateTime
```

---

## Configuration

### Environment Variables
File: `app/config.py`

**Required:**
- `DATABASE_URL` (hoặc DB_USER, DB_PASS, DB_HOST, DB_PORT, DB_NAME)
- `SECRET_KEY` (cho JWT)

**Optional:**
- `FLASK_DEBUG` (default: False)

### Database Connection
- Hỗ trợ cả `DATABASE_URL` và separate credentials
- Auto-convert MySQL URL cho SQLAlchemy
- Charset: utf8mb4

---

## Deployment

### Render.com
- **Web Service**: Flask app
- **Database**: MySQL
- **Files cần thiết**:
  - `requirements.txt` - Python dependencies
  - `Procfile` - Start command
  - `runtime.txt` - Python version
  - `render.yaml` - Auto config (optional)

### Commands
```bash
# Local development
python run.py

# Initialize database
flask init-db

# Deploy (Render tự động)
git push origin main
```

---

## API Summary

| Module | Endpoints | Auth Required | Chức năng |
|--------|-----------|---------------|-----------|
| **Auth** | 2 | ❌ | Đăng ký, Đăng nhập |
| **Community** | 2 | ⚠️ Một phần | Xem/Tạo bài viết |
| **School** | 1 | ✅ | Dịch trang chủ trường |
| **Matching** | 6 | ✅ | Kết nối mentor-mentee, Chat |

**Tổng**: 11 endpoints

---

## Security Features

### Password Security
- ✅ Bcrypt hashing
- ✅ Salt tự động
- ✅ Không trả về password_hash trong API

### JWT Security
- ✅ HS256 algorithm
- ✅ Token expiration (1 ngày)
- ✅ User validation
- ✅ Secret key từ environment

### Authorization
- ✅ Route protection với `@require_auth`
- ✅ User ownership validation
- ✅ Role-based logic (helper vs mentee)

---

## Tính năng đặc biệt

### 1. Anonymous Posts
- User có thể đăng bài ẩn danh
- Tác giả hiển thị là "익명"
- user_id = None trong response

### 2. Language Support
- Lưu ngôn ngữ gốc của bài viết
- Tự động dịch trang chủ trường theo ngôn ngữ user

### 3. Matching System
- Tìm helper theo:
  - Ngôn ngữ
  - Giới tính
  - College
- Workflow: Request → Offer → Accept → Conversation

### 4. Real-time Chat
- Conversation được tạo tự động khi match
- Messages được lưu với timestamp
- Chỉ participants mới xem/gửi được

---

## Chưa có (có thể cần thêm)

### Admin Features
- [ ] Admin dashboard
- [ ] User management (CRUD)
- [ ] Post moderation
- [ ] Community management
- [ ] Analytics/Statistics

### Advanced Features
- [ ] Refresh token
- [ ] Email verification
- [ ] Password reset
- [ ] File upload (images, documents)
- [ ] Notifications
- [ ] Search/Filter nâng cao
- [ ] Pagination metadata
- [ ] Rate limiting
- [ ] WebSocket cho real-time chat

### Database
- [ ] Migrations (Alembic)
- [ ] Seeding data
- [ ] Backup strategy
- [ ] Indexes optimization

---

## Testing

### Manual Testing
```bash
# Test root
curl https://hi-campus-backend.onrender.com/

# Test register
curl -X POST https://hi-campus-backend.onrender.com/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{...}'

# Test login
curl -X POST https://hi-campus-backend.onrender.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"123456"}'
```

### Automated Testing
Chưa có unit tests. Recommended:
- pytest
- Flask testing client
- Factory pattern cho test data

---

## Performance

### Current
- ✅ SQLAlchemy ORM (efficient queries)
- ✅ Marshmallow serialization
- ✅ Database relationships
- ✅ CORS configured

### Can Improve
- [ ] Query optimization
- [ ] Database indexes
- [ ] Response caching (Redis)
- [ ] Connection pooling
- [ ] Load balancing

---

## Monitoring

### Render Dashboard
- Logs tab: Xem application logs
- Metrics: CPU, Memory usage
- Events: Deploy history

### Recommended Tools
- Sentry (error tracking)
- New Relic (APM)
- Datadog (monitoring)

---

## Files Overview

```
backend/
├── app/
│   ├── __init__.py           # Application factory
│   ├── config.py             # Configuration
│   ├── database.py           # SQLAlchemy setup
│   ├── models.py             # Database models (15 tables)
│   ├── schemas.py            # Marshmallow schemas
│   ├── auth_utils.py         # JWT decorator
│   └── routes/
│       ├── auth.py           # 2 endpoints (register, login)
│       ├── community.py      # 2 endpoints (posts CRUD)
│       ├── school.py         # 1 endpoint (translation)
│       └── matching.py       # 6 endpoints (matching + chat)
├── run.py                    # Entry point
├── main.py                   # FastAPI (không dùng)
├── requirements.txt          # Dependencies
├── Procfile                  # Render start command
├── runtime.txt               # Python version
├── render.yaml               # Render config
├── setup_database.sql        # Database schema
└── setup_data.py             # Seed data (nếu có)
```

---

## Conclusion

Backend Hi-Campus có **11 endpoints** với **4 modules chính**:
1. ✅ Authentication (JWT)
2. ✅ Community (Posts)
3. ✅ School (Translation)
4. ✅ Matching (Mentor-Mentee + Chat)

**Đang chạy trên**: https://hi-campus-backend.onrender.com

**Framework**: Flask + SQLAlchemy + JWT

**Database**: MySQL (15 tables)

**Ready for**: Production use với frontend Flutter app

Cần thêm tính năng gì không? 🚀

