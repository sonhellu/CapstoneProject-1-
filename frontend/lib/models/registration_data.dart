class RegistrationData {
  // Step 1: Personal Information
  String email = '';
  String password = '';
  String confirmPassword = '';
  String realName = '';

  // Step 2: Profile Information
  String nickname = '';
  String mainLanguage = 'ko';
  String nationalityIso2 = 'KR';

  // Step 3: School Information
  int schoolId = 1;
  String schoolIdString = ''; // For user input
  int departmentId = 1;
  int enrollmentYear = DateTime.now().year;

  // Validation methods
  bool isStep1Valid() {
    return email.isNotEmpty && 
           password.isNotEmpty && 
           confirmPassword.isNotEmpty && 
           realName.isNotEmpty &&
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
    return (schoolId > 0 || schoolIdString.isNotEmpty) && 
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
      'main_language': mainLanguage,
      'nationality_iso2': nationalityIso2,
      'school_id': schoolIdString.isNotEmpty ? int.tryParse(schoolIdString) ?? schoolId : schoolId,
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
    nickname = '';
    mainLanguage = 'ko';
    nationalityIso2 = 'KR';
    schoolId = 1;
    schoolIdString = '';
    departmentId = 1;
    enrollmentYear = DateTime.now().year;
  }
}
