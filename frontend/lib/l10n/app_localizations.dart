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
    'studentId': 'Student ID',
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
    'recentActivity': 'Recent Activity',
    'welcomeToHelloCampus': 'Welcome to Hello Campus!',
    'accountCreatedSuccessfully': 'Your account has been created successfully. Start exploring your campus!',
    'hoursAgo': 'hours ago',
    'news': 'News',
    'international': 'International',
    'domestic': 'Domestic',
    'retry': 'Retry',
    'more': 'More',
    'languageChangedTo': 'Language changed to',
    'languageOrder': 'Language Order',
    'shareFunctionalityComingSoon': 'Share functionality coming soon!',
    'like': 'Like',
    'bookmark': 'Bookmark',
    'bookmarkFunctionalityComingSoon': 'Bookmark functionality coming soon!',
    'postPublishedSuccessfully': 'Post published successfully!',
    'errorOccurred': 'An error occurred',
    'registrationSuccessful': 'Registration successful! Please login.',
    'pleaseLogin': 'Please login.',
    'pleaseFillAllRequiredFields': 'Please fill in all required fields',
    'previous': 'Previous',
    'next': 'Next',
    'searchNews': 'Search news',
    'cancel': 'Cancel',
    'search': 'Search',
    'edit': 'Edit',
    'saveProfile': 'Save Profile',
    'profileUpdated': 'Profile updated successfully!',
    'noSearchResults': 'No search results found.',
    'writePost': 'Write Post',
    'writeAnonymously': 'Write anonymously',
    'post': 'Post',
    'title': 'Title',
    'content': 'Content',
    'titleRequired': 'Please enter a title',
    'contentRequired': 'Please enter content',
    'findMatch': 'Find Matching Partner',
    'languageExchangeMatching': 'Language Exchange Matching',
    'matchFound': 'Match found!',
    'targetLanguage': 'Target Language',
    'gender': 'Gender',
    'college': 'College',
    'startChat': 'Start Chat',
    'goBack': 'Go Back',
    'tryAgain': 'Try Again',
    'changeConditions': 'Change Conditions',
    'noMatchFound': 'No matching partner found.\n(Target Language: {targetLang})',
    'schoolInformation': 'School Information',
    'tellUsAboutAcademicBackground': 'Tell us about your academic background',
    'department': 'Department',
    'southKorea': 'South Korea',
    'vietnam': 'Vietnam',
    'unitedStates': 'United States',
    'japan': 'Japan',
    'china': 'China',
    'myanmar': 'Myanmar',
    'personalInformation': 'Personal Information',
    'profileSetup': 'Profile Setup',
    'nickname': 'Nickname',
    'enrollmentYear': 'Enrollment Year',
    'male': 'Male',
    'female': 'Female',
    'reviewAndSave': 'Review & Save',
    'featuredNews': 'Featured News',
    'board': 'Board',
    'noticeBoard': 'Notice Board',
    'freeBoard': 'Free Board',
    'infoBoard': 'Info Board',
    'promoBoard': 'Promo Board',
    'languageExchangeChat': 'Language Exchange Chat',
    'findLanguageExchangePartner': 'Select the language you want to learn and conditions to find a language exchange partner!',
    'noLanguageExchangeChatHistory': 'No language exchange chat history yet.\nStart matching from the home screen!',
    'noPostsYet': 'No posts yet.',
    'editProfileStep': 'Edit Profile - Step {step}/2',
    'step': 'Step',
    'stepSeparator': '/',
    'basicInformation': 'Basic Information',
    'pleaseProvideBasicInformation': 'Please provide your basic information',
    'pleaseReviewBeforeSaving': 'Please review your information before saving',
    'pleaseReviewBeforeCompleting': 'Please review your information before completing',
    'reviewAndComplete': 'Review & Complete',
    'realName': 'Real Name',
    'completeRegistration': 'Complete Registration',
    'deletePost': 'Delete Post',
    'deletePostConfirm': 'Are you sure you want to delete this post?',
    'postDeleted': 'Post deleted successfully',
    'cannotDeletePost': 'Cannot delete post',
    'delete': 'Delete',
    'latestNoticeTitle': 'Semester Start and Academic Schedule Notice',
    'latestFreeTitle': 'Exams are over! What are you doing this Saturday?',
    'latestInfoTitle': '2025 Exchange Student Recruitment Information',
    'latestPromoTitle': 'Club Promotion – New Member Recruitment',
    'postLabel': 'Post',
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
    'studentId': '학번',
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
    'recentActivity': '최근 활동',
    'welcomeToHelloCampus': 'Hello Campus에 오신 것을 환영합니다!',
    'accountCreatedSuccessfully': '계정이 성공적으로 생성되었습니다. 캠퍼스를 탐험해보세요!',
    'hoursAgo': '시간 전',
    'news': '뉴스',
    'international': '국제',
    'domestic': '국내',
    'retry': '다시 시도',
    'more': '더보기',
    'languageChangedTo': '언어가 변경되었습니다',
    'languageOrder': '언어 주문',
    'shareFunctionalityComingSoon': '공유 기능이 곧 제공될 예정입니다!',
    'like': '좋아요',
    'bookmark': '북마크',
    'bookmarkFunctionalityComingSoon': '북마크 기능이 곧 제공될 예정입니다!',
    'postPublishedSuccessfully': '게시물이 성공적으로 게시되었습니다!',
    'errorOccurred': '오류가 발생했습니다',
    'registrationSuccessful': '등록이 완료되었습니다! 로그인해주세요.',
    'pleaseLogin': '로그인해주세요.',
    'pleaseFillAllRequiredFields': '모든 필수 항목을 입력해주세요',
    'previous': '이전',
    'next': '다음',
    'searchNews': '뉴스 검색',
    'cancel': '취소',
    'search': '검색',
    'edit': '편집',
    'saveProfile': '프로필 저장',
    'profileUpdated': '프로필이 성공적으로 업데이트되었습니다!',
    'noSearchResults': '검색 결과가 없습니다.',
    'writePost': '게시글 작성',
    'writeAnonymously': '익명으로 작성',
    'post': '게시하기',
    'title': '제목',
    'content': '내용',
    'titleRequired': '제목을 입력해주세요',
    'contentRequired': '내용을 입력해주세요',
    'findMatch': '조건에 맞는 상대 찾기',
    'languageExchangeMatching': '언어교류 매칭',
    'matchFound': '상대를 찾았습니다!',
    'targetLanguage': '대상 언어',
    'gender': '성별',
    'college': '단과대학',
    'startChat': '채팅 시작하기',
    'goBack': '돌아가기',
    'tryAgain': '다시 시도',
    'changeConditions': '조건 변경하기',
    'noMatchFound': '조건에 맞는 상대를 찾지 못했어요.\n(대상 언어: {targetLang})',
    'schoolInformation': '학교 정보',
    'tellUsAboutAcademicBackground': '학력에 대해 알려주세요',
    'department': '학과',
    'southKorea': '대한민국',
    'vietnam': '베트남',
    'unitedStates': '미국',
    'japan': '일본',
    'china': '중국',
    'myanmar': '미얀마',
    'personalInformation': '개인 정보',
    'profileSetup': '프로필 설정',
    'nickname': '닉네임',
    'enrollmentYear': '입학 연도',
    'male': '남성',
    'female': '여성',
    'reviewAndSave': '검토 및 저장',
    'featuredNews': '주요 뉴스',
    'board': '게시판',
    'noticeBoard': '공지게시판',
    'freeBoard': '자유게시판',
    'infoBoard': '정보게시판',
    'promoBoard': '홍보게시판',
    'languageExchangeChat': '언어 교류 채팅',
    'findLanguageExchangePartner': '배우고 싶은 언어와 조건을 선택해서 언어교류 파트너를 찾아보세요!',
    'noLanguageExchangeChatHistory': '아직 언어교류 채팅 기록이 없어요.\n홈 화면에서 매칭을 시작해보세요!',
    'noPostsYet': '아직 게시글이 없습니다.',
    'editProfileStep': '프로필 편집 - {step}/2 단계',
    'step': '단계',
    'stepSeparator': '/',
    'basicInformation': '기본 정보',
    'pleaseProvideBasicInformation': '기본 정보를 입력해주세요',
    'pleaseReviewBeforeSaving': '저장하기 전에 정보를 확인해주세요',
    'pleaseReviewBeforeCompleting': '완료하기 전에 정보를 확인해주세요',
    'reviewAndComplete': '검토 및 완료',
    'realName': '실명',
    'completeRegistration': '회원가입 완료',
    'deletePost': '게시글 삭제',
    'deletePostConfirm': '이 게시글을 삭제하시겠습니까?',
    'postDeleted': '게시글이 성공적으로 삭제되었습니다',
    'cannotDeletePost': '게시글을 삭제할 수 없습니다',
    'delete': '삭제',
    'latestNoticeTitle': '개강 및 학사 일정 안내',
    'latestFreeTitle': '시험 끝! 토요일에 뭐 하세요?',
    'latestInfoTitle': '2025 교환학생 모집 정보 공유',
    'latestPromoTitle': '동아리 홍보 – ○○ 동아리 신입 모집',
    'postLabel': '게시글',
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
    'studentId': 'Mã sinh viên',
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
    'recentActivity': 'Hoạt động gần đây',
    'welcomeToHelloCampus': 'Chào mừng đến với Hello Campus!',
    'accountCreatedSuccessfully': 'Tài khoản của bạn đã được tạo thành công. Bắt đầu khám phá khuôn viên của bạn!',
    'hoursAgo': 'giờ trước',
    'news': 'Tin tức',
    'international': 'Quốc tế',
    'domestic': 'Trong nước',
    'retry': 'Thử lại',
    'more': 'Xem thêm',
    'languageChangedTo': 'Ngôn ngữ đã thay đổi thành',
    'languageOrder': 'Đặt hàng ngôn ngữ',
    'shareFunctionalityComingSoon': 'Tính năng chia sẻ sẽ sớm có mặt!',
    'like': 'Thích',
    'bookmark': 'Đánh dấu',
    'bookmarkFunctionalityComingSoon': 'Tính năng đánh dấu sẽ sớm có mặt!',
    'postPublishedSuccessfully': 'Đăng bài thành công!',
    'errorOccurred': 'Đã xảy ra lỗi',
    'registrationSuccessful': 'Đăng ký thành công! Vui lòng đăng nhập.',
    'pleaseLogin': 'Vui lòng đăng nhập.',
    'pleaseFillAllRequiredFields': 'Vui lòng điền tất cả các trường bắt buộc',
    'previous': 'Trước',
    'next': 'Tiếp theo',
    'searchNews': 'Tìm kiếm tin tức',
    'cancel': 'Hủy',
    'search': 'Tìm kiếm',
    'edit': 'Chỉnh sửa',
    'saveProfile': 'Lưu hồ sơ',
    'profileUpdated': 'Hồ sơ đã được cập nhật thành công!',
    'noSearchResults': 'Không tìm thấy kết quả tìm kiếm.',
    'writePost': 'Viết bài đăng',
    'writeAnonymously': 'Viết ẩn danh',
    'post': 'Đăng bài',
    'title': 'Tiêu đề',
    'content': 'Nội dung',
    'titleRequired': 'Vui lòng nhập tiêu đề',
    'contentRequired': 'Vui lòng nhập nội dung',
    'findMatch': 'Tìm đối tác phù hợp',
    'languageExchangeMatching': 'Kết nối trao đổi ngôn ngữ',
    'matchFound': 'Đã tìm thấy đối tác!',
    'targetLanguage': 'Ngôn ngữ mục tiêu',
    'gender': 'Giới tính',
    'college': 'Khoa',
    'startChat': 'Bắt đầu trò chuyện',
    'goBack': 'Quay lại',
    'tryAgain': 'Thử lại',
    'changeConditions': 'Thay đổi điều kiện',
    'noMatchFound': 'Không tìm thấy đối tác phù hợp.\n(Ngôn ngữ mục tiêu: {targetLang})',
    'schoolInformation': 'Thông tin trường học',
    'tellUsAboutAcademicBackground': 'Hãy cho chúng tôi biết về nền tảng học vấn của bạn',
    'department': 'Khoa',
    'southKorea': 'Hàn Quốc',
    'vietnam': 'Việt Nam',
    'unitedStates': 'Hoa Kỳ',
    'japan': 'Nhật Bản',
    'china': 'Trung Quốc',
    'myanmar': 'Myanmar',
    'personalInformation': 'Thông tin cá nhân',
    'profileSetup': 'Thiết lập hồ sơ',
    'nickname': 'Biệt danh',
    'enrollmentYear': 'Năm nhập học',
    'male': 'Nam',
    'female': 'Nữ',
    'reviewAndSave': 'Xem lại và Lưu',
    'featuredNews': 'Tin Tức Nổi Bật',
    'board': 'Bảng Tin',
    'noticeBoard': 'Bảng Thông Báo',
    'freeBoard': 'Bảng Tự Do',
    'infoBoard': 'Bảng Thông Tin',
    'promoBoard': 'Bảng Quảng Cáo',
    'languageExchangeChat': 'Trò Chuyện Trao Đổi Ngôn Ngữ',
    'findLanguageExchangePartner': 'Chọn ngôn ngữ bạn muốn học và điều kiện để tìm đối tác trao đổi ngôn ngữ!',
    'noLanguageExchangeChatHistory': 'Chưa có lịch sử trò chuyện trao đổi ngôn ngữ.\nBắt đầu kết nối từ màn hình chính!',
    'noPostsYet': 'Chưa có bài đăng nào.',
    'editProfileStep': 'Chỉnh sửa hồ sơ - Bước {step}/2',
    'step': 'Bước',
    'stepSeparator': '/',
    'basicInformation': 'Thông Tin Cơ Bản',
    'pleaseProvideBasicInformation': 'Vui lòng cung cấp thông tin cơ bản của bạn',
    'pleaseReviewBeforeSaving': 'Vui lòng xem lại thông tin của bạn trước khi lưu',
    'pleaseReviewBeforeCompleting': 'Vui lòng xem lại thông tin của bạn trước khi hoàn tất',
    'reviewAndComplete': 'Xem Lại & Hoàn Tất',
    'realName': 'Tên Thật',
    'completeRegistration': 'Hoàn Tất Đăng Ký',
    'deletePost': 'Xóa bài viết',
    'deletePostConfirm': 'Bạn có chắc chắn muốn xóa bài viết này?',
    'postDeleted': 'Đã xóa bài viết thành công',
    'cannotDeletePost': 'Không thể xóa bài viết',
    'delete': 'Xóa',
    'latestNoticeTitle': 'Thông báo khai giảng và lịch học vụ',
    'latestFreeTitle': 'Thi xong rồi! Thứ bảy này bạn làm gì?',
    'latestInfoTitle': 'Thông tin tuyển sinh trao đổi 2025',
    'latestPromoTitle': 'Quảng bá câu lạc bộ – Tuyển thành viên mới',
    'postLabel': 'Bài viết',
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
    'studentId': '学号',
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
    'reviewAndSave': '审查和保存',
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
    'recentActivity': '最近活动',
    'welcomeToHelloCampus': '欢迎来到Hello Campus！',
    'accountCreatedSuccessfully': '您的账户已成功创建。开始探索您的校园吧！',
    'hoursAgo': '小时前',
    'news': '新闻',
    'international': '国际',
    'domestic': '国内',
    'retry': '重试',
    'more': '更多',
    'languageChangedTo': '语言已更改为',
    'languageOrder': '语言订单',
    'shareFunctionalityComingSoon': '分享功能即将推出！',
    'like': '点赞',
    'bookmark': '收藏',
    'bookmarkFunctionalityComingSoon': '收藏功能即将推出！',
    'postPublishedSuccessfully': '帖子发布成功！',
    'errorOccurred': '发生错误',
    'registrationSuccessful': '注册成功！请登录。',
    'pleaseLogin': '请登录。',
    'pleaseFillAllRequiredFields': '请填写所有必填字段',
    'searchNews': '搜索新闻',
    'cancel': '取消',
    'search': '搜索',
    'edit': '编辑',
    'noSearchResults': '未找到搜索结果。',
    'writePost': '写帖子',
    'writeAnonymously': '匿名发布',
    'post': '发布',
    'title': '标题',
    'content': '内容',
    'titleRequired': '请输入标题',
    'contentRequired': '请输入内容',
    'findMatch': '寻找匹配的伙伴',
    'languageExchangeMatching': '语言交流匹配',
    'matchFound': '找到匹配对象！',
    'targetLanguage': '目标语言',
    'gender': '性别',
    'college': '学院',
    'startChat': '开始聊天',
    'goBack': '返回',
    'tryAgain': '重试',
    'changeConditions': '更改条件',
    'noMatchFound': '未找到匹配的伙伴。\n(目标语言: {targetLang})',
    'schoolInformation': '学校信息',
    'tellUsAboutAcademicBackground': '请告诉我们您的学术背景',
    'department': '专业',
    'southKorea': '韩国',
    'vietnam': '越南',
    'unitedStates': '美国',
    'japan': '日本',
    'china': '中国',
    'personalInformation': '个人信息',
    'profileSetup': '个人资料设置',
    'nickname': '昵称',
    'enrollmentYear': '入学年份',
    'male': '男',
    'female': '女',
    'featuredNews': '精选新闻',
    'board': '公告板',
    'noticeBoard': '公告板',
    'freeBoard': '自由板',
    'infoBoard': '信息板',
    'promoBoard': '宣传板',
    'languageExchangeChat': '语言交流聊天',
    'findLanguageExchangePartner': '选择您想学习的语言和条件来找到语言交流伙伴！',
    'noLanguageExchangeChatHistory': '还没有语言交流聊天记录。\n从主屏幕开始匹配吧！',
    'noPostsYet': '还没有帖子。',
    'editProfileStep': '编辑资料 - 步骤 {step}/2',
    'step': '步骤',
    'stepSeparator': '/',
    'basicInformation': '基本信息',
    'pleaseProvideBasicInformation': '请提供您的基本信息',
    'pleaseReviewBeforeSaving': '请在保存前查看您的信息',
    'pleaseReviewBeforeCompleting': '请在完成前查看您的信息',
    'reviewAndComplete': '审查和完成',
    'realName': '真实姓名',
    'completeRegistration': '完成注册',
    'deletePost': '删除帖子',
    'deletePostConfirm': '您确定要删除此帖子吗？',
    'postDeleted': '帖子已成功删除',
    'cannotDeletePost': '无法删除帖子',
    'delete': '删除',
    'latestNoticeTitle': '开学及教务日程通知',
    'latestFreeTitle': '考试结束了！这个星期六你做什么？',
    'latestInfoTitle': '2025交换生招募信息',
    'latestPromoTitle': '社团宣传 – 新成员招募',
    'postLabel': '帖子',
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
    'studentId': '学籍番号',
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
    'reviewAndSave': '確認と保存',
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
    'recentActivity': '最近の活動',
    'welcomeToHelloCampus': 'Hello Campusへようこそ！',
    'accountCreatedSuccessfully': 'アカウントが正常に作成されました。キャンパスを探索しましょう！',
    'hoursAgo': '時間前',
    'news': 'ニュース',
    'international': '国際',
    'domestic': '国内',
    'retry': '再試行',
    'more': 'もっと見る',
    'languageChangedTo': '言語が変更されました',
    'languageOrder': '言語注文',
    'shareFunctionalityComingSoon': '共有機能は間もなく利用可能になります！',
    'like': 'いいね',
    'bookmark': 'ブックマーク',
    'bookmarkFunctionalityComingSoon': 'ブックマーク機能は間もなく利用可能になります！',
    'postPublishedSuccessfully': '投稿が正常に公開されました！',
    'errorOccurred': 'エラーが発生しました',
    'registrationSuccessful': '登録が完了しました！ログインしてください。',
    'pleaseLogin': 'ログインしてください。',
    'pleaseFillAllRequiredFields': 'すべての必須項目を入力してください',
    'searchNews': 'ニュース検索',
    'cancel': 'キャンセル',
    'search': '検索',
    'edit': '編集',
    'noSearchResults': '検索結果が見つかりませんでした。',
    'writePost': '投稿を書く',
    'writeAnonymously': '匿名で投稿',
    'post': '投稿',
    'title': 'タイトル',
    'content': '内容',
    'titleRequired': 'タイトルを入力してください',
    'contentRequired': '内容を入力してください',
    'findMatch': 'マッチするパートナーを見つける',
    'languageExchangeMatching': '言語交換マッチング',
    'matchFound': 'マッチが見つかりました！',
    'targetLanguage': '目標言語',
    'gender': '性別',
    'college': '学部',
    'startChat': 'チャットを開始',
    'goBack': '戻る',
    'tryAgain': '再試行',
    'changeConditions': '条件を変更',
    'noMatchFound': 'マッチするパートナーが見つかりませんでした。\n(目標言語: {targetLang})',
    'schoolInformation': '学校情報',
    'tellUsAboutAcademicBackground': '学歴について教えてください',
    'department': '学科',
    'southKorea': '韓国',
    'vietnam': 'ベトナム',
    'unitedStates': 'アメリカ',
    'japan': '日本',
    'china': '中国',
    'personalInformation': '個人情報',
    'profileSetup': 'プロフィール設定',
    'nickname': 'ニックネーム',
    'enrollmentYear': '入学年',
    'male': '男性',
    'female': '女性',
    'featuredNews': '注目ニュース',
    'board': '掲示板',
    'noticeBoard': 'お知らせ掲示板',
    'freeBoard': '自由掲示板',
    'infoBoard': '情報掲示板',
    'promoBoard': '宣伝掲示板',
    'languageExchangeChat': '言語交換チャット',
    'findLanguageExchangePartner': '学びたい言語と条件を選択して言語交換パートナーを見つけましょう！',
    'noLanguageExchangeChatHistory': '言語交換チャットの履歴がまだありません。\nホーム画面からマッチングを始めましょう！',
    'noPostsYet': 'まだ投稿がありません。',
    'editProfileStep': 'プロフィール編集 - ステップ {step}/2',
    'step': 'ステップ',
    'stepSeparator': '/',
    'basicInformation': '基本情報',
    'pleaseProvideBasicInformation': '基本情報を入力してください',
    'pleaseReviewBeforeSaving': '保存前に情報を確認してください',
    'pleaseReviewBeforeCompleting': '完了前に情報を確認してください',
    'reviewAndComplete': '確認と完了',
    'realName': '本名',
    'completeRegistration': '登録完了',
    'deletePost': '投稿を削除',
    'deletePostConfirm': 'この投稿を削除してもよろしいですか？',
    'postDeleted': '投稿が正常に削除されました',
    'cannotDeletePost': '投稿を削除できません',
    'delete': '削除',
    'latestNoticeTitle': '開講および学務スケジュールのお知らせ',
    'latestFreeTitle': '試験終了！土曜日は何をしますか？',
    'latestInfoTitle': '2025交換留学生募集情報',
    'latestPromoTitle': 'サークル宣伝 – 新メンバー募集',
    'postLabel': '投稿',
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
    'studentId': 'ကျောင်းသားနံပါတ်',
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
    'reviewAndSave': 'ပြန်လည်စစ်ဆေးပြီး သိမ်းဆည်းပါ',
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
    'recentActivity': 'လတ်တလော လုပ်ဆောင်မှုများ',
    'welcomeToHelloCampus': 'Hello Campus မှကြိုဆိုပါတယ်！',
    'accountCreatedSuccessfully': 'သင့်အကောင့်ကို အောင်မြင်စွာ ဖန်တီးပြီးပါပြီ။ သင့်တက္ကသိုလ်ကို စတင်လေ့လာပါ！',
    'hoursAgo': 'နာရီအကြာက',
    'news': 'သတင်းများ',
    'international': 'နိုင်ငံတကာ',
    'domestic': 'ပြည်တွင်း',
    'retry': 'ပြန်လည်စမ်းသပ်ပါ',
    'more': 'ပိုမိုကြည့်ရှုရန်',
    'languageChangedTo': 'ဘာသာစကား ပြောင်းလဲပြီးပါပြီ',
    'languageOrder': 'ဘာသာစကား အမှာစာ',
    'shareFunctionalityComingSoon': 'မျှဝေခြင်း လုပ်ဆောင်ချက်သည် မကြာမီ ရရှိပါမည်！',
    'like': 'ကြိုက်နှစ်သက်သည်',
    'bookmark': 'စာအုပ်မှတ်သားရန်',
    'bookmarkFunctionalityComingSoon': 'စာအုပ်မှတ်သားခြင်း လုပ်ဆောင်ချက်သည် မကြာမီ ရရှိပါမည်！',
    'postPublishedSuccessfully': 'စာတမ်းကို အောင်မြင်စွာ ထုတ်ဝေပြီးပါပြီ！',
    'errorOccurred': 'အမှားတစ်ခု ဖြစ်ပွားခဲ့သည်',
    'registrationSuccessful': 'အကောင့်ဖွင့်ခြင်း အောင်မြင်ပါပြီ！ အကောင့်ဝင်ရောက်ပါ။',
    'pleaseLogin': 'အကောင့်ဝင်ရောက်ပါ။',
    'pleaseFillAllRequiredFields': 'လိုအပ်သော အကွက်အားလုံးကို ဖြည့်သွင်းပါ',
    'searchNews': 'သတင်းများ ရှာဖွေရန်',
    'cancel': 'ပယ်ဖျက်ရန်',
    'search': 'ရှာဖွေရန်',
    'edit': 'ပြင်ဆင်ရန်',
    'noSearchResults': 'ရှာဖွေမှုရလဒ်များ မတွေ့ရှိပါ။',
    'writePost': 'စာတမ်းရေးရန်',
    'writeAnonymously': 'အမည်မဖော်ဘဲ ရေးရန်',
    'post': 'ထုတ်ဝေရန်',
    'title': 'ခေါင်းစဉ်',
    'content': 'အကြောင်းအရာ',
    'titleRequired': 'ခေါင်းစဉ်ထည့်သွင်းပါ',
    'contentRequired': 'အကြောင်းအရာထည့်သွင်းပါ',
    'findMatch': 'ကိုက်ညီသော လက်တွဲဖော်ရှာရန်',
    'languageExchangeMatching': 'ဘာသာစကား ဖလှယ်ခြင်း ပေါင်းစပ်ခြင်း',
    'matchFound': 'လက်တွဲဖော်ကို တွေ့ရှိပါပြီ!',
    'targetLanguage': 'ဦးတည်ဘာသာစကား',
    'gender': 'လိင်',
    'college': 'ကောလိပ်',
    'startChat': 'စကားပြောစတင်ရန်',
    'goBack': 'ပြန်သွားရန်',
    'tryAgain': 'ပြန်လည်စမ်းသပ်ရန်',
    'changeConditions': 'အခြေအနေများ ပြောင်းလဲရန်',
    'noMatchFound': 'ကိုက်ညီသော လက်တွဲဖော် မတွေ့ရှိပါ။\n(ဦးတည်ဘာသာစကား: {targetLang})',
    'schoolInformation': 'ကျောင်းအချက်အလက်',
    'tellUsAboutAcademicBackground': 'သင့်ပညာရေးနောက်ခံအကြောင်း ပြောပြပါ',
    'department': 'ဌာန',
    'southKorea': 'တောင်ကိုရီးယား',
    'vietnam': 'ဗီယက်နမ်',
    'unitedStates': 'အမေရိကန်ပြည်ထောင်စု',
    'japan': 'ဂျပန်',
    'china': 'တရုတ်',
    'personalInformation': 'ကိုယ်ရေးအချက်အလက်',
    'profileSetup': 'ကိုယ်ရေးအချက်အလက် စနစ်သွင်းခြင်း',
    'nickname': 'အမည်ပြောင်',
    'enrollmentYear': 'စာရင်းသွင်းနှစ်',
    'male': 'အမျိုးသား',
    'female': 'အမျိုးသမီး',
    'featuredNews': 'ထင်ရှားသော သတင်းများ',
    'board': 'ကြေညာချက်',
    'noticeBoard': 'အကြောင်းကြားစာ',
    'freeBoard': 'လွတ်လပ်သော',
    'infoBoard': 'အချက်အလက်',
    'promoBoard': 'ကြော်ငြာ',
    'languageExchangeChat': 'ဘာသာစကား ဖလှယ်ခြင်း စကားပြောဆို',
    'findLanguageExchangePartner': 'သင်လေ့လာလိုသော ဘာသာစကားနှင့် အခြေအနေများကို ရွေးချယ်ပြီး ဘာသာစကား ဖလှယ်ရန် လက်တွဲဖော်ကို ရှာဖွေပါ！',
    'noLanguageExchangeChatHistory': 'ဘာသာစကား ဖလှယ်ခြင်း စကားပြောဆို မှတ်တမ်းများ မရှိသေးပါ။\nပင်မ မျက်နှာပြင်မှ ပေါင်းစပ်ခြင်းကို စတင်ပါ！',
    'noPostsYet': 'ပို့စ်များ မရှိသေးပါ။',
    'editProfileStep': 'ကိုယ်ရေးအချက်အလက် ပြင်ဆင်ရန် - အဆင့် {step}/2',
    'step': 'အဆင့်',
    'stepSeparator': '/',
    'basicInformation': 'အခြေခံ အချက်အလက်',
    'pleaseProvideBasicInformation': 'သင့်အခြေခံ အချက်အလက်များကို ပေးပါ',
    'pleaseReviewBeforeSaving': 'သိမ်းဆည်းမီ သင့်အချက်အလက်များကို ပြန်လည်စစ်ဆေးပါ',
    'pleaseReviewBeforeCompleting': 'ပြီးမြောက်မီ သင့်အချက်အလက်များကို ပြန်လည်စစ်ဆေးပါ',
    'reviewAndComplete': 'ပြန်လည်စစ်ဆေးပြီး ပြီးမြောက်ရန်',
    'realName': 'အမည်ရင်း',
    'completeRegistration': 'အကောင့်ဖွင့်ခြင်း ပြီးမြောက်ရန်',
    'deletePost': 'စာတမ်း ဖျက်ရန်',
    'deletePostConfirm': 'ဤစာတမ်းကို ဖျက်ရန် သေချာပါသလား?',
    'postDeleted': 'စာတမ်း အောင်မြင်စွာ ဖျက်ပြီးပါပြီ',
    'cannotDeletePost': 'စာတမ်း ဖျက်၍မရပါ',
    'delete': 'ဖျက်ရန်',
    'latestNoticeTitle': 'ကျောင်းဖွင့်ခြင်းနှင့် ပညာရေးအစီအစဉ် အကြောင်းကြားချက်',
    'latestFreeTitle': 'စာမေးပွဲပြီးပြီ! စနေနေ့မှာ ဘာလုပ်မလဲ?',
    'latestInfoTitle': '၂၀၂၅ လဲလှယ်ကျောင်းသား စုဆောင်းမှု အချက်အလက်',
    'latestPromoTitle': 'ကလပ်များ ကြော်ငြာ – အဖွဲ့ဝင် အသစ် စုဆောင်းခြင်း',
    'postLabel': 'စာတမ်း',
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
  String get studentId => translate('studentId');
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
  String get recentActivity => translate('recentActivity');
  String get welcomeToHelloCampus => translate('welcomeToHelloCampus');
  String get accountCreatedSuccessfully => translate('accountCreatedSuccessfully');
  String get hoursAgo => translate('hoursAgo');
  String get news => translate('news');
  String get international => translate('international');
  String get domestic => translate('domestic');
  String get retry => translate('retry');
  String get more => translate('more');
  String get languageChangedTo => translate('languageChangedTo');
  String get languageOrder => translate('languageOrder');
  String get shareFunctionalityComingSoon => translate('shareFunctionalityComingSoon');
  String get like => translate('like');
  String get bookmark => translate('bookmark');
  String get bookmarkFunctionalityComingSoon => translate('bookmarkFunctionalityComingSoon');
  String get postPublishedSuccessfully => translate('postPublishedSuccessfully');
  String get errorOccurred => translate('errorOccurred');
  String get registrationSuccessful => translate('registrationSuccessful');
  String get pleaseLogin => translate('pleaseLogin');
  String get pleaseFillAllRequiredFields => translate('pleaseFillAllRequiredFields');
  String get previous => translate('previous');
  String get next => translate('next');
  String get searchNews => translate('searchNews');
  String get cancel => translate('cancel');
  String get search => translate('search');
  String get edit => translate('edit');
  String get translateText => translate('translate');
  String get showOriginal => translate('showOriginal');
  String get translating => translate('translating');
  String get translationFailed => translate('translationFailed');
  String get saveProfile => translate('saveProfile');
  String get profileUpdated => translate('profileUpdated');
  String get noSearchResults => translate('noSearchResults');
  String get writePost => translate('writePost');
  String get writeAnonymously => translate('writeAnonymously');
  String get post => translate('post');
  String get title => translate('title');
  String get content => translate('content');
  String get titleRequired => translate('titleRequired');
  String get contentRequired => translate('contentRequired');
  String get findMatch => translate('findMatch');
  String get languageExchangeMatching => translate('languageExchangeMatching');
  String get matchFound => translate('matchFound');
  String get targetLanguage => translate('targetLanguage');
  String get gender => translate('gender');
  String get college => translate('college');
  String get startChat => translate('startChat');
  String get goBack => translate('goBack');
  String get tryAgain => translate('tryAgain');
  String get changeConditions => translate('changeConditions');
  String noMatchFound(String targetLang) => translate('noMatchFound').replaceAll('{targetLang}', targetLang);
  String get schoolInformation => translate('schoolInformation');
  String get tellUsAboutAcademicBackground => translate('tellUsAboutAcademicBackground');
  String get department => translate('department');
  String get southKorea => translate('southKorea');
  String get vietnam => translate('vietnam');
  String get unitedStates => translate('unitedStates');
  String get japan => translate('japan');
  String get china => translate('china');
  String get personalInformation => translate('personalInformation');
  String get profileSetup => translate('profileSetup');
  String get nickname => translate('nickname');
  String get enrollmentYear => translate('enrollmentYear');
  String get male => translate('male');
  String get female => translate('female');
  String get reviewAndSave => translate('reviewAndSave');
  String get featuredNews => translate('featuredNews');
  String get board => translate('board');
  String get noticeBoard => translate('noticeBoard');
  String get freeBoard => translate('freeBoard');
  String get infoBoard => translate('infoBoard');
  String get promoBoard => translate('promoBoard');
  String get languageExchangeChat => translate('languageExchangeChat');
  String get findLanguageExchangePartner => translate('findLanguageExchangePartner');
  String get noLanguageExchangeChatHistory => translate('noLanguageExchangeChatHistory');
  String get noPostsYet => translate('noPostsYet');
  String editProfileStep(int step) => translate('editProfileStep').replaceAll('{step}', step.toString());
  String get step => translate('step');
  String get stepSeparator => translate('stepSeparator');
  String get basicInformation => translate('basicInformation');
  String get pleaseProvideBasicInformation => translate('pleaseProvideBasicInformation');
  String get pleaseReviewBeforeSaving => translate('pleaseReviewBeforeSaving');
  String get pleaseReviewBeforeCompleting => translate('pleaseReviewBeforeCompleting');
  String get reviewAndComplete => translate('reviewAndComplete');
  String get realName => translate('realName');
  String get completeRegistration => translate('completeRegistration');
  
  String get visitOfficialWebsite => translate('visitOfficialWebsite');
  String get selectBoard => translate('selectBoard');
  String get pleaseSelectBoard => translate('pleaseSelectBoard');
  String get searching => translate('searching');
  String get tryAgainLater => translate('tryAgainLater');
  String get noMessagesYet => translate('noMessagesYet');
  String get typeMessage => translate('typeMessage');
  String get matchAccepted => translate('matchAccepted');
  String get matchRejected => translate('matchRejected');
  String get deleteConversation => translate('deleteConversation');
  String deleteConversationConfirm(String partnerName) => translate('deleteConversationConfirm').replaceAll('{partnerName}', partnerName);
  String get conversationDeleted => translate('conversationDeleted');
  String get cannotDeleteConversation => translate('cannotDeleteConversation');
  String get deleteMessage => translate('deleteMessage');
  String get deleteMessageConfirm => translate('deleteMessageConfirm');
  String get messageDeleted => translate('messageDeleted');
  String get cannotDeleteMessage => translate('cannotDeleteMessage');
  String get cannotLoadMessages => translate('cannotLoadMessages');
  String get sendMessageFailed => translate('sendMessageFailed');
  String get noConversationsYet => translate('noConversationsYet');
  String get startFindingLanguagePartner => translate('startFindingLanguagePartner');
  String get loadingConversations => translate('loadingConversations');
  String get errorLoadingData => translate('errorLoadingData');
  String get failedToUpdateProfile => translate('failedToUpdateProfile');
  String get couldNotLoadOptions => translate('couldNotLoadOptions');
  String get couldNotLoadDepartments => translate('couldNotLoadDepartments');
  String get pleaseSelectUniversity => translate('pleaseSelectUniversity');
  String get pleaseSelectDepartment => translate('pleaseSelectDepartment');
  String get loading => translate('loading');
  String get selectSchoolFirst => translate('selectSchoolFirst');
  String get error => translate('error');
  String get failedToCreateMatchRequest => translate('failedToCreateMatchRequest');
  String get errorParsingHelpers => translate('errorParsingHelpers');
  String get errorFindingMatch => translate('errorFindingMatch');
  String get missingMatchInformation => translate('missingMatchInformation');
  String get errorOfferingMatch => translate('errorOfferingMatch');
  String get errorAcceptingMatch => translate('errorAcceptingMatch');
  String get failedToCreateConversation => translate('failedToCreateConversation');
  String get justNow => translate('justNow');
  String minutesAgo(int count) => translate('minutesAgo').replaceAll('{count}', count.toString());
  String hoursAgoShort(int count) => translate('hoursAgoShort').replaceAll('{count}', count.toString());
  String daysAgoShort(int count) => translate('daysAgoShort').replaceAll('{count}', count.toString());
  String get startConversation => translate('startConversation');
  String get translated => translate('translated');
  String get validStudentEmail => translate('validStudentEmail');
  String get pleaseConfirmPassword => translate('pleaseConfirmPassword');
  String get mainLanguage => translate('mainLanguage');
  String get studentEmail => translate('studentEmail');
  String get selectLanguageToLearn => translate('selectLanguageToLearn');
  String get selectLanguageToLearnRequired => translate('selectLanguageToLearnRequired');
  String get preferredGender => translate('preferredGender');
  String get selectLanguageGenderCollege => translate('selectLanguageGenderCollege');
  String get noPreference => translate('noPreference');
  String get latestNoticeTitle => translate('latestNoticeTitle');
  String get latestFreeTitle => translate('latestFreeTitle');
  String get latestInfoTitle => translate('latestInfoTitle');
  String get latestPromoTitle => translate('latestPromoTitle');
  String get deletePost => translate('deletePost');
  String get deletePostConfirm => translate('deletePostConfirm');
  String get postDeleted => translate('postDeleted');
  String get cannotDeletePost => translate('cannotDeletePost');
  String get delete => translate('delete');
  String get postLabel => translate('postLabel');
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
