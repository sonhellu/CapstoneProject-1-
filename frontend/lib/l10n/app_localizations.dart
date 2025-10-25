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
    'codeSentTo': '验证码已发送至'
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
    'codeSentTo': '認証コードが送信されました'
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
    'codeSentTo': 'အတည်ပြုကုဒ်ကို ပို့ပြီးပါပြီ'
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
  
  // Notification translations
  String get notifications => translate('notifications');
  String get unreadNotifications => translate('unreadNotifications');
  String get noNotifications => translate('noNotifications');
  String get noNotificationsMessage => translate('noNotificationsMessage');
  String get markAllAsRead => translate('markAllAsRead');
  String get visitOfficialWebsite => translate('visitOfficialWebsite');
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
