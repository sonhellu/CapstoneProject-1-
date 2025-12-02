# Services Guide - Hi-Campus Frontend

## Tổng quan

Đã tạo 5 services để tương tác với backend API:

1. **ApiService** - Base HTTP service (GET, POST, PUT, DELETE)
2. **AuthService** - Authentication (Login, Register, Token)
3. **CommunityService** - Boards và Posts
4. **SchoolService** - School translation
5. **MatchingService** - Matching và Chat

---

## 1. ApiService (api_service.dart)

### Base HTTP methods với retry và caching

```dart
// GET với cache
final data = await ApiService.get('/api/board/1/posts');

// GET không cache
final data = await ApiService.get('/api/board/1/posts', useCache: false);

// POST
final result = await ApiService.post(
  '/api/auth/login',
  body: {'email': 'test@example.com', 'password': '123456'},
);

// PUT
final result = await ApiService.put(
  '/api/users/1',
  body: {'nickname': 'newnick'},
);

// DELETE
final result = await ApiService.delete('/api/posts/1');

// Clear cache
ApiService.clearCache();
ApiService.clearCacheEntry('/api/board/1/posts');
```

---

## 2. AuthService (auth_service.dart)

### Authentication và token management

```dart
// Đăng ký
await AuthService.register(
  email: 'user@example.com',
  password: '123456',
  nickname: 'username',
  realname: 'Full Name',
  gender: 'male',
  mainLanguage: 'vi',
  nationalityIso2: 'VN',
  schoolId: 1,
  departmentId: 1,
  enrollmentYear: 2024,
);

// Đăng nhập
final response = await AuthService.login(
  email: 'user@example.com',
  password: '123456',
);
// Response: {message, access_token}

// Kiểm tra login status
final isLoggedIn = await AuthService.isLoggedIn();

// Lấy thông tin user
final email = await AuthService.getUserEmail();
final nickname = await AuthService.getUserNickname();
final token = await AuthService.getAccessToken();

// Lấy headers với auth
final headers = await AuthService.getAuthHeaders();
// Headers: {Content-Type, Accept, Authorization: Bearer <token>}

// Logout
await AuthService.logout();
```

---

## 3. CommunityService (community_service.dart)

### Boards và Posts

```dart
// Lấy danh sách bài viết
final posts = await CommunityService.getPosts(
  boardId: 1,
  limit: 20,
  useCache: true,
);
// Returns: List<dynamic>

// Tạo bài viết mới
final post = await CommunityService.createPost(
  boardId: 1,
  title: 'Tiêu đề bài viết',
  content: 'Nội dung bài viết...',
  isAnonymous: false,
);
// Returns: Map<String, dynamic>

// Refresh posts (force reload)
final posts = await CommunityService.refreshPosts(
  boardId: 1,
  limit: 20,
);
```

### Board IDs
```dart
1 = 공지게시판 (Notice)
2 = 자유게시판 (Free)
3 = 정보게시판 (Info)
4 = 홍보게시판 (Promo)
```

---

## 4. SchoolService (school_service.dart)

### School translation

```dart
// Lấy thông tin dịch trang chủ trường
final data = await SchoolService.getMySchoolTranslation();
// Returns: {school_id, school_name, original_url, translated_url, target_language}

// Chỉ lấy URL đã dịch
final translatedUrl = await SchoolService.getTranslatedSchoolUrl();
// Returns: String (Google Translate URL)

// Lấy thông tin trường
final info = await SchoolService.getSchoolInfo();
// Returns: {school_id, school_name, original_url, target_language}
```

### Sử dụng trong UI
```dart
// Mở URL trong WebView hoặc browser
final url = await SchoolService.getTranslatedSchoolUrl();
// Launch URL với url_launcher package
```

---

## 5. MatchingService (matching_service.dart)

### Matching và Chat

```dart
// Tạo yêu cầu tìm helper
final request = await MatchingService.createMatchRequest(
  preferredCollegeId: 1,
  preferredGender: 'female', // male/female/any
  notes: 'Tôi muốn học tiếng Hàn...',
);
// Returns: {id, status: "pending"}

// Tìm helper phù hợp
final helpers = await MatchingService.findHelpers(
  requestId: 1,
  limit: 10,
);
// Returns: List<{id, nickname}>

// Đề xuất helper
final offer = await MatchingService.offerMatch(
  requestId: 1,
  mentorUserId: 5,
);
// Returns: {request_id, status: "offered", offered_to}

// Chấp nhận kết nối
final match = await MatchingService.acceptMatch(
  requestId: 1,
  mentorUserId: 5,
);
// Returns: {match_id, conversation_id}

// Gửi tin nhắn
final message = await MatchingService.sendMessage(
  conversationId: 1,
  content: 'Hello!',
);
// Returns: {message_id, created_at}

// Lấy danh sách tin nhắn
final messages = await MatchingService.getMessages(
  conversationId: 1,
  useCache: false,
);
// Returns: List<{id, sender_user_id, content, created_at}>

// Refresh messages
final messages = await MatchingService.refreshMessages(
  conversationId: 1,
);
```

---

## Error Handling

### Try-Catch Pattern

