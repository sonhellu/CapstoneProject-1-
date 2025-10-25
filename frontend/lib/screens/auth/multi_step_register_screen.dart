import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/registration_data.dart';

class MultiStepRegisterScreen extends StatefulWidget {
  final Function(String)? onLanguageChanged;
  
  const MultiStepRegisterScreen({super.key, this.onLanguageChanged});

  @override
  State<MultiStepRegisterScreen> createState() => _MultiStepRegisterScreenState();
}

class _MultiStepRegisterScreenState extends State<MultiStepRegisterScreen> 
    with TickerProviderStateMixin {
  
  final PageController _pageController = PageController();
  final RegistrationData _registrationData = RegistrationData();
  
  int _currentStep = 0;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Form controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _realNameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _schoolIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _realNameController.dispose();
    _nicknameController.dispose();
    _schoolIdController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      // Validate current step before proceeding
      if (_validateCurrentStep()) {
        _saveCurrentStepData();
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        setState(() {
          _currentStep++;
        });
      }
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0: // Step 1: Personal Info
        return _formKey.currentState!.validate();
      case 1: // Step 2: Profile Info
        return _formKey.currentState!.validate();
      case 2: // Step 3: School Info
        return true; // Dropdowns are always valid
      default:
        return true;
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep--;
      });
    }
  }

  void _saveCurrentStepData() {
    switch (_currentStep) {
      case 0: // Step 1: Personal Info
        _registrationData.email = _emailController.text;
        _registrationData.password = _passwordController.text;
        _registrationData.confirmPassword = _confirmPasswordController.text;
        _registrationData.realName = _realNameController.text;
        break;
      case 1: // Step 2: Profile Info
        _registrationData.nickname = _nicknameController.text;
        break;
      case 2: // Step 3: School Info
        _registrationData.schoolIdString = _schoolIdController.text;
        break;
    }
  }

  Future<void> _completeRegistration() async {
    if (!_registrationData.isAllStepsValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      // Save language preference to SharedPreferences
      await _saveLanguagePreference(_registrationData.mainLanguage);
      
      // Save all registration data to SharedPreferences
      await _saveRegistrationData();

      // Show success message in selected language
      String successMessage = _getSuccessMessage(_registrationData.mainLanguage);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(successMessage),
          backgroundColor: Colors.green[600],
          duration: const Duration(seconds: 3),
        ),
      );

      // Trigger language change callback BEFORE navigation
      if (widget.onLanguageChanged != null) {
        widget.onLanguageChanged!(_registrationData.mainLanguage);
        
        // Wait a bit for language change to take effect
        await Future.delayed(const Duration(milliseconds: 300));
      }
      
      // Navigate back to login with language change
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _saveLanguagePreference(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', languageCode);
  }

  Future<void> _saveRegistrationData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save all registration data
    await prefs.setString('email', _registrationData.email);
    await prefs.setString('realName', _registrationData.realName);
    await prefs.setString('nickname', _registrationData.nickname);
    await prefs.setString('mainLanguage', _registrationData.mainLanguage);
    await prefs.setString('nationalityIso2', _registrationData.nationalityIso2);
    await prefs.setInt('schoolId', _registrationData.schoolId);
    await prefs.setString('schoolIdString', _registrationData.schoolIdString);
    await prefs.setInt('departmentId', _registrationData.departmentId);
    await prefs.setInt('enrollmentYear', _registrationData.enrollmentYear);
    
    // Mark user as logged in
    await prefs.setBool('isLoggedIn', true);
  }

  String _getSuccessMessage(String languageCode) {
    switch (languageCode) {
      case 'ko':
        return '회원가입이 성공적으로 완료되었습니다! 로그인해주세요.';
      case 'vi':
        return 'Đăng ký thành công! Vui lòng đăng nhập.';
      case 'ja':
        return '登録が正常に完了しました！ログインしてください。';
      case 'zh':
        return '注册成功！请登录。';
      case 'my':
        return 'အောင်မြင်စွာ စာရင်းသွင်းပြီးပါပြီ။ ကျေးဇူးပြု၍ ဝင်ရောက်ပါ။';
      case 'en':
      default:
        return 'Registration successful! Please login.';
    }
  }

  // Validation methods
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    // Check for @stu domain
    if (!RegExp(r'^[\w-\.]+@stu\.[\w-]{2,4}$').hasMatch(value)) {
      return 'Please use a valid student email (@stu)';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  String? _validateRequired(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[600],
        title: Text(
          'Register (${_currentStep + 1}/4)',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark 
              ? [
                  const Color(0xFF1E1E1E),
                  const Color(0xFF121212),
                ]
              : [
                  Colors.red[50]!,
                  Colors.white,
                ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Progress indicator
              _buildProgressIndicator(isDark),
              
              // Page content
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildStep1(isDark),
                        _buildStep2(isDark),
                        _buildStep3(isDark),
                        _buildStep4(isDark),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Navigation buttons
              _buildNavigationButtons(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: List.generate(4, (index) {
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
                  height: 4,
                  decoration: BoxDecoration(
                    color: index <= _currentStep 
                        ? Colors.red[600] 
                        : (isDark ? Colors.grey[700] : Colors.grey[300]),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            _getStepTitle(_currentStep),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.red[800],
            ),
          ),
        ],
      ),
    );
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 0: return 'Personal Information';
      case 1: return 'Profile Setup';
      case 2: return 'School Information';
      case 3: return 'Review & Complete';
      default: return '';
    }
  }

  Widget _buildStep1(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          
          // Icon
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.red[600]!, Colors.red[700]!],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.person_add,
              size: 60,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 40),
          
          // Title
          Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.red[800],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Let\'s start with your basic information',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white70 : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          
          // Form fields
          Form(
            key: _formKey,
            child: Column(
              children: [
                _buildFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  labelText: 'Student Email (@stu)',
                  prefixIcon: Icons.email_outlined,
                  isDark: isDark,
                  validator: _validateEmail,
                ),
                const SizedBox(height: 20),
                
                _buildFormField(
                  controller: _passwordController,
                  obscureText: true,
                  labelText: 'Password',
                  prefixIcon: Icons.lock_outline,
                  isDark: isDark,
                  validator: _validatePassword,
                ),
                const SizedBox(height: 20),
                
                _buildFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  labelText: 'Confirm Password',
                  prefixIcon: Icons.lock_reset,
                  isDark: isDark,
                  validator: _validateConfirmPassword,
                ),
                const SizedBox(height: 20),
                
                _buildFormField(
                  controller: _realNameController,
                  labelText: 'Real Name',
                  prefixIcon: Icons.badge_outlined,
                  isDark: isDark,
                  validator: _validateRequired,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          
          // Icon
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue[600]!, Colors.blue[700]!],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.person,
              size: 60,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 40),
          
          // Title
          Text(
            'Profile Setup',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.blue[800],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Tell us more about yourself',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white70 : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          
          // Form fields
          Form(
            key: _formKey,
            child: _buildFormField(
              controller: _nicknameController,
              labelText: 'Nickname',
              prefixIcon: Icons.alternate_email,
              isDark: isDark,
              validator: _validateRequired,
            ),
          ),
          const SizedBox(height: 20),
          
          _buildDropdownField(
            value: _registrationData.mainLanguage,
            labelText: 'Main Language',
            icon: Icons.translate,
            items: const [
              DropdownMenuItem(value: 'ko', child: Text('한국어')),
              DropdownMenuItem(value: 'en', child: Text('English')),
              DropdownMenuItem(value: 'vi', child: Text('Tiếng Việt')),
              DropdownMenuItem(value: 'ja', child: Text('日本語')),
              DropdownMenuItem(value: 'zh', child: Text('中文')),
              DropdownMenuItem(value: 'my', child: Text('မြန်မာ')),
            ],
            onChanged: (value) {
              setState(() {
                _registrationData.mainLanguage = value!;
              });
            },
            isDark: isDark,
          ),
          const SizedBox(height: 20),
          
          _buildDropdownField(
            value: _registrationData.nationalityIso2,
            labelText: 'Nationality',
            icon: Icons.public,
            items: const [
              DropdownMenuItem(value: 'KR', child: Text('🇰🇷 South Korea')),
              DropdownMenuItem(value: 'VN', child: Text('🇻🇳 Vietnam')),
              DropdownMenuItem(value: 'US', child: Text('🇺🇸 United States')),
              DropdownMenuItem(value: 'JP', child: Text('🇯🇵 Japan')),
              DropdownMenuItem(value: 'CN', child: Text('🇨🇳 China')),
              DropdownMenuItem(value: 'MM', child: Text('🇲🇲 Myanmar')),
            ],
            onChanged: (value) {
              setState(() {
                _registrationData.nationalityIso2 = value!;
              });
            },
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildStep3(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          
          // Icon
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.green[600]!, Colors.green[700]!],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.school,
              size: 60,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 40),
          
          // Title
          Text(
            'School Information',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.green[800],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Tell us about your academic background',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white70 : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          
          // Form fields
          _buildFormField(
            controller: _schoolIdController,
            keyboardType: TextInputType.number,
            labelText: 'School ID',
            prefixIcon: Icons.credit_card,
            isDark: isDark,
          ),
          const SizedBox(height: 20),
          
          _buildDropdownField(
            value: _registrationData.schoolId,
            labelText: 'School',
            icon: Icons.school_outlined,
            items: const [
              DropdownMenuItem(value: 1, child: Text(' Keimyung University')),
              DropdownMenuItem(value: 2, child: Text(' Seoul National University')),
              DropdownMenuItem(value: 3, child: Text(' Korea University')),
              DropdownMenuItem(value: 4, child: Text(' Yonsei University')),
              DropdownMenuItem(value: 5, child: Text(' KAIST')),
              DropdownMenuItem(value: 6, child: Text(' Sungkyunkwan University')),
              DropdownMenuItem(value: 7, child: Text(' Hongik University')),
              DropdownMenuItem(value: 8, child: Text(' Hanyang University')),
              DropdownMenuItem(value: 9, child: Text(' Chung-Ang University')),
              DropdownMenuItem(value: 10, child: Text(' Kyung Hee University')),
              DropdownMenuItem(value: 11, child: Text(' Ewha Womans University')),
              DropdownMenuItem(value: 12, child: Text(' Sogang University')),
              DropdownMenuItem(value: 13, child: Text(' Pusan National University')),
              DropdownMenuItem(value: 14, child: Text(' Inha University')),
              DropdownMenuItem(value: 15, child: Text(' Other University')),
            ],
            onChanged: (value) {
              setState(() {
                _registrationData.schoolId = value!;
              });
            },
            isDark: isDark,
          ),
          const SizedBox(height: 20),
          
          _buildDropdownField(
            value: _registrationData.departmentId,
            labelText: 'Department',
            icon: Icons.business_center,
            items: const [
              DropdownMenuItem(value: 1, child: Text(' Computer Science')),
              DropdownMenuItem(value: 2, child: Text(' Business Administration')),
              DropdownMenuItem(value: 3, child: Text(' Engineering')),
              DropdownMenuItem(value: 4, child: Text(' Liberal Arts')),
              DropdownMenuItem(value: 5, child: Text(' Medicine')),
              DropdownMenuItem(value: 6, child: Text(' Law')),
              DropdownMenuItem(value: 7, child: Text(' Fine Arts')),
              DropdownMenuItem(value: 8, child: Text(' Music')),
              DropdownMenuItem(value: 9, child: Text(' Physical Education')),
              DropdownMenuItem(value: 10, child: Text(' Natural Sciences')),
              DropdownMenuItem(value: 11, child: Text(' International Studies')),
              DropdownMenuItem(value: 12, child: Text(' Media & Communication')),
              DropdownMenuItem(value: 13, child: Text(' Architecture')),
              DropdownMenuItem(value: 14, child: Text(' Culinary Arts')),
              DropdownMenuItem(value: 15, child: Text(' Early Childhood Education')),
              DropdownMenuItem(value: 16, child: Text(' Environmental Science')),
              DropdownMenuItem(value: 17, child: Text(' Psychology')),
              DropdownMenuItem(value: 18, child: Text(' Economics')),
              DropdownMenuItem(value: 19, child: Text(' Information Technology')),
              DropdownMenuItem(value: 20, child: Text(' Theater & Film')),
            ],
            onChanged: (value) {
              setState(() {
                _registrationData.departmentId = value!;
              });
            },
            isDark: isDark,
          ),
          const SizedBox(height: 20),
          
          _buildDropdownField(
            value: _registrationData.enrollmentYear,
            labelText: 'Enrollment Year',
            icon: Icons.event,
            items: List.generate(10, (index) {
              final year = DateTime.now().year - index;
              return DropdownMenuItem(
                value: year,
                child: Text(year.toString()),
              );
            }),
            onChanged: (value) {
              setState(() {
                _registrationData.enrollmentYear = value!;
              });
            },
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildStep4(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          
          // Icon
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.purple[600]!, Colors.purple[700]!],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.check_circle,
              size: 60,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 40),
          
          // Title
          Text(
            'Review & Complete',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.purple[800],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Please review your information before completing',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white70 : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          
          // Review information
          _buildReviewCard(isDark),
        ],
      ),
    );
  }

  Widget _buildReviewCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          _buildReviewItem('Email', _registrationData.email, isDark),
          _buildReviewItem('Real Name', _registrationData.realName, isDark),
          _buildReviewItem('Nickname', _registrationData.nickname, isDark),
          _buildReviewItem('Language', _getLanguageName(_registrationData.mainLanguage), isDark),
          _buildReviewItem('Nationality', _getNationalityName(_registrationData.nationalityIso2), isDark),
          _buildReviewItem('School ID', _registrationData.schoolIdString.isNotEmpty ? _registrationData.schoolIdString : _registrationData.schoolId.toString(), isDark),
          _buildReviewItem('School', _getSchoolName(_registrationData.schoolId), isDark),
          _buildReviewItem('Department', _getDepartmentName(_registrationData.departmentId), isDark),
          _buildReviewItem('Enrollment Year', _registrationData.enrollmentYear.toString(), isDark),
        ],
      ),
    );
  }

  Widget _buildReviewItem(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods to convert codes to friendly names
  String _getLanguageName(String code) {
    switch (code) {
      case 'ko': return '한국어';
      case 'en': return 'English';
      case 'vi': return 'Tiếng Việt';
      case 'ja': return '日本語';
      case 'zh': return '中文';
      case 'my': return 'မြန်မာ';
      default: return code;
    }
  }

  String _getNationalityName(String code) {
    switch (code) {
      case 'KR': return '🇰🇷 Hàn Quốc';
      case 'VN': return '🇻🇳 Việt Nam';
      case 'US': return '🇺🇸 United States';
      case 'JP': return '🇯🇵 Japan';
      case 'CN': return '🇨🇳 China';
      case 'MM': return '🇲🇲 Myanmar';
      default: return code;
    }
  }

  String _getDepartmentName(int id) {
    switch (id) {
      case 1: return 'Computer Science';
      case 2: return 'Business Administration';
      case 3: return 'Engineering';
      case 4: return ' Liberal Arts';
      case 5: return ' Medicine';
      case 6: return ' Law';
      case 7: return ' Fine Arts';
      case 8: return ' Music';
      case 9: return ' Physical Education';
      case 10: return ' Natural Sciences';
      case 11: return ' International Studies';
      case 12: return ' Media & Communication';
      case 13: return ' Architecture';
      case 14: return ' Culinary Arts';
      case 15: return ' Early Childhood Education';
      case 16: return ' Environmental Science';
      case 17: return ' Psychology';
      case 18: return ' Economics';
      case 19: return ' Information Technology';
      case 20: return ' Theater & Film';
      default: return 'epartment $id';
    }
  }

  String _getSchoolName(int id) {
    switch (id) {
      case 1: return ' Keimyung University';
      case 2: return ' Seoul National University';
      case 3: return ' Korea University';
      case 4: return ' Yonsei University';
      case 5: return ' KAIST';
      case 6: return ' Sungkyunkwan University';
      case 7: return ' Hongik University';
      case 8: return ' Hanyang University';
      case 9: return ' Chung-Ang University';
      case 10: return ' Kyung Hee University';
      case 11: return ' Ewha Womans University';
      case 12: return ' Sogang University';
      case 13: return ' Pusan National University';
      case 14: return ' Inha University';
      case 15: return ' Other University';
      default: return 'School $id';
    }
  }

  Widget _buildFormField({
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool obscureText = false,
    required String labelText,
    required IconData prefixIcon,
    required bool isDark,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              prefixIcon,
              color: Colors.red[600],
              size: 20,
            ),
          ),
          filled: true,
          fillColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.red[600]!, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: isDark ? Colors.grey[600]! : Colors.grey[300]!),
          ),
          labelStyle: TextStyle(
            color: isDark ? Colors.white70 : Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required T value,
    required String labelText,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
          ),
        ),
        child: Row(
          children: [
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.blue[600],
                size: 20,
              ),
            ),
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<T>(
                  value: value,
                  items: items,
                  onChanged: onChanged,
                  isExpanded: true,
                  icon: Icon(Icons.arrow_drop_down, color: isDark ? Colors.white70 : Colors.grey[600]),
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 16,
                  ),
                  dropdownColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Colors.red[600]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Previous',
                  style: TextStyle(
                    color: Colors.red[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _currentStep == 3 ? _completeRegistration : _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      _currentStep == 3 ? 'Complete Registration' : 'Next',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
