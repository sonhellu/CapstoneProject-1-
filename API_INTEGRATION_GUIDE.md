# API Integration Guide - Frontend với Render Backend

## Tổng quan

Frontend Flutter app đã được tích hợp với backend API trên Render:
- **Backend URL**: https://hi-campus-backend.onrender.com
- **Framework**: Flask (Python)
- **Authentication**: JWT Token

## Cấu hình

### API Config (`lib/services/api_config.dart`)

```dart
// Production mode (sử dụng Render)
static const bool _isProduction = true;

// Development mode (sử dụng local backend)
static const bool _isProduction = false;
```

**URLs:**
- Production: `https://hi-campus-backend.onrender.com`
- Development: `http://127.0.0.1:8000`

## Authentication Flow

### 1. Đăng ký (Register)

```dart
final response = await AuthService.register(
  email: 'user@example.com',
  password: '123456',
  nickname: 'username',
  realname: 'Full Name',
  gender: 'male', // hoặc 'female'
  mainLanguage: 'vi',
  nationalityIso2: 'VN',
  schoolId: 1,
  departmentId: 1,
  enrollmentYear: 2024,
);
```

**Backend Response:**
```json
{
  "message": "User registered successfully"
}
```

### 2. Đăng nhập (Login)

```dart
final response = await AuthService.login(
  email: 'user@example.com',
  password: '123456',
);
```

**Backend Response:**
```json
{
  "access_token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "token_type": "bearer"
}
```

**Lưu trữ:**
- `isLoggedIn`: true
- `userEmail`: email
- `accessToken`: JWT token
- `userNickname`: nickname (từ email tạm thời)

### 3. Sử dụng Token

```dart
// Lấy token
final token = await AuthService.getAccessToken();

// Tạo headers với auth
final headers = await AuthService.getAuthHeaders();

// Gọi protected API
final response = await ApiService.post(
  '/api/board/1/posts',
  headers: headers,
  body: {'title': 'Test', 'content': 'Content'},
);
```

## API Endpoints

### Authentication

#### Register
- **Method**: POST
- **URL**: `/api/auth/register`
- **Body**: email, password, nickname, realname, gender, main_language, nationality_iso2, school_id, department_id, enrollment_year
- **Auth**: Không cần
- **Response**: `{message}`

#### Login
- **Method**: POST
- **URL**: `/api/auth/login`
- **Body**: email, password
- **Auth**: Không cần
- **Response**: `{access_token, token_type}`

### Community

#### Get Posts
- **Method**: GET
- **URL**: `/api/board/{board_id}/posts?limit=20`
- **Auth**: Không cần
- **Response**: Array of posts

```dart
final posts = await ApiService.get(
  ApiConfig.boardPostsEndpoint(1) + '?limit=10',
);
```

#### Create Post
- **Method**: POST
- **URL**: `/api/board/{board_id}/posts`
- **Auth**: Cần token
- **Body**: title, content, is_anonymous
- **Response**: Post object

```dart
final headers = await AuthService.getAuthHeaders();
final response = await ApiService.post(
  ApiConfig.createPostEndpoint(1),
  headers: headers,
  body: {
    'title': 'Tiêu đề',
    'content': 'Nội dung bài viết',
    'is_anonymous': false,
  },
);
```

### School

#### Get School Translation URL
- **Method**: GET
- **URL**: `/api/school/my-homepage-translation`
- **Auth**: Cần token
- **Response**: `{school_id, school_name, original_url, translated_url, target_language}`

```dart
final headers = await AuthService.getAuthHeaders();
final response = await ApiService.get(
  ApiConfig.schoolTranslationEndpoint,
  headers: headers,
);
```

### Matching

#### Create Match Request
- **Method**: POST
- **URL**: `/api/match_requests`
- **Auth**: Cần token
- **Body**: preferred_college_id, preferred_gender, notes
- **Response**: `{id, status}`

#### Find Helpers
- **Method**: GET
- **URL**: `/api/match_requests/{id}/find_helpers?limit=10`
- **Auth**: Cần token
- **Response**: Array of helpers

#### Send Message
- **Method**: POST
- **URL**: `/api/conversations/{conv_id}/messages`
- **Auth**: Cần token
- **Body**: content
- **Response**: `{message_id, created_at}`

#### Get Messages
- **Method**: GET
- **URL**: `/api/conversations/{conv_id}/messages`
- **Auth**: Cần token
- **Response**: Array of messages

