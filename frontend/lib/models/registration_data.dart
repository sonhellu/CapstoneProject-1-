class RegistrationData {
  // Step 1: Personal Information
  String email = '';
  String password = '';
  String confirmPassword = '';
  String realName = '';
  String gender = 'male'; // Thêm trường gender

  // Step 2: Profile Information
  String nickname = '';
  String mainLanguage = 'ko';
  String nationalityIso2 = 'KR';

  // Step 3: School Information
  String studentId = ''; // Student ID - user can input freely (optional)
  int schoolId = 1;
  int departmentId = 1;
  int enrollmentYear = DateTime.now().year;

  // Validation methods
  bool isStep1Valid() {
    return email.isNotEmpty && 
           password.isNotEmpty && 
           confirmPassword.isNotEmpty && 
           realName.isNotEmpty &&
           gender.isNotEmpty &&
           password == confirmPassword &&
           _isValidEmail(email) &&
           password.length >= 6;
  }

  bool isStep2Valid() {
    return nickname.isNotEmpty && 
           mainLanguage.isNotEmpty && 
           nationalityIso2.isNotEmpty;
  }

  bool isStep3Valid() {
    return schoolId > 0 && 
           departmentId > 0 && 
           enrollmentYear > 2000;
  }

  bool isAllStepsValid() {
    return isStep1Valid() && isStep2Valid() && isStep3Valid();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Convert to API format
  Map<String, dynamic> toApiFormat() {
    return {
      'email': email,
      'password': password,
      'nickname': nickname,
      'realname': realName,
      'student_id': studentId.trim(), // Student ID - optional
      'gender': gender,
      'main_language': mainLanguage,
      'nationality_iso2': nationalityIso2,
      'school_id': schoolId,
      'department_id': departmentId,
      'enrollment_year': enrollmentYear,
    };
  }

  // Reset all data
  void reset() {
    email = '';
    password = '';
    confirmPassword = '';
    realName = '';
    gender = 'male';
    nickname = '';
    mainLanguage = 'ko';
    nationalityIso2 = 'KR';
    studentId = '';
    schoolId = 1;
    departmentId = 1;
    enrollmentYear = DateTime.now().year;
  }
}
