# Frontend Optimization Notes

## Đã tối ưu hóa

### 1. API Configuration (`lib/services/api_config.dart`)
- ✅ Thêm environment-based URLs (Production/Development)
- ✅ Sử dụng Render URL cho production: `https://hi-campus-backend.onrender.com`
- ✅ Tăng timeout lên 30s để xử lý Render cold start
- ✅ Thêm retry settings (3 lần, delay 2s)
- ✅ Thêm cache timeout (5 phút)
- ✅ Thêm helper methods cho tất cả endpoints

### 2. API Service (`lib/services/api_service.dart`)
- ✅ Thêm retry logic với exponential backoff
- ✅ Implement in-memory caching cho GET requests
- ✅ Thêm GET, PUT, DELETE methods
- ✅ Cải thiện error handling với messages chi tiết
- ✅ Hỗ trợ Render cold start (retry khi timeout)
- ✅ Cache management (clear cache, clear entry)

### 3. Main App (`lib/main.dart`)
- ✅ Thêm loading state khi khởi tạo app
- ✅ Optimize changeLanguage với early return
- ✅ Lazy route generation với onGenerateRoute
- ✅ Error handling trong _loadAppState

### 4. Performance Utils (`lib/utils/performance_utils.dart`)
- ✅ Debounce và throttle utilities
- ✅ Widget visibility checker
- ✅ Image preloading helper
- ✅ LazyLoadWidget wrapper

## Cần tối ưu thêm

### 1. State Management
- [ ] Xem xét dùng Riverpod hoặc GetX thay vì Provider
- [ ] Implement proper state persistence
- [ ] Add state hydration

### 2. Images
- [ ] Thêm `cached_network_image` package
- [ ] Implement image compression
- [ ] Add placeholder và error widgets

### 3. Lists
- [ ] Implement pagination cho danh sách bài viết
- [ ] Add pull-to-refresh
- [ ] Lazy loading cho long lists

### 4. Build Optimization
- [ ] Thêm nhiều `const` constructors
- [ ] Use `RepaintBoundary` cho complex widgets
- [ ] Implement `AutomaticKeepAliveClientMixin` cho tabs

### 5. Network
- [ ] Xem xét dùng Dio thay vì http package
- [ ] Implement request cancellation
- [ ] Add request/response interceptors

## Cách sử dụng

### Chuyển đổi môi trường
Trong `lib/services/api_config.dart`:
```dart
static const bool _isProduction = true;  // Production (Render)
static const bool _isProduction = false; // Development (Local)
```

### Sử dụng cache
```dart
// Với cache (mặc định)
final data = await ApiService.get('/api/board/1/posts');

// Không cache
final data = await ApiService.get('/api/board/1/posts', useCache: false);

// Clear cache
ApiService.clearCache();

// Clear specific endpoint
ApiService.clearCacheEntry('/api/board/1/posts');
```

### Retry logic
- Tự động retry 3 lần khi gặp lỗi server (5xx) hoặc network error
- Delay giữa các lần retry: 2s, 4s, 6s (exponential backoff)
- Đặc biệt hữu ích cho Render cold start

## Performance Tips

1. **Render Cold Start**: 
   - Lần đầu request có thể mất 30-60s
   - Retry logic sẽ tự động xử lý
   - Hiển thị loading indicator cho user

2. **Caching**:
   - GET requests được cache 5 phút
   - Giảm số lượng API calls
   - Clear cache khi cần dữ liệu mới

3. **Error Handling**:
   - Hiển thị messages rõ ràng cho user
   - Log errors để debug
   - Graceful degradation

4. **Build Performance**:
   - Sử dụng `const` constructors khi có thể
   - Wrap complex widgets với `RepaintBoundary`
   - Lazy load screens và widgets

## Testing

### Test với Production URL
```bash
# Trong api_config.dart, set:
static const bool _isProduction = true;

# Chạy app
flutter run
```

### Test với Local URL
```bash
# Trong api_config.dart, set:
static const bool _isProduction = false;

# Đảm bảo backend đang chạy local
cd backend
python run.py

# Chạy app
flutter run
```

## Monitoring

Theo dõi performance metrics:
- API response time
- Cache hit rate
- Error rate
- App startup time
- Frame rendering time

Sử dụng Flutter DevTools để profile app.