## Error Handling

### API Exceptions

```dart
try {
  final response = await AuthService.login(...);
} on ApiException catch (e) {
  // Xử lý lỗi API
  print('API Error: ${e.message}');
  // Hiển thị cho user
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(e.message)),
  );
} catch (e) {
  // Xử lý lỗi khác
  print('Unknown Error: $e');
}
```

### Common Errors

| Status Code | Error | Giải pháp |
|-------------|-------|-----------|
| 401 | Unauthorized | Đăng nhập lại |
| 409 | Conflict | Email đã tồn tại |
| 500 | Server Error | Thử lại sau |
| Timeout | Connection Timeout | Retry tự động (3 lần) |
| Network | No Internet | Kiểm tra kết nối |

## Caching

### GET Requests tự động cache

```dart
// Lần đầu: Gọi API
final posts1 = await ApiService.get('/api/board/1/posts');

// Lần sau (trong 5 phút): Lấy từ cache
final posts2 = await ApiService.get('/api/board/1/posts');

// Force refresh
final posts3 = await ApiService.get('/api/board/1/posts', useCache: false);

// Clear cache
ApiService.clearCache();
```

## Retry Logic

### Tự động retry khi:
- Network error (SocketException)
- Timeout
- Server error (5xx)

### Retry settings:
- Số lần: 3
- Delay: 2s, 4s, 6s (exponential backoff)
- Chỉ retry cho server errors, không retry cho client errors (4xx)

## Render Cold Start

### Vấn đề
Render free tier sleep sau 15 phút không dùng. Request đầu tiên mất 30-60s.

### Giải pháp đã implement
- ✅ Timeout 30s
- ✅ Retry logic
- ✅ Loading indicator
- ✅ User-friendly error messages

### User Experience
1. User nhấn Login
2. Hiển thị loading (có thể mất 30s lần đầu)
3. Retry tự động nếu timeout
4. Thành công hoặc hiển thị error message

## Testing

### Test với Render Backend

```bash
# 1. Đảm bảo _isProduction = true
# 2. Run app
flutter run

# 3. Test đăng ký
# 4. Test đăng nhập
# 5. Test các features khác
```

### Test với Local Backend

```bash
# 1. Start backend
cd backend
python run.py

# 2. Đảm bảo _isProduction = false
# 3. Run app
flutter run
```

## Debugging

### Xem API calls

```dart
// Trong api_service.dart, thêm debug prints
print('🌐 API Call: ${ApiConfig.getFullUrl(endpoint)}');
print('📤 Request Body: $body');
print('📥 Response: $responseBody');
```

### Check logs

```bash
# Flutter logs
flutter logs

# Render logs
# Vào Render Dashboard → Web Service → Logs tab
```

## Best Practices

### 1. Always handle errors
```dart
try {
  final response = await ApiService.post(...);
} on ApiException catch (e) {
  // Handle API errors
} catch (e) {
  // Handle other errors
}
```

### 2. Show loading states
```dart
setState(() {
  _isLoading = true;
});
// ... API call
setState(() {
  _isLoading = false;
});
```

### 3. Use cache wisely
```dart
// Cache for read-only data
final posts = await ApiService.get('/api/board/1/posts');

// No cache for dynamic data
final messages = await ApiService.get(
  '/api/conversations/1/messages',
  useCache: false,
);
```

### 4. Clear cache on logout
```dart
await AuthService.logout(); // Tự động clear cache
```

## Checklist

- [x] API config với Render URL
- [x] Retry logic
- [x] Caching
- [x] Error handling
- [x] Login flow
- [x] Register flow
- [x] Token management
- [ ] Test tất cả endpoints
- [ ] Handle token expiration
- [ ] Implement refresh token (nếu cần)

## Support

Nếu gặp vấn đề:
1. Kiểm tra backend đang chạy: https://hi-campus-backend.onrender.com/
2. Xem logs trong Render Dashboard
3. Test với Postman trước
4. Check network connectivity
5. Verify API config

## Summary

✅ Frontend đã sẵn sàng sử dụng API thật từ Render
✅ Tối ưu hóa performance và error handling
✅ Hỗ trợ cả development và production
✅ Retry logic cho Render cold start
✅ Caching để giảm API calls

Chúc bạn code vui vẻ! 🎉

