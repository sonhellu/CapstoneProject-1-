import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppLocalizations {
  final Locale locale;
  
  AppLocalizations(this.locale);
  
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }
  
  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();
  
  static const List<LocalizationsDelegate> localizationsDelegates = [
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
  
  static const List<Locale> supportedLocales = [
    Locale('en', ''),
    Locale('ko', ''),
    Locale('vi', ''),
    Locale('zh', ''),
    Locale('ja', ''),
    Locale('my', ''),
  ];
  
  // English translations
  static const Map<String, String> _en = {
    'appTitle': 'Hi Campus',
    'login': 'Login',
    'register': 'Register',
    'email': 'Email',
    'password': 'Password',
    'confirmPassword': 'Confirm Password',
    'loginButton': 'Login',
    'registerButton': 'Register',
    'alreadyHaveAccount': 'Already have an account?',
    'dontHaveAccount': 'Don\'t have an account?',
    'home': 'Home',
    'profile': 'Profile',
    'chat': 'Chat',
    'language': 'Language',
    'selectLanguage': 'Select Language',
    'english': 'English',
    'korean': '한국어',
    'vietnamese': 'Tiếng Việt',
    'welcome': 'Welcome to Hi Campus',
    'welcomeMessage': 'Your journey in Korea starts here',
    'fullName': 'Full Name',
    'university': 'University',
    'major': 'Major',
    'year': 'Year',
    'nationality': 'Nationality',
    'selectUniversity': 'Select University',
    'selectMajor': 'Select Major',
    'selectYear': 'Select Year',
    'selectNationality': 'Select Nationality',
    'save': 'Save',
    'editProfile': 'Edit Profile',
    'logout': 'Logout',
    'emailRequired': 'Email is required',
    'emailInvalid': 'Please enter a valid email',
    'passwordRequired': 'Password is required',
    'passwordTooShort': 'Password must be at least 6 characters',
    'passwordMismatch': 'Passwords do not match',
    'nameRequired': 'Name is required',
    'universityRequired': 'University is required',
    'majorRequired': 'Major is required',
    'yearRequired': 'Year is required',
    'nationalityRequired': 'Nationality is required',
    'featuredNews': 'Featured News',
    'news': 'News',
    'visitOfficialWebsite': 'Visit Official Website',
    'languageOrder': 'Language Order',
    'selectLanguageToLearn': 'Select the language (country) you want to learn',
    'selectLanguageToLearnLabel': 'Language (Country) to Learn *',
    'selectLanguageToLearnRequired': 'Please select the language (country) you want to learn',
    'preferredGender': 'Preferred Gender',
    'college': 'College',
    'findMatch': 'Find Matching Partner',
    'languageExchangeMatching': 'Language Exchange Matching',
    'moreOptions': 'More Options',
    'loadingOnlineUsers': 'Loading online users...',
    'errorOccurred': 'An error occurred',
    'retry': 'Retry',
    'noMatchFound': 'No matching partner found',
    'targetLanguage': 'Target Language',
    'changeConditions': 'Change Conditions',
    'onlineUsers': 'Online Users',
    'online': 'Online',
    'viewMore': 'View More',
    'writePost': 'Write Post',
    'title': 'Title',
    'titleRequired': 'Please enter a title',
    'content': 'Content',
    'contentRequired': 'Please enter content',
    'postAnonymously': 'Post Anonymously',
    'cancel': 'Cancel',
    'post': 'Post',
    'noSearchResults': 'No search results found',
    'edit': 'Edit',
    'previous': 'Previous',
    'saveProfile': 'Save Profile',
    'profileUpdatedSuccessfully': 'Profile updated successfully!',
    'searchNews': 'Search News',
    'search': 'Search',
    'next': 'Next',
    'enterSearchKeyword': 'Enter search keyword...',
    'errorSendingMessage': 'Error sending message',
    'conversationId': 'Conversation ID',
    'noConversationsYet': 'No conversations yet',
    'startConversation': 'Start a conversation with someone!',
    'international': 'International',
    'domestic': 'Domestic',
    'national': 'National',
    'board': 'Board',
    'noticeBoard': 'Notice Board',
    'freeBoard': 'Free Board',
    'infoBoard': 'Info Board',
    'promoBoard': 'Promo Board',
    'step': 'Step',
    'personalInformation': 'Personal Information',
    'profileSetup': 'Profile Setup',
    'schoolInformation': 'School Information',
    'reviewAndComplete': 'Review & Complete',
    'completeRegistration': 'Complete Registration',
    'user': 'User',
    'student': 'Student',
    'name': 'Name',
    'notProvided': 'Not provided',
    'studentEmail': 'Student Email (@stu)',
    'realName': 'Real Name',
    'nickname': 'Nickname',
    'mainLanguage': 'Main Language',
    'schoolId': 'School ID',
    'school': 'School',
    'department': 'Department',
    'pleaseFillAllFields': 'Please fill in all required fields',
    'languageChangedTo': 'Language changed to',
    '1stYear': '1st Year',
    '2ndYear': '2nd Year',
    '3rdYear': '3rd Year',
    '4thYear': '4th Year',
    'graduateStudent': 'Graduate Student',
    'phdStudent': 'PhD Student',
    'newsDetail': 'News Detail',
    'internationalNews': 'International News',
    'domesticNews': 'Domestic News',
    'close': 'Close',
    'select': 'Select',
    'confirm': 'Confirm',
    'shareComingSoon': 'Share functionality coming soon!',
    'savedToFavorites': 'Saved to favorites!',
    'likedPost': 'Liked the post!',
    'like': 'Like',
    'bookmark': 'Bookmark',
    'bookmarkComingSoon': 'Bookmark functionality coming soon!',
    'postPublishedSuccessfully': 'Post published successfully!',
    'registrationSuccessful': 'Registration successful! Please login.',
    'likeFunctionalityComingSoon': 'Like functionality coming soon!',
    'noNewsAvailable': 'No news available',
    'noResultsFound': 'No results found',
    'enterMessage': 'Enter message',
    'enrollmentYear': 'Enrollment Year',
    'tellUsAboutAcademicBackground': 'Tell us about your academic background',
    'southKorea': 'South Korea',
    'vietnam': 'Vietnam',
    'unitedStates': 'United States',
    'japan': 'Japan',
    'china': 'China',
    'myanmar': 'Myanmar',
    'chinese': '中文',
    'japanese': '日本語',
  };
  
  // Korean translations
  static const Map<String, String> _ko = {
    'appTitle': 'Hi Campus',
    'login': '로그인',
    'register': '회원가입',
    'email': '이메일',
    'password': '비밀번호',
    'confirmPassword': '비밀번호 확인',
    'loginButton': '로그인',
    'registerButton': '회원가입',
    'alreadyHaveAccount': '이미 계정이 있으신가요?',
    'dontHaveAccount': '계정이 없으신가요?',
    'home': '홈',
    'profile': '프로필',
    'chat': '채팅',
    'language': '언어',
    'selectLanguage': '언어 선택',
    'english': 'English',
    'korean': '한국어',
    'vietnamese': 'Tiếng Việt',
    'welcome': '하이 캠퍼스에 오신 것을 환영합니다',
    'welcomeMessage': '한국에서의 여정이 여기서 시작됩니다',
    'fullName': '성명',
    'university': '대학교',
    'major': '전공',
    'year': '학년',
    'nationality': '국적',
    'selectUniversity': '대학교 선택',
    'selectMajor': '전공 선택',
    'selectYear': '학년 선택',
    'selectNationality': '국적 선택',
    'save': '저장',
    'editProfile': '프로필 편집',
    'logout': '로그아웃',
    'emailRequired': '이메일을 입력해주세요',
    'emailInvalid': '올바른 이메일을 입력해주세요',
    'passwordRequired': '비밀번호를 입력해주세요',
    'passwordTooShort': '비밀번호는 최소 6자 이상이어야 합니다',
    'passwordMismatch': '비밀번호가 일치하지 않습니다',
    'nameRequired': '이름을 입력해주세요',
    'universityRequired': '대학교를 선택해주세요',
    'majorRequired': '전공을 선택해주세요',
    'yearRequired': '학년을 선택해주세요',
    'nationalityRequired': '국적을 선택해주세요',
    'featuredNews': '주요 뉴스',
    'news': '뉴스',
    'visitOfficialWebsite': '공식 웹사이트 방문',
    'languageOrder': '언어교류 주문',
    'selectLanguageToLearn': '배우고 싶은 언어(국가), 성별, 단과대학을 선택하세요',
    'selectLanguageToLearnLabel': '배우고 싶은 언어(국가) *',
    'selectLanguageToLearnRequired': '배우고 싶은 언어(국가)를 선택해주세요',
    'preferredGender': '선호 성별',
    'college': '단과대학',
    'findMatch': '조건에 맞는 상대 찾기',
    'languageExchangeMatching': '언어교류 매칭',
    'moreOptions': '더 많은 옵션',
    'loadingOnlineUsers': '온라인 사용자 로딩 중...',
    'errorOccurred': '문제가 발생했어요',
    'retry': '다시 시도',
    'noMatchFound': '조건에 맞는 상대를 찾지 못했어요',
    'targetLanguage': '대상 언어',
    'changeConditions': '조건 변경하기',
    'onlineUsers': '온라인 사용자',
    'online': '온라인',
    'viewMore': '더보기',
    'writePost': '게시글 작성',
    'title': '제목',
    'titleRequired': '제목을 입력해주세요',
    'content': '내용',
    'contentRequired': '내용을 입력해주세요',
    'postAnonymously': '익명으로 작성',
    'cancel': '취소',
    'post': '게시하기',
    'noSearchResults': '검색 결과가 없습니다',
    'edit': '편집',
    'previous': '이전',
    'saveProfile': '프로필 저장',
    'profileUpdatedSuccessfully': '프로필이 성공적으로 업데이트되었습니다!',
    'searchNews': '뉴스 검색',
    'search': '검색',
    'next': '다음',
    'enterSearchKeyword': '검색어를 입력하세요...',
    'errorSendingMessage': '메시지 전송 오류',
    'conversationId': '대화 ID',
    'noConversationsYet': '아직 대화가 없습니다',
    'startConversation': '누군가와 대화를 시작하세요!',
    'international': '국제',
    'domestic': '국내',
    'national': '국가',
    'board': '게시판',
    'noticeBoard': '공지게시판',
    'freeBoard': '자유게시판',
    'infoBoard': '정보게시판',
    'promoBoard': '홍보게시판',
    'step': '단계',
    'personalInformation': '개인 정보',
    'profileSetup': '프로필 설정',
    'schoolInformation': '학교 정보',
    'reviewAndComplete': '검토 및 완료',
    'completeRegistration': '등록 완료',
    'user': '사용자',
    'student': '학생',
    'name': '이름',
    'notProvided': '제공되지 않음',
    'studentEmail': '학생 이메일 (@stu)',
    'realName': '실명',
    'nickname': '닉네임',
    'mainLanguage': '주 언어',
    'schoolId': '학교 ID',
    'school': '학교',
    'department': '학과',
    'pleaseFillAllFields': '모든 필수 필드를 입력해주세요',
    'languageChangedTo': '언어가 다음으로 변경되었습니다',
    '1stYear': '1학년',
    '2ndYear': '2학년',
    '3rdYear': '3학년',
    '4thYear': '4학년',
    'graduateStudent': '대학원생',
    'phdStudent': '박사과정',
    'newsDetail': '뉴스 상세',
    'internationalNews': '국제 뉴스',
    'domesticNews': '국내 뉴스',
    'close': '닫기',
    'select': '선택',
    'confirm': '확인',
    'shareComingSoon': '공유 기능이 곧 제공될 예정입니다!',
    'savedToFavorites': '즐겨찾기에 저장되었습니다!',
    'likedPost': '게시물을 좋아합니다!',
    'like': '좋아요',
    'bookmark': '북마크',
    'bookmarkComingSoon': '북마크 기능이 곧 제공될 예정입니다!',
    'postPublishedSuccessfully': '게시물이 성공적으로 게시되었습니다!',
    'registrationSuccessful': '등록이 완료되었습니다! 로그인해주세요.',
    'likeFunctionalityComingSoon': '좋아요 기능이 곧 제공될 예정입니다!',
    'noNewsAvailable': '뉴스가 없습니다',
    'noResultsFound': '결과를 찾을 수 없습니다',
    'enterMessage': '메시지를 입력하세요',
    'enrollmentYear': '입학 연도',
    'tellUsAboutAcademicBackground': '학력에 대해 알려주세요',
    'southKorea': '대한민국',
    'vietnam': '베트남',
    'unitedStates': '미국',
    'japan': '일본',
    'china': '중국',
    'myanmar': '미얀마',
    'chinese': '中文',
    'japanese': '日本語',
    'username': '사용자 이름',
    'basicInformation': '기본 정보',
    'pleaseProvideBasicInformation': '기본 정보를 제공해주세요',
    'reviewAndSave': '검토 및 저장',
    'pleaseReviewInformation': '저장하기 전에 정보를 검토해주세요',
  };
  
  // Vietnamese translations
  static const Map<String, String> _vi = {
    'appTitle': 'Hi Campus',
    'login': 'Đăng nhập',
    'register': 'Đăng ký',
    'email': 'Email',
    'password': 'Mật khẩu',
    'confirmPassword': 'Xác nhận mật khẩu',
    'loginButton': 'Đăng nhập',
    'registerButton': 'Đăng ký',
    'alreadyHaveAccount': 'Đã có tài khoản?',
    'dontHaveAccount': 'Chưa có tài khoản?',
    'home': 'Trang chủ',
    'profile': 'Cá nhân',
    'chat': 'Tin Nhắn',
    'language': 'Ngôn ngữ',
    'selectLanguage': 'Chọn ngôn ngữ',
    'english': 'English',
    'korean': '한국어',
    'vietnamese': 'Tiếng Việt',
    'welcome': 'Chào mừng đến với Hello Campus',
    'welcomeMessage': 'Hành trình của bạn tại Hàn Quốc bắt đầu từ đây',
    'fullName': 'Họ và tên',
    'university': 'Trường đại học',
    'major': 'Chuyên ngành',
    'year': 'Năm học',
    'nationality': 'Quốc tịch',
    'selectUniversity': 'Chọn trường đại học',
    'selectMajor': 'Chọn chuyên ngành',
    'selectYear': 'Chọn năm học',
    'selectNationality': 'Chọn quốc tịch',
    'save': 'Lưu',
    'editProfile': 'Chỉnh sửa thông tin',
    'logout': 'Đăng xuất',
    'emailRequired': 'Vui lòng nhập email',
    'emailInvalid': 'Vui lòng nhập email hợp lệ',
    'passwordRequired': 'Vui lòng nhập mật khẩu',
    'passwordTooShort': 'Mật khẩu phải có ít nhất 6 ký tự',
    'passwordMismatch': 'Mật khẩu không khớp',
    'nameRequired': 'Vui lòng nhập tên',
    'universityRequired': 'Vui lòng chọn trường đại học',
    'majorRequired': 'Vui lòng chọn chuyên ngành',
    'yearRequired': 'Vui lòng chọn năm học',
    'nationalityRequired': 'Vui lòng chọn quốc tịch',
    'featuredNews': 'Tin tức nổi bật',
    'news': 'Tin tức',
    'visitOfficialWebsite': 'Truy cập trang web chính thức',
    'languageOrder': 'Đặt hàng ngôn ngữ',
    'selectLanguageToLearn': 'Chọn ngôn ngữ (quốc gia) bạn muốn học',
    'selectLanguageToLearnLabel': 'Ngôn ngữ (Quốc gia) muốn học *',
    'selectLanguageToLearnRequired': 'Vui lòng chọn ngôn ngữ (quốc gia) bạn muốn học',
    'preferredGender': 'Giới tính ưu tiên',
    'college': 'Khoa',
    'findMatch': 'Tìm đối tác phù hợp',
    'languageExchangeMatching': 'Kết nối trao đổi ngôn ngữ',
    'moreOptions': 'Tùy chọn thêm',
    'loadingOnlineUsers': 'Đang tải người dùng online...',
    'errorOccurred': 'Đã xảy ra lỗi',
    'retry': 'Thử lại',
    'noMatchFound': 'Không tìm thấy đối tác phù hợp',
    'targetLanguage': 'Ngôn ngữ mục tiêu',
    'changeConditions': 'Thay đổi điều kiện',
    'onlineUsers': 'Người dùng online',
    'online': 'Online',
    'viewMore': 'Xem thêm',
    'writePost': 'Viết bài',
    'title': 'Tiêu đề',
    'titleRequired': 'Vui lòng nhập tiêu đề',
    'content': 'Nội dung',
    'contentRequired': 'Vui lòng nhập nội dung',
    'postAnonymously': 'Đăng ẩn danh',
    'cancel': 'Hủy',
    'post': 'Đăng bài',
    'noSearchResults': 'Không tìm thấy kết quả',
    'edit': 'Chỉnh sửa',
    'previous': 'Trước',
    'saveProfile': 'Lưu hồ sơ',
    'profileUpdatedSuccessfully': 'Cập nhật hồ sơ thành công!',
    'searchNews': 'Tìm kiếm tin tức',
    'search': 'Tìm kiếm',
    'next': 'Tiếp theo',
    'enterSearchKeyword': 'Nhập từ khóa tìm kiếm...',
    'errorSendingMessage': 'Lỗi khi gửi tin nhắn',
    'conversationId': 'ID cuộc trò chuyện',
    'noConversationsYet': 'Chưa có cuộc trò chuyện nào',
    'startConversation': 'Bắt đầu trò chuyện với ai đó!',
    'international': 'Quốc tế',
    'domestic': 'Trong nước',
    'national': 'Quốc gia',
    'board': 'Bảng tin',
    'noticeBoard': 'Bảng thông báo',
    'freeBoard': 'Bảng tự do',
    'infoBoard': 'Bảng thông tin',
    'promoBoard': 'Bảng quảng cáo',
    'step': 'Bước',
    'personalInformation': 'Thông tin cá nhân',
    'profileSetup': 'Thiết lập hồ sơ',
    'schoolInformation': 'Thông tin trường học',
    'reviewAndComplete': 'Xem lại & Hoàn tất',
    'completeRegistration': 'Hoàn tất đăng ký',
    'user': 'Người dùng',
    'student': 'Sinh viên',
    'name': 'Tên',
    'notProvided': 'Chưa cung cấp',
    'studentEmail': 'Email sinh viên (@stu)',
    'realName': 'Tên thật',
    'nickname': 'Biệt danh',
    'mainLanguage': 'Ngôn ngữ chính',
    'schoolId': 'ID trường học',
    'school': 'Trường học',
    'department': 'Khoa',
    'pleaseFillAllFields': 'Vui lòng điền tất cả các trường bắt buộc',
    'languageChangedTo': 'Ngôn ngữ đã thay đổi thành',
    '1stYear': 'Năm 1',
    '2ndYear': 'Năm 2',
    '3rdYear': 'Năm 3',
    '4thYear': 'Năm 4',
    'graduateStudent': 'Sinh viên sau đại học',
    'phdStudent': 'Nghiên cứu sinh',
    'newsDetail': 'Chi tiết tin tức',
    'internationalNews': 'Tin tức quốc tế',
    'domesticNews': 'Tin tức trong nước',
    'close': 'Đóng',
    'select': 'Chọn',
    'confirm': 'Xác nhận',
    'shareComingSoon': 'Tính năng chia sẻ sẽ sớm có mặt!',
    'savedToFavorites': 'Đã lưu vào danh sách yêu thích!',
    'likedPost': 'Đã thích bài viết!',
    'like': 'Thích',
    'bookmark': 'Đánh dấu',
    'bookmarkComingSoon': 'Tính năng đánh dấu sẽ sớm có mặt!',
    'postPublishedSuccessfully': 'Đã đăng bài thành công!',
    'registrationSuccessful': 'Đăng ký thành công! Vui lòng đăng nhập.',
    'likeFunctionalityComingSoon': 'Tính năng thích sẽ sớm có mặt!',
    'noNewsAvailable': 'Chưa có tin tức nào',
    'noResultsFound': 'Không tìm thấy kết quả',
    'enterMessage': 'Nhập tin nhắn',
    'enrollmentYear': 'Năm nhập học',
    'tellUsAboutAcademicBackground': 'Cho chúng tôi biết về nền tảng học vấn của bạn',
    'southKorea': 'Hàn Quốc',
    'vietnam': 'Việt Nam',
    'unitedStates': 'Hoa Kỳ',
    'japan': 'Nhật Bản',
    'china': 'Trung Quốc',
    'myanmar': 'Myanmar',
    'chinese': '中文',
    'japanese': '日本語',
    'username': 'Tên người dùng',
    'basicInformation': 'Thông tin cơ bản',
    'pleaseProvideBasicInformation': 'Vui lòng cung cấp thông tin cơ bản của bạn',
    'reviewAndSave': 'Xem lại & Lưu',
    'pleaseReviewInformation': 'Vui lòng xem lại thông tin của bạn trước khi lưu',
  };
  
  // Chinese translations
  static const Map<String, String> _zh = {
    'appTitle': 'Hi Campus',
    'login': '登录',
    'register': '注册',
    'email': '邮箱',
    'password': '密码',
    'confirmPassword': '确认密码',
    'loginButton': '登录',
    'registerButton': '注册',
    'alreadyHaveAccount': '已有账户？',
    'dontHaveAccount': '没有账户？',
    'home': '首页',
    'profile': '个人资料',
    'chat': '聊天',
    'language': '语言',
    'selectLanguage': '选择语言',
    'english': 'English',
    'korean': '한국어',
    'vietnamese': 'Tiếng Việt',
    'chinese': '中文',
    'japanese': '日本語',
    'myanmar': 'မြန်မာ',
    'welcome': '欢迎来到Hello Campus',
    'welcomeMessage': '您在韩国的旅程从这里开始',
    'fullName': '姓名',
    'university': '大学',
    'major': '专业',
    'year': '年级',
    'nationality': '国籍',
    'selectUniversity': '选择大学',
    'selectMajor': '选择专业',
    'selectYear': '选择年级',
    'selectNationality': '选择国籍',
    'save': '保存',
    'editProfile': '编辑资料',
    'logout': '退出登录',
    'emailRequired': '请输入邮箱',
    'emailInvalid': '请输入有效的邮箱',
    'passwordRequired': '请输入密码',
    'passwordTooShort': '密码至少需要6个字符',
    'passwordMismatch': '密码不匹配',
    'nameRequired': '请输入姓名',
    'universityRequired': '请选择大学',
    'majorRequired': '请选择专业',
    'yearRequired': '请选择年级',
    'nationalityRequired': '请选择国籍',
    'username': '用户名',
    'basicInformation': '基本信息',
    'pleaseProvideBasicInformation': '请提供您的基本信息',
    'reviewAndSave': '审查和保存',
    'pleaseReviewInformation': '请在保存前查看您的信息',
    'emailVerification': '邮箱验证',
    'verifyYourEmail': '验证您的学生邮箱地址',
    'studentEmail': '学生邮箱 (@stu.)',
    'sendVerificationCode': '发送验证码',
    'codeSent': '已发送',
    'enterVerificationCode': '输入6位验证码',
    'verificationCode': '验证码',
    'verifyCode': '验证码',
    'emailVerified': '邮箱已验证',
    'termsAndConditions': '条款和条件',
    'agreeToTerms': '我同意条款和条件',
    'reviewYourInfo': '保存前请审查您的信息',
    'emailStatus': '邮箱状态',
    'verified': '已验证 ✓',
    'notVerified': '未验证',
    'agreed': '已同意 ✓',
    'notAgreed': '未同意',
    'previous': '上一步',
    'next': '下一步',
    'saveProfile': '保存资料',
    'profileUpdated': '资料更新成功！',
    'invalidCode': '验证码无效',
    'emailVerifiedSuccess': '邮箱验证成功！',
    'pleaseAgreeTerms': '请同意条款和条件以继续',
    'validStudentEmail': '请输入有效的学生邮箱 (@stu.)',
    'codeSentTo': '验证码已发送至',
    'visitOfficialWebsite': '访问官方网站',
    'languageOrder': '语言交换订单',
    'selectLanguageToLearn': '请选择您想学习的语言（国家）、性别、学院',
    'selectLanguageToLearnLabel': '想学习的语言（国家） *',
    'selectLanguageToLearnRequired': '请选择您想学习的语言（国家）',
    'preferredGender': '首选性别',
    'college': '学院',
    'findMatch': '寻找匹配的伙伴',
    'languageExchangeMatching': '语言交换匹配',
    'moreOptions': '更多选项',
    'loadingOnlineUsers': '正在加载在线用户...',
    'errorOccurred': '发生错误',
    'retry': '重试',
    'noMatchFound': '未找到匹配的伙伴',
    'targetLanguage': '目标语言',
    'changeConditions': '更改条件',
    'onlineUsers': '在线用户',
    'online': '在线',
    'viewMore': '查看更多',
    'writePost': '写帖子',
    'title': '标题',
    'titleRequired': '请输入标题',
    'content': '内容',
    'contentRequired': '请输入内容',
    'postAnonymously': '匿名发布',
    'cancel': '取消',
    'post': '发布',
    'noSearchResults': '未找到搜索结果',
    'edit': '编辑',
    'profileUpdatedSuccessfully': '资料更新成功！',
    'searchNews': '搜索新闻',
    'search': '搜索',
    'enterSearchKeyword': '输入搜索关键词...',
    'errorSendingMessage': '发送消息错误',
    'conversationId': '会话ID',
    'noConversationsYet': '还没有对话',
    'startConversation': '与某人开始对话吧！',
    'featuredNews': '精选新闻',
    'news': '新闻',
    'international': '国际',
    'domestic': '国内',
    'national': '国家',
    'board': '公告板',
    'noticeBoard': '通知公告板',
    'freeBoard': '自由公告板',
    'infoBoard': '信息公告板',
    'promoBoard': '推广公告板',
    'step': '步骤',
    'personalInformation': '个人信息',
    'profileSetup': '资料设置',
    'schoolInformation': '学校信息',
    'reviewAndComplete': '审查并完成',
    'completeRegistration': '完成注册',
    'user': '用户',
    'student': '学生',
    'name': '姓名',
    'notProvided': '未提供',
    'realName': '真实姓名',
    'nickname': '昵称',
    'mainLanguage': '主要语言',
    'schoolId': '学校ID',
    'school': '学校',
    'department': '系',
    'pleaseFillAllFields': '请填写所有必填字段',
    'languageChangedTo': '语言已更改为',
    '1stYear': '一年级',
    '2ndYear': '二年级',
    '3rdYear': '三年级',
    '4thYear': '四年级',
    'graduateStudent': '研究生',
    'phdStudent': '博士生',
    'newsDetail': '新闻详情',
    'internationalNews': '国际新闻',
    'domesticNews': '国内新闻',
    'close': '关闭',
    'select': '选择',
    'confirm': '确认',
    'shareComingSoon': '分享功能即将推出！',
    'savedToFavorites': '已保存到收藏夹！',
    'likedPost': '已点赞！',
    'like': '点赞',
    'bookmark': '书签',
    'bookmarkComingSoon': '书签功能即将推出！',
    'postPublishedSuccessfully': '帖子发布成功！',
    'registrationSuccessful': '注册成功！请登录。',
    'likeFunctionalityComingSoon': '点赞功能即将推出！',
    'noNewsAvailable': '暂无新闻',
    'noResultsFound': '未找到结果',
    'enterMessage': '输入消息',
    'enrollmentYear': '入学年份',
    'tellUsAboutAcademicBackground': '请告诉我们您的学术背景',
    'southKorea': '韩国',
    'vietnam': '越南',
    'unitedStates': '美国',
    'japan': '日本',
    'china': '中国',
  };
  
  // Japanese translations
  static const Map<String, String> _ja = {
    'appTitle': 'Hi Campus',
    'login': 'ログイン',
    'register': '登録',
    'email': 'メール',
    'password': 'パスワード',
    'confirmPassword': 'パスワード確認',
    'loginButton': 'ログイン',
    'registerButton': '登録',
    'alreadyHaveAccount': 'アカウントをお持ちですか？',
    'dontHaveAccount': 'アカウントをお持ちでないですか？',
    'home': 'ホーム',
    'profile': 'プロフィール',
    'chat': 'チャット',
    'language': '言語',
    'selectLanguage': '言語選択',
    'english': 'English',
    'korean': '한국어',
    'vietnamese': 'Tiếng Việt',
    'chinese': '中文',
    'japanese': '日本語',
    'myanmar': 'မြန်မာ',
    'welcome': 'Hello Campusへようこそ',
    'welcomeMessage': '韓国でのあなたの旅はここから始まります',
    'fullName': '氏名',
    'university': '大学',
    'major': '専攻',
    'year': '学年',
    'nationality': '国籍',
    'selectUniversity': '大学を選択',
    'selectMajor': '専攻を選択',
    'selectYear': '学年を選択',
    'selectNationality': '国籍を選択',
    'save': '保存',
    'editProfile': 'プロフィール編集',
    'logout': 'ログアウト',
    'emailRequired': 'メールを入力してください',
    'emailInvalid': '有効なメールを入力してください',
    'passwordRequired': 'パスワードを入力してください',
    'passwordTooShort': 'パスワードは6文字以上である必要があります',
    'passwordMismatch': 'パスワードが一致しません',
    'nameRequired': '名前を入力してください',
    'universityRequired': '大学を選択してください',
    'majorRequired': '専攻を選択してください',
    'yearRequired': '学年を選択してください',
    'nationalityRequired': '国籍を選択してください',
    'username': 'ユーザー名',
    'basicInformation': '基本情報',
    'pleaseProvideBasicInformation': '基本情報を提供してください',
    'reviewAndSave': '確認と保存',
    'pleaseReviewInformation': '保存する前に情報を確認してください',
    'emailVerification': 'メール認証',
    'verifyYourEmail': '学生メールアドレスを認証してください',
    'studentEmail': '学生メール (@stu.)',
    'sendVerificationCode': '認証コードを送信',
    'codeSent': 'コード送信済み',
    'enterVerificationCode': '6桁の認証コードを入力してください',
    'verificationCode': '認証コード',
    'verifyCode': 'コード認証',
    'emailVerified': 'メール認証済み',
    'termsAndConditions': '利用規約',
    'agreeToTerms': '利用規約に同意します',
    'reviewYourInfo': '保存前に情報を確認してください',
    'emailStatus': 'メール状態',
    'verified': '認証済み ✓',
    'notVerified': '未認証',
    'agreed': '同意済み ✓',
    'notAgreed': '未同意',
    'previous': '前へ',
    'next': '次へ',
    'saveProfile': 'プロフィール保存',
    'profileUpdated': 'プロフィールが正常に更新されました！',
    'invalidCode': '無効な認証コード',
    'emailVerifiedSuccess': 'メール認証が成功しました！',
    'pleaseAgreeTerms': '続行するには利用規約に同意してください',
    'validStudentEmail': '有効な学生メールを入力してください (@stu.)',
    'codeSentTo': '認証コードが送信されました',
    'visitOfficialWebsite': '公式ウェブサイトを訪問',
    'languageOrder': '言語交換注文',
    'selectLanguageToLearn': '学びたい言語（国）、性別、学部を選択してください',
    'selectLanguageToLearnLabel': '学びたい言語（国） *',
    'selectLanguageToLearnRequired': '学びたい言語（国）を選択してください',
    'preferredGender': '希望する性別',
    'college': '学部',
    'findMatch': '条件に合う相手を探す',
    'languageExchangeMatching': '言語交換マッチング',
    'moreOptions': 'その他のオプション',
    'loadingOnlineUsers': 'オンラインユーザーを読み込み中...',
    'errorOccurred': 'エラーが発生しました',
    'retry': '再試行',
    'noMatchFound': '条件に合う相手が見つかりませんでした',
    'targetLanguage': '対象言語',
    'changeConditions': '条件を変更',
    'onlineUsers': 'オンラインユーザー',
    'online': 'オンライン',
    'viewMore': 'もっと見る',
    'writePost': '投稿を書く',
    'title': 'タイトル',
    'titleRequired': 'タイトルを入力してください',
    'content': '内容',
    'contentRequired': '内容を入力してください',
    'postAnonymously': '匿名で投稿',
    'cancel': 'キャンセル',
    'post': '投稿',
    'noSearchResults': '検索結果が見つかりません',
    'edit': '編集',
    'profileUpdatedSuccessfully': 'プロフィールが正常に更新されました！',
    'searchNews': 'ニュースを検索',
    'search': '検索',
    'enterSearchKeyword': '検索キーワードを入力...',
    'errorSendingMessage': 'メッセージ送信エラー',
    'conversationId': '会話ID',
    'noConversationsYet': 'まだ会話がありません',
    'startConversation': '誰かと会話を始めましょう！',
    'featuredNews': '注目のニュース',
    'news': 'ニュース',
    'international': '国際',
    'domestic': '国内',
    'national': '国家',
    'board': '掲示板',
    'noticeBoard': 'お知らせ掲示板',
    'freeBoard': '自由掲示板',
    'infoBoard': '情報掲示板',
    'promoBoard': 'プロモーション掲示板',
    'step': 'ステップ',
    'personalInformation': '個人情報',
    'profileSetup': 'プロフィール設定',
    'schoolInformation': '学校情報',
    'reviewAndComplete': '確認と完了',
    'completeRegistration': '登録完了',
    'user': 'ユーザー',
    'student': '学生',
    'name': '名前',
    'notProvided': '提供されていません',
    'realName': '本名',
    'nickname': 'ニックネーム',
    'mainLanguage': 'メイン言語',
    'schoolId': '学校ID',
    'school': '学校',
    'department': '学科',
    'pleaseFillAllFields': 'すべての必須フィールドを入力してください',
    'languageChangedTo': '言語が次のように変更されました',
    '1stYear': '1年生',
    '2ndYear': '2年生',
    '3rdYear': '3年生',
    '4thYear': '4年生',
    'graduateStudent': '大学院生',
    'phdStudent': '博士課程',
    'newsDetail': 'ニュース詳細',
    'internationalNews': '国際ニュース',
    'domesticNews': '国内ニュース',
    'close': '閉じる',
    'select': '選択',
    'confirm': '確認',
    'shareComingSoon': '共有機能がまもなく利用可能になります！',
    'savedToFavorites': 'お気に入りに保存されました！',
    'likedPost': '投稿をいいねしました！',
    'like': 'いいね',
    'bookmark': 'ブックマーク',
    'bookmarkComingSoon': 'ブックマーク機能がまもなく利用可能になります！',
    'postPublishedSuccessfully': '投稿が正常に公開されました！',
    'registrationSuccessful': '登録が完了しました！ログインしてください。',
    'likeFunctionalityComingSoon': 'いいね機能がまもなく利用可能になります！',
    'noNewsAvailable': 'ニュースがありません',
    'noResultsFound': '結果が見つかりません',
    'enterMessage': 'メッセージを入力',
    'enrollmentYear': '入学年度',
    'tellUsAboutAcademicBackground': '学歴について教えてください',
    'southKorea': '大韓民国',
    'vietnam': 'ベトナム',
    'unitedStates': 'アメリカ合衆国',
    'japan': '日本',
    'china': '中国',
  };
  
  // Myanmar translations
  static const Map<String, String> _my = {
    'appTitle': 'Hi Campus',
    'login': 'အကောင့်ဝင်ရောက်ရန်',
    'register': 'အကောင့်ဖွင့်ရန်',
    'email': 'အီးမေးလ်',
    'password': 'စကားဝှက်',
    'confirmPassword': 'စကားဝှက်အတည်ပြုရန်',
    'loginButton': 'အကောင့်ဝင်ရောက်ရန်',
    'registerButton': 'အကောင့်ဖွင့်ရန်',
    'alreadyHaveAccount': 'အကောင့်ရှိပြီးသားလား?',
    'dontHaveAccount': 'အကောင့်မရှိသေးလား?',
    'home': 'ပင်မ',
    'profile': 'ကိုယ်ရေးအချက်အလက်',
    'chat': 'စကားပြောဆို',
    'language': 'ဘာသာစကား',
    'selectLanguage': 'ဘာသာစကားရွေးချယ်ရန်',
    'english': 'English',
    'korean': '한국어',
    'vietnamese': 'Tiếng Việt',
    'chinese': '中文',
    'japanese': '日本語',
    'myanmar': 'မြန်မာ',
    'welcome': 'Hello Campus မှကြိုဆိုပါတယ်',
    'welcomeMessage': 'ကိုရီးယားရှိ သင့်ခရီးသည် ဤနေရာမှ စတင်ပါသည်',
    'fullName': 'အမည်',
    'university': 'တက္ကသိုလ်',
    'major': 'ဘာသာရပ်',
    'year': 'နှစ်',
    'nationality': 'နိုင်ငံသား',
    'selectUniversity': 'တက္ကသိုလ်ရွေးချယ်ရန်',
    'selectMajor': 'ဘာသာရပ်ရွေးချယ်ရန်',
    'selectYear': 'နှစ်ရွေးချယ်ရန်',
    'selectNationality': 'နိုင်ငံသားရွေးချယ်ရန်',
    'save': 'သိမ်းဆည်းရန်',
    'editProfile': 'ကိုယ်ရေးအချက်အလက်ပြင်ဆင်ရန်',
    'logout': 'အကောင့်မှထွက်ရန်',
    'emailRequired': 'အီးမေးလ်ထည့်သွင်းပါ',
    'emailInvalid': 'မှန်ကန်သောအီးမေးလ်ထည့်သွင်းပါ',
    'passwordRequired': 'စကားဝှက်ထည့်သွင်းပါ',
    'passwordTooShort': 'စကားဝှက်သည် အနည်းဆုံး ၆ လုံးရှိရပါမည်',
    'passwordMismatch': 'စကားဝှက်များ မကိုက်ညီပါ',
    'nameRequired': 'အမည်ထည့်သွင်းပါ',
    'universityRequired': 'တက္ကသိုလ်ရွေးချယ်ပါ',
    'majorRequired': 'ဘာသာရပ်ရွေးချယ်ပါ',
    'yearRequired': 'နှစ်ရွေးချယ်ပါ',
    'nationalityRequired': 'နိုင်ငံသားရွေးချယ်ပါ',
    'username': 'အသုံးပြုသူအမည်',
    'basicInformation': 'အခြေခံ အချက်အလက်',
    'pleaseProvideBasicInformation': 'သင်၏ အခြေခံ အချက်အလက်ကို ပေးပါ',
    'reviewAndSave': 'ပြန်လည်စစ်ဆေးပြီး သိမ်းဆည်းပါ',
    'pleaseReviewInformation': 'သိမ်းဆည်းမီ သင်၏ အချက်အလက်ကို ပြန်လည်စစ်ဆေးပါ',
    'emailVerification': 'အီးမေးလ်အတည်ပြုခြင်း',
    'verifyYourEmail': 'သင့်ကျောင်းသားအီးမေးလ်လိပ်စာကို အတည်ပြုပါ',
    'studentEmail': 'ကျောင်းသားအီးမေးလ် (@stu.)',
    'sendVerificationCode': 'အတည်ပြုကုဒ်ပို့ပါ',
    'codeSent': 'ကုဒ်ပို့ပြီး',
    'enterVerificationCode': 'အတည်ပြုကုဒ် ၆ လုံးထည့်သွင်းပါ',
    'verificationCode': 'အတည်ပြုကုဒ်',
    'verifyCode': 'ကုဒ်အတည်ပြုပါ',
    'emailVerified': 'အီးမေးလ်အတည်ပြုပြီး',
    'termsAndConditions': 'စည်းကမ်းချက်များနှင့် အခြေအနေများ',
    'agreeToTerms': 'စည်းကမ်းချက်များနှင့် အခြေအနေများကို သဘောတူပါသည်',
    'reviewYourInfo': 'သိမ်းဆည်းမီ သင့်အချက်အလက်များကို ပြန်လည်စစ်ဆေးပါ',
    'emailStatus': 'အီးမေးလ်အခြေအနေ',
    'verified': 'အတည်ပြုပြီး ✓',
    'notVerified': 'မအတည်ပြုရသေး',
    'agreed': 'သဘောတူပြီး ✓',
    'notAgreed': 'မသဘောတူရသေး',
    'previous': 'ရှေ့',
    'next': 'နောက်',
    'saveProfile': 'ကိုယ်ရေးအချက်အလက်သိမ်းဆည်းပါ',
    'profileUpdated': 'ကိုယ်ရေးအချက်အလက် အောင်မြင်စွာ ပြင်ဆင်ပြီးပါပြီ!',
    'invalidCode': 'မမှန်ကန်သော အတည်ပြုကုဒ်',
    'emailVerifiedSuccess': 'အီးမေးလ်အတည်ပြုခြင်း အောင်မြင်ပါပြီ!',
    'pleaseAgreeTerms': 'ဆက်လက်လုပ်ဆောင်ရန် စည်းကမ်းချက်များနှင့် အခြေအနေများကို သဘောတူပါ',
    'validStudentEmail': 'မှန်ကန်သော ကျောင်းသားအီးမေးလ်ထည့်သွင်းပါ (@stu.)',
    'codeSentTo': 'အတည်ပြုကုဒ်ကို ပို့ပြီးပါပြီ',
    'visitOfficialWebsite': 'တရားဝင်ဝဘ်ဆိုက်ကို လည်ပတ်ပါ',
    'languageOrder': 'ဘာသာစကား ဖလှယ်ရေး မှာယူမှု',
    'selectLanguageToLearn': 'သင်ယူလိုသော ဘာသာစကား (နိုင်ငံ), လိင်, ကောလိပ်ကို ရွေးချယ်ပါ',
    'selectLanguageToLearnLabel': 'သင်ယူလိုသော ဘာသာစကား (နိုင်ငံ) *',
    'selectLanguageToLearnRequired': 'သင်ယူလိုသော ဘာသာစကား (နိုင်ငံ) ကို ရွေးချယ်ပါ',
    'preferredGender': 'နှစ်သက်သော လိင်',
    'college': 'ကောလိပ်',
    'findMatch': 'ကိုက်ညီသော လက်တွဲဖော် ရှာဖွေရန်',
    'languageExchangeMatching': 'ဘာသာစကား ဖလှယ်ရေး ကိုက်ညီမှု',
    'moreOptions': 'ပိုမိုသော ရွေးချယ်စရာများ',
    'loadingOnlineUsers': 'အွန်လိုင်း အသုံးပြုသူများကို ဖွင့်နေသည်...',
    'errorOccurred': 'အမှားတစ်ခု ဖြစ်ပွားခဲ့သည်',
    'retry': 'ပြန်လည် စမ်းကြည့်ရန်',
    'noMatchFound': 'ကိုက်ညီသော လက်တွဲဖော် မတွေ့ရှိပါ',
    'targetLanguage': 'ဦးတည်ရာ ဘာသာစကား',
    'changeConditions': 'အခြေအနေများ ပြောင်းလဲရန်',
    'onlineUsers': 'အွန်လိုင်း အသုံးပြုသူများ',
    'online': 'အွန်လိုင်း',
    'viewMore': 'ပိုမို ကြည့်ရန်',
    'writePost': 'စာတမ်းရေးရန်',
    'title': 'ခေါင်းစဉ်',
    'titleRequired': 'ခေါင်းစဉ် ထည့်သွင်းပါ',
    'content': 'အကြောင်းအရာ',
    'contentRequired': 'အကြောင်းအရာ ထည့်သွင်းပါ',
    'postAnonymously': 'အမည်မဖော်ဘဲ ပို့ရန်',
    'cancel': 'ပယ်ဖျက်ရန်',
    'post': 'ပို့ရန်',
    'noSearchResults': 'ရှာဖွေမှု ရလဒ် မတွေ့ရှိပါ',
    'edit': 'တည်းဖြတ်ရန်',
    'profileUpdatedSuccessfully': 'ကိုယ်ရေးအချက်အလက် အောင်မြင်စွာ ပြင်ဆင်ပြီးပါပြီ!',
    'searchNews': 'သတင်းများ ရှာဖွေရန်',
    'search': 'ရှာဖွေရန်',
    'enterSearchKeyword': 'ရှာဖွေရန် စကားလုံး ထည့်သွင်းပါ...',
    'errorSendingMessage': 'စာတိုပို့ရန် အမှား',
    'conversationId': 'စကားပြောဆို ID',
    'noConversationsYet': 'အခုထိ စကားပြောဆိုမှု မရှိသေးပါ',
    'startConversation': 'တစ်စုံတစ်ယောက်နှင့် စကားပြောဆိုမှု စတင်ပါ！',
    'featuredNews': 'ထင်ရှားသော သတင်းများ',
    'news': 'သတင်းများ',
    'international': 'နိုင်ငံတကာ',
    'domestic': 'ပြည်တွင်း',
    'national': 'နိုင်ငံ',
    'board': 'ဘုတ်အဖွဲ့',
    'noticeBoard': 'အကြောင်းကြားစာ ဘုတ်အဖွဲ့',
    'freeBoard': 'လွတ်လပ်သော ဘုတ်အဖွဲ့',
    'infoBoard': 'အချက်အလက် ဘုတ်အဖွဲ့',
    'promoBoard': 'ကြော်ငြာ ဘုတ်အဖွဲ့',
    'step': 'အဆင့်',
    'personalInformation': 'ကိုယ်ရေးအချက်အလက်',
    'profileSetup': 'ကိုယ်ရေးအချက်အလက် စနစ်ထားရှိရန်',
    'schoolInformation': 'ကျောင်းအချက်အလက်',
    'reviewAndComplete': 'ပြန်လည်ဆန်းစစ်ရန် နှင့် ပြီးစီးရန်',
    'completeRegistration': 'မှတ်ပုံတင်ခြင်း ပြီးစီးရန်',
    'user': 'အသုံးပြုသူ',
    'student': 'ကျောင်းသား',
    'name': 'အမည်',
    'notProvided': 'မပေးထားပါ',
    'realName': 'အမည်အမှန်',
    'nickname': 'အမည်ပြောင်',
    'mainLanguage': 'အဓိက ဘာသာစကား',
    'schoolId': 'ကျောင်း ID',
    'school': 'ကျောင်း',
    'department': 'ဌာန',
    'pleaseFillAllFields': 'လိုအပ်သော အကွက်အားလုံးကို ဖြည့်ပါ',
    'languageChangedTo': 'ဘာသာစကား ပြောင်းလဲထားသည်',
    '1stYear': 'နှစ် ၁',
    '2ndYear': 'နှစ် ၂',
    '3rdYear': 'နှစ် ၃',
    '4thYear': 'နှစ် ၄',
    'graduateStudent': 'ဘွဲ့လွန်ကျောင်းသား',
    'phdStudent': 'ပါရဂူဘွဲ့ ကျောင်းသား',
    'newsDetail': 'သတင်း အသေးစိတ်',
    'internationalNews': 'နိုင်ငံတကာ သတင်းများ',
    'domesticNews': 'ပြည်တွင်း သတင်းများ',
    'close': 'ပိတ်ရန်',
    'select': 'ရွေးချယ်ရန်',
    'confirm': 'အတည်ပြုရန်',
    'shareComingSoon': 'မျှဝေခြင်း လုပ်ဆောင်ချက် မကြာမီ ရရှိပါမည်！',
    'savedToFavorites': 'အကြိုက်ဆုံး စာရင်းသို့ သိမ်းဆည်းပြီးပါပြီ！',
    'likedPost': 'စာတမ်းကို နှစ်သက်ပါပြီ！',
    'like': 'နှစ်သက်ရန်',
    'bookmark': 'စာအမှတ်အသား',
    'bookmarkComingSoon': 'စာအမှတ်အသား လုပ်ဆောင်ချက် မကြာမီ ရရှိပါမည်！',
    'postPublishedSuccessfully': 'စာတမ်း အောင်မြင်စွာ ပို့ပြီးပါပြီ！',
    'registrationSuccessful': 'မှတ်ပုံတင်ခြင်း အောင်မြင်ပါပြီ！ အကောင့်ဝင်ရောက်ပါ။',
    'likeFunctionalityComingSoon': 'နှစ်သက်ရန် လုပ်ဆောင်ချက် မကြာမီ ရရှိပါမည်！',
    'noNewsAvailable': 'သတင်းများ မရှိပါ',
    'noResultsFound': 'ရလဒ် မတွေ့ရှိပါ',
    'enterMessage': 'မက်ဆေ့ချ် ထည့်သွင်းရန်',
    'enrollmentYear': 'စာရင်းသွင်းသည့် နှစ်',
    'tellUsAboutAcademicBackground': 'သင်၏ ပညာရေး နောက်ခံ အကြောင်း ပြောပြပါ',
    'southKorea': 'တောင်ကိုရီးယား',
    'vietnam': 'ဗီယက်နမ်',
    'unitedStates': 'အမေရိကန် ပြည်ထောင်စု',
    'japan': 'ဂျပန်',
    'china': 'တရုတ်',
  };
  
  String translate(String key) {
    Map<String, String> translations;
    switch (locale.languageCode) {
      case 'ko':
        translations = _ko;
        break;
      case 'vi':
        translations = _vi;
        break;
      case 'zh':
        translations = _zh;
        break;
      case 'ja':
        translations = _ja;
        break;
      case 'my':
        translations = _my;
        break;
      default:
        translations = _en;
    }
    return translations[key] ?? key;
  }
  
  // Getters for common translations
  String get appTitle => translate('appTitle');
  String get login => translate('login');
  String get register => translate('register');
  String get email => translate('email');
  String get password => translate('password');
  String get confirmPassword => translate('confirmPassword');
  String get loginButton => translate('loginButton');
  String get registerButton => translate('registerButton');
  String get alreadyHaveAccount => translate('alreadyHaveAccount');
  String get dontHaveAccount => translate('dontHaveAccount');
  String get home => translate('home');
  String get profile => translate('profile');
  String get chat => translate('chat');
  String get language => translate('language');
  String get selectLanguage => translate('selectLanguage');
  String get english => translate('english');
  String get korean => translate('korean');
  String get vietnamese => translate('vietnamese');
  String get chinese => translate('chinese');
  String get japanese => translate('japanese');
  String get myanmar => translate('myanmar');
  String get welcome => translate('welcome');
  String get welcomeMessage => translate('welcomeMessage');
  String get fullName => translate('fullName');
  String get username => translate('username');
  String get basicInformation => translate('basicInformation');
  String get pleaseProvideBasicInformation => translate('pleaseProvideBasicInformation');
  String get reviewAndSave => translate('reviewAndSave');
  String get pleaseReviewInformation => translate('pleaseReviewInformation');
  String get university => translate('university');
  String get major => translate('major');
  String get year => translate('year');
  String get nationality => translate('nationality');
  String get selectUniversity => translate('selectUniversity');
  String get selectMajor => translate('selectMajor');
  String get selectYear => translate('selectYear');
  String get selectNationality => translate('selectNationality');
  String get save => translate('save');
  String get editProfile => translate('editProfile');
  String get logout => translate('logout');
  String get emailRequired => translate('emailRequired');
  String get emailInvalid => translate('emailInvalid');
  String get passwordRequired => translate('passwordRequired');
  String get passwordTooShort => translate('passwordTooShort');
  String get passwordMismatch => translate('passwordMismatch');
  String get nameRequired => translate('nameRequired');
  String get universityRequired => translate('universityRequired');
  String get majorRequired => translate('majorRequired');
  String get yearRequired => translate('yearRequired');
  String get nationalityRequired => translate('nationalityRequired');
  
  String get visitOfficialWebsite => translate('visitOfficialWebsite');
  
  // Language Order translations
  String get languageOrder => translate('languageOrder');
  String get selectLanguageToLearn => translate('selectLanguageToLearn');
  String get selectLanguageToLearnLabel => translate('selectLanguageToLearnLabel');
  String get selectLanguageToLearnRequired => translate('selectLanguageToLearnRequired');
  String get preferredGender => translate('preferredGender');
  String get college => translate('college');
  String get findMatch => translate('findMatch');
  String get languageExchangeMatching => translate('languageExchangeMatching');
  String get moreOptions => translate('moreOptions');
  String get loadingOnlineUsers => translate('loadingOnlineUsers');
  String get errorOccurred => translate('errorOccurred');
  String get retry => translate('retry');
  String get noMatchFound => translate('noMatchFound');
  String get targetLanguage => translate('targetLanguage');
  String get changeConditions => translate('changeConditions');
  String get onlineUsers => translate('onlineUsers');
  String get online => translate('online');
  String get viewMore => translate('viewMore');
  
  // Board translations
  String get writePost => translate('writePost');
  String get title => translate('title');
  String get titleRequired => translate('titleRequired');
  String get content => translate('content');
  String get contentRequired => translate('contentRequired');
  String get postAnonymously => translate('postAnonymously');
  String get cancel => translate('cancel');
  String get post => translate('post');
  String get noSearchResults => translate('noSearchResults');
  
  // Profile translations
  String get edit => translate('edit');
  String get previous => translate('previous');
  String get saveProfile => translate('saveProfile');
  String get profileUpdatedSuccessfully => translate('profileUpdatedSuccessfully');
  
  // News translations
  String get searchNews => translate('searchNews');
  String get search => translate('search');
  String get next => translate('next');
  String get enterSearchKeyword => translate('enterSearchKeyword');
  
  // Chat translations
  String get errorSendingMessage => translate('errorSendingMessage');
  String get conversationId => translate('conversationId');
  String get noConversationsYet => translate('noConversationsYet');
  String get startConversation => translate('startConversation');
  
  // News translations
  String get featuredNews => translate('featuredNews');
  String get news => translate('news');
  String get international => translate('international');
  String get domestic => translate('domestic');
  String get national => translate('national');
  
  // Board translations
  String get board => translate('board');
  String get noticeBoard => translate('noticeBoard');
  String get freeBoard => translate('freeBoard');
  String get infoBoard => translate('infoBoard');
  String get promoBoard => translate('promoBoard');
  
  // Step translations
  String get step => translate('step');
  String get personalInformation => translate('personalInformation');
  String get profileSetup => translate('profileSetup');
  String get schoolInformation => translate('schoolInformation');
  String get reviewAndComplete => translate('reviewAndComplete');
  String get completeRegistration => translate('completeRegistration');
  
  // Additional translations
  String get user => translate('user');
  String get student => translate('student');
  String get name => translate('name');
  String get notProvided => translate('notProvided');
  String get studentEmail => translate('studentEmail');
  String get realName => translate('realName');
  String get nickname => translate('nickname');
  String get mainLanguage => translate('mainLanguage');
  String get schoolId => translate('schoolId');
  String get school => translate('school');
  String get department => translate('department');
  String get pleaseFillAllFields => translate('pleaseFillAllFields');
  String get languageChangedTo => translate('languageChangedTo');
  String get firstYear => translate('1stYear');
  String get secondYear => translate('2ndYear');
  String get thirdYear => translate('3rdYear');
  String get fourthYear => translate('4thYear');
  String get graduateStudent => translate('graduateStudent');
  String get phdStudent => translate('phdStudent');
  
  // News translations
  String get newsDetail => translate('newsDetail');
  String get internationalNews => translate('internationalNews');
  String get domesticNews => translate('domesticNews');
  
  // Common actions
  String get close => translate('close');
  String get select => translate('select');
  String get confirm => translate('confirm');
  
  // Feature messages
  String get shareComingSoon => translate('shareComingSoon');
  String get savedToFavorites => translate('savedToFavorites');
  String get likedPost => translate('likedPost');
  String get like => translate('like');
  String get bookmark => translate('bookmark');
  String get bookmarkComingSoon => translate('bookmarkComingSoon');
  String get postPublishedSuccessfully => translate('postPublishedSuccessfully');
  String get registrationSuccessful => translate('registrationSuccessful');
  String get likeFunctionalityComingSoon => translate('likeFunctionalityComingSoon');
  String get noNewsAvailable => translate('noNewsAvailable');
  String get noResultsFound => translate('noResultsFound');
  String get enterMessage => translate('enterMessage');
  String get enrollmentYear => translate('enrollmentYear');
  String get tellUsAboutAcademicBackground => translate('tellUsAboutAcademicBackground');
  String get southKorea => translate('southKorea');
  String get vietnam => translate('vietnam');
  String get unitedStates => translate('unitedStates');
  String get japan => translate('japan');
  String get china => translate('china');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();
  
  @override
  bool isSupported(Locale locale) {
    return ['en', 'ko', 'vi', 'zh', 'ja', 'my'].contains(locale.languageCode);
  }
  
  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }
  
  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
