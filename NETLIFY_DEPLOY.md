# Hướng dẫn Deploy Flutter Web lên Netlify

## Bước 1: Chuẩn bị

### 1.1. Đảm bảo Flutter đã cài đặt
```bash
flutter --version
```

### 1.2. Enable Flutter Web (nếu chưa)
```bash
flutter config --enable-web
```

### 1.3. Build Flutter Web locally để test
```bash
cd frontend
flutter build web --release
```

Kiểm tra build thành công tại `frontend/build/web/`

---

## Bước 2: Cấu hình Netlify

### 2.1. Đăng nhập Netlify
1. Truy cập [https://app.netlify.com](https://app.netlify.com)
2. Đăng nhập bằng GitHub/GitLab/Bitbucket

### 2.2. Kết nối Repository
1. Click **"Add new site"** → **"Import an existing project"**
2. Chọn **"Deploy with GitHub"** (hoặc GitLab/Bitbucket)
3. Chọn repository của bạn
4. Chọn branch `main` (hoặc branch bạn muốn deploy)

### 2.3. Cấu hình Build Settings

Netlify sẽ tự động detect `netlify.toml` file, nhưng bạn có thể cấu hình thủ công:

**Build settings:**
- **Base directory:** `frontend`
- **Build command:** `flutter build web --release`
- **Publish directory:** `frontend/build/web`

**Environment variables (nếu cần):**
- `FLUTTER_VERSION`: `3.9.2` (hoặc version bạn đang dùng)

### 2.4. Deploy

1. Click **"Deploy site"**
2. Netlify sẽ:
   - Install Flutter SDK
   - Run `flutter build web --release`
   - Deploy files từ `frontend/build/web`

---

## Bước 3: Cấu hình Custom Domain (Optional)

1. Vào **Site settings** → **Domain management**
2. Click **"Add custom domain"**
3. Nhập domain của bạn
4. Follow instructions để setup DNS

---

## Bước 4: Continuous Deployment

Mỗi khi push code lên Git:
- Netlify tự động detect changes
- Tự động build và deploy
- Bạn có thể xem logs trong **Deploys** tab

---

## Troubleshooting

### Lỗi: Flutter not found
- Đảm bảo `FLUTTER_VERSION` trong environment variables đúng
- Hoặc thêm build plugin: `netlify-plugin-flutter`

### Lỗi: Build timeout
- Tăng build timeout trong **Site settings** → **Build & deploy** → **Build settings**
- Default: 15 minutes

### Lỗi: Routing không hoạt động
- Đảm bảo file `_redirects` trong `frontend/web/` có nội dung: `/*    /index.html   200`
- Hoặc cấu hình redirect trong `netlify.toml`

### Lỗi: API calls bị CORS
- Backend đã có CORS config, nhưng nếu vẫn lỗi:
  - Kiểm tra `ApiConfig` trong frontend có đúng URL không
  - Thêm domain frontend vào CORS whitelist trong backend

---

## Cấu trúc Files

```
project-root/
├── netlify.toml          # Netlify configuration
├── frontend/
│   ├── web/
│   │   ├── _redirects    # Routing redirects
│   │   └── index.html
│   └── build/
│       └── web/          # Build output (gitignored)
```

---

## Lưu ý

1. **Build time:** Flutter web build có thể mất 5-10 phút
2. **Build size:** Flutter web apps thường lớn (5-10MB), Netlify free plan có giới hạn
3. **API URL:** Đảm bảo `ApiConfig` trong frontend trỏ đúng backend URL
4. **Environment:** Có thể set environment variables trong Netlify dashboard

---

## Quick Deploy Commands

### Deploy từ local (nếu có Netlify CLI)
```bash
# Install Netlify CLI
npm install -g netlify-cli

# Login
netlify login

# Build
cd frontend
flutter build web --release

# Deploy
netlify deploy --prod --dir=build/web
```

---

## Links hữu ích

- [Netlify Docs](https://docs.netlify.com/)
- [Flutter Web Deployment](https://docs.flutter.dev/deployment/web)
- [Netlify Build Plugins](https://docs.netlify.com/configure-builds/build-plugins/)

