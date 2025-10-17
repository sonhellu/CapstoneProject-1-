import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  ];
  
  // English translations
  static const Map<String, String> _en = {
    'appTitle': 'Hello Campus',
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
    'welcome': 'Welcome to Hello Campus',
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
    'appTitle': '헬로 캠퍼스',
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
    'welcome': '헬로 캠퍼스에 오신 것을 환영합니다',
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
    'appTitle': 'Hello Campus',
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
    'chat': 'Chat',
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
  
  String translate(String key) {
    Map<String, String> translations;
    switch (locale.languageCode) {
      case 'ko':
        translations = _ko;
        break;
      case 'vi':
        translations = _vi;
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
  String get welcome => translate('welcome');
  String get welcomeMessage => translate('welcomeMessage');
  String get fullName => translate('fullName');
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
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();
  
  @override
  bool isSupported(Locale locale) {
    return ['en', 'ko', 'vi'].contains(locale.languageCode);
  }
  
  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }
  
  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