```dart
try {
  final result = await CommunityService.getPosts(boardId: 1);
  // Success
} on ApiException catch (e) {
  // API error với message rõ ràng
  print('API Error: ${e.message}');
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(e.message)),
  );
} catch (e) {
  // Other errors
  print('Unknown Error: $e');
}
```

### Common Errors

| Error | Nguyên nhân | Giải pháp |
|-------|-------------|-----------|
| `ApiException: 401` | Token hết hạn hoặc invalid | Đăng nhập lại |
| `ApiException: 403` | Không có quyền | Kiểm tra permissions |
| `ApiException: 404` | Resource không tồn tại | Kiểm tra ID |
| `ApiException: 409` | Conflict (email đã tồn tại) | Dùng email khác |
| `ApiException: timeout` | Server chậm hoặc cold start | Retry tự động |
| `ApiException: network` | Không có internet | Kiểm tra kết nối |

---

## Loading States

### Pattern cho UI

```dart
class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  bool _isLoading = false;
  List<dynamic> _data = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await CommunityService.getPosts(boardId: 1);
      setState(() {
        _data = data;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _data.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }
    
    if (_error != null && _data.isEmpty) {
      return Center(
        child: Column(
          children: [
            Text(_error!),
            ElevatedButton(
              onPressed: _loadData,
              child: Text('Thử lại'),
            ),
          ],
        ),
      );
    }
    
    if (_data.isEmpty) {
      return Center(child: Text('Không có dữ liệu'));
    }
    
    return ListView.builder(
      itemCount: _data.length,
      itemBuilder: (_, i) => ListTile(title: Text(_data[i].toString())),
    );
  }
}
```

---

## Caching Strategy

### GET requests
- Tự động cache 5 phút
- Clear cache khi:
  - Logout
  - Tạo/Update/Delete resource
  - User yêu cầu refresh

### POST/PUT/DELETE
- Không cache
- Clear related cache sau khi success

### Example
```dart
// Load posts (với cache)
final posts = await CommunityService.getPosts(boardId: 1);

// Tạo post mới
await CommunityService.createPost(...);
// → Tự động clear cache của board 1

// Load lại posts (từ server)
final newPosts = await CommunityService.getPosts(boardId: 1);
```

---

## Authentication Flow

### Complete Flow

```dart
// 1. Đăng ký
await AuthService.register(...);

// 2. Đăng nhập
await AuthService.login(email, password);
// → Lưu token vào SharedPreferences

// 3. Gọi protected API
final headers = await AuthService.getAuthHeaders();
await ApiService.post('/api/board/1/posts', headers: headers, body: {...});

// 4. Logout
await AuthService.logout();
// → Clear token và cache
```

---

## Best Practices

### 1. Always handle errors
```dart
try {
  final result = await SomeService.someMethod();
} on ApiException catch (e) {
  // Show user-friendly message
} catch (e) {
  // Log error
}
```

### 2. Show loading states
```dart
setState(() { _isLoading = true; });
try {
  final data = await SomeService.getData();
} finally {
  setState(() { _isLoading = false; });
}
```

### 3. Use cache wisely
```dart
// Cache cho data ít thay đổi
final schools = await ApiService.get('/api/schools');

// Không cache cho data realtime
final messages = await MatchingService.getMessages(
  conversationId: 1,
  useCache: false,
);
```

### 4. Clear cache appropriately
```dart
// Sau khi tạo post
await CommunityService.createPost(...);
// Service tự động clear cache

// Sau khi logout
await AuthService.logout();
// Tự động clear tất cả cache
```

---

## Testing

### Test từng service

```dart
// Test AuthService
final response = await AuthService.login(
  email: 'test@example.com',
  password: '123456',
);
print('Token: ${response['access_token']}');

// Test CommunityService
final posts = await CommunityService.getPosts(boardId: 1);
print('Posts count: ${posts.length}');

// Test SchoolService
final url = await SchoolService.getTranslatedSchoolUrl();
print('Translated URL: $url');

// Test MatchingService
final request = await MatchingService.createMatchRequest(
  preferredGender: 'any',
);
print('Request ID: ${request['id']}');
```

---

## Troubleshooting

### Token expired
```dart
// Catch 401 error
try {
  await SomeService.protectedMethod();
} on ApiException catch (e) {
  if (e.message.contains('401') || e.message.contains('expired')) {
    // Redirect to login
    Navigator.pushReplacementNamed(context, '/login');
  }
}
```

### Network timeout
- Retry tự động 3 lần
- Hiển thị loading với message
- Cho phép user cancel hoặc retry manual

### Cache stale data
```dart
// Force refresh
final data = await CommunityService.refreshPosts(boardId: 1);

// Hoặc
ApiService.clearCache();
final data = await CommunityService.getPosts(boardId: 1);
```

---

## Summary

✅ **5 Services đã sẵn sàng**
- ApiService: Base HTTP với retry + cache
- AuthService: JWT authentication
- CommunityService: Posts CRUD
- SchoolService: Translation
- MatchingService: Matching + Chat

✅ **Features**
- Retry logic (3 lần)
- In-memory caching (5 phút)
- Error handling
- Loading states
- Token management

✅ **Production Ready**
- Backend URL: https://hi-campus-backend.onrender.com
- Timeout: 30s (handle cold start)
- CORS configured
- Security: JWT tokens

🚀 **Sẵn sàng sử dụng!**

