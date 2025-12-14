import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/registration_data.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../services/options_service.dart';
import '../../l10n/app_localizations.dart';

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
  bool _isLoadingOptions = false;
  final _formKey = GlobalKey<FormState>();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Options data from API
  List<Map<String, dynamic>> _schools = [];
  List<Map<String, dynamic>> _departments = [];
  List<Map<String, dynamic>> _languages = [];
  List<Map<String, dynamic>> _countries = [];

  // Form controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _realNameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _studentIdController = TextEditingController();

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
    _loadOptionsData();
  }
  
  /// Load all options data from API
  Future<void> _loadOptionsData() async {
    setState(() {
      _isLoadingOptions = true;
    });
    
    try {
      // Load all options in parallel
      final results = await Future.wait([
        OptionsService.getSchools(),
        OptionsService.getLanguages(),
        OptionsService.getCountries(),
      ]);
      
      // Set default values BEFORE setting state to avoid value mismatch
      int? firstSchoolId;
      String? firstLanguage;
      String? firstCountry;
      
      if ((results[0] as List).isNotEmpty) {
        firstSchoolId = (results[0] as List).first['id'] as int;
      }
      if ((results[1] as List).isNotEmpty) {
        firstLanguage = (results[1] as List).first['code'] as String;
      }
      if ((results[2] as List).isNotEmpty) {
        firstCountry = (results[2] as List).first['iso2'] as String;
      }
      
      setState(() {
        _schools = (results[0] as List).cast<Map<String, dynamic>>();
        _languages = (results[1] as List).cast<Map<String, dynamic>>();
        _countries = (results[2] as List).cast<Map<String, dynamic>>();
        _isLoadingOptions = false;
        
        // Set default values only if data is available
        if (firstSchoolId != null) {
          _registrationData.schoolId = firstSchoolId;
        }
        if (firstLanguage != null) {
          _registrationData.mainLanguage = firstLanguage;
        }
        if (firstCountry != null) {
          _registrationData.nationalityIso2 = firstCountry;
        }
      });
      
      // Load departments after setting school
      if (firstSchoolId != null) {
        _loadDepartments(firstSchoolId);
      }
    } catch (e) {
      setState(() {
        _isLoadingOptions = false;
        // Set empty lists to prevent errors
        _schools = [];
        _languages = [];
        _countries = [];
      });
      // Show error but don't block registration
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).couldNotLoadOptions),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
  
  /// Load departments for selected school
  Future<void> _loadDepartments(int schoolId) async {
    try {
      final departments = await OptionsService.getDepartments(schoolId);
      setState(() {
        _departments = departments;
        // Set default department if available, otherwise reset to 0
        if (_departments.isNotEmpty) {
          _registrationData.departmentId = _departments.first['id'] as int;
        } else {
          _registrationData.departmentId = 0; // Reset if no departments
        }
      });
    } catch (e) {
      // Error loading departments - reset list
      setState(() {
        _departments = [];
        _registrationData.departmentId = 0;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).couldNotLoadDepartments),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
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
    _studentIdController.dispose();
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
        // Validate that school and department are selected
        if (_registrationData.schoolId <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).pleaseSelectUniversity),
              backgroundColor: Colors.red,
            ),
          );
          return false;
        }
        if (_registrationData.departmentId <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).pleaseSelectDepartment),
              backgroundColor: Colors.red,
            ),
          );
          return false;
        }
        return true;
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
        // Gender đã được lưu trực tiếp khi chọn
        break;
      case 1: // Step 2: Profile Info
        _registrationData.nickname = _nicknameController.text;
        break;
      case 2: // Step 3: School Info
        _registrationData.studentId = _studentIdController.text.trim();
        // University và Department ID đã được lưu trực tiếp khi chọn từ dropdown
        break;
    }
  }

  Future<void> _completeRegistration() async {
    if (!_registrationData.isAllStepsValid()) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseFillAllRequiredFields),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Call real registration API
      final apiData = _registrationData.toApiFormat();
      final response = await AuthService.register(
        email: apiData['email'] as String,
        password: apiData['password'] as String,
        nickname: apiData['nickname'] as String,
        realname: apiData['realname'] as String,
        studentId: apiData['student_id'] as String?,
        gender: apiData['gender'] as String,
        mainLanguage: apiData['main_language'] as String,
        nationalityIso2: apiData['nationality_iso2'] as String,
        schoolId: apiData['school_id'] as int,
        departmentId: apiData['department_id'] as int,
        enrollmentYear: apiData['enrollment_year'] as int,
      );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      // Save language preference to SharedPreferences
      await _saveLanguagePreference(_registrationData.mainLanguage);

      // Show success message in selected language
      String successMessage = _getSuccessMessage(_registrationData.mainLanguage);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(response['message'] ?? successMessage),
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
    } on ApiException catch (e) {
      // Handle API errors
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red[600],
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Handle unexpected errors
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.errorOccurred}: ${e.toString()}'),
            backgroundColor: Colors.red[600],
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _saveLanguagePreference(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', languageCode);
  }

  // This method is no longer needed because registration doesn't auto-login
  // User needs to login after successful registration

  String _getSuccessMessage(String languageCode) {
    switch (languageCode) {
      case 'ko':
        return '회원가입이 성공적으로 완료되었습니다! 로그인해주세요.';
      case 'vi':
        return 'Registration successful! Please login.';
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
      return AppLocalizations.of(context).validStudentEmail;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context).passwordRequired;
    }
    if (value.length < 6) {
      return AppLocalizations.of(context).passwordTooShort;
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context).pleaseConfirmPassword;
    }
    if (value != _passwordController.text) {
      return AppLocalizations.of(context).passwordMismatch;
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
      padding: const EdgeInsets.all(16),
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
    final l10n = AppLocalizations.of(context);
    switch (step) {
      case 0: return l10n.personalInformation;
      case 1: return l10n.profileSetup;
      case 2: return l10n.schoolInformation;
      case 3: return l10n.reviewAndSave;
      default: return '';
    }
  }

  Widget _buildStep1(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          
          // Icon
          Container(
            padding: const EdgeInsets.all(16),
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
            AppLocalizations.of(context).personalInformation,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.red[800],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context).tellUsAboutAcademicBackground,
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
                  labelText: AppLocalizations.of(context).studentEmail,
                  prefixIcon: Icons.email_outlined,
                  isDark: isDark,
                  validator: _validateEmail,
                ),
                const SizedBox(height: 20),
                
                _buildFormField(
                  controller: _passwordController,
                  obscureText: true,
                  labelText: AppLocalizations.of(context).password,
                  prefixIcon: Icons.lock_outline,
                  isDark: isDark,
                  validator: _validatePassword,
                ),
                const SizedBox(height: 20),
                
                _buildFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  labelText: AppLocalizations.of(context).confirmPassword,
                  prefixIcon: Icons.lock_reset,
                  isDark: isDark,
                  validator: _validateConfirmPassword,
                ),
                const SizedBox(height: 20),
                
                _buildFormField(
                  controller: _realNameController,
                  labelText: AppLocalizations.of(context).fullName,
                  prefixIcon: Icons.badge_outlined,
                  isDark: isDark,
                  validator: _validateRequired,
                ),
                const SizedBox(height: 20),
                
                // Gender Selection
                _buildGenderSelector(isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          
          // Icon
          Container(
            padding: const EdgeInsets.all(16),
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
              labelText: AppLocalizations.of(context).nickname,
              prefixIcon: Icons.alternate_email,
              isDark: isDark,
              validator: _validateRequired,
            ),
          ),
          const SizedBox(height: 20),
          
          _isLoadingOptions
              ? const Center(child: CircularProgressIndicator())
              : _buildDropdownField<String>(
                  value: _languages.isEmpty 
                      ? 'ko' 
                      : (_languages.any((l) => l['code'] == _registrationData.mainLanguage)
                          ? _registrationData.mainLanguage
                          : (_languages.isNotEmpty ? _languages.first['code'] as String : 'ko')),
            labelText: AppLocalizations.of(context).targetLanguage,
            icon: Icons.translate,
                  items: _languages.isEmpty
                      ? [DropdownMenuItem(value: 'ko', child: Text(AppLocalizations.of(context).loading))]
                      : _languages.map((lang) {
                          return DropdownMenuItem(
                            value: lang['code'] as String,
                            child: Text(lang['native_name'] as String? ?? lang['name'] as String),
                          );
                        }).toList(),
                  onChanged: _languages.isEmpty ? null : (value) {
                    if (value != null) {
              setState(() {
                        _registrationData.mainLanguage = value;
              });
                    }
            },
            isDark: isDark,
          ),
          const SizedBox(height: 20),
          
          _isLoadingOptions
              ? const Center(child: CircularProgressIndicator())
              : _buildDropdownField<String>(
                  value: _countries.isEmpty 
                      ? 'KR' 
                      : (_countries.any((c) => c['iso2'] == _registrationData.nationalityIso2)
                          ? _registrationData.nationalityIso2
                          : (_countries.isNotEmpty ? _countries.first['iso2'] as String : 'KR')),
                  labelText: AppLocalizations.of(context).nationality,
            icon: Icons.public,
                  items: _countries.isEmpty
                      ? [DropdownMenuItem(value: 'KR', child: Text(AppLocalizations.of(context).loading))]
                      : _countries.map((country) {
                          final iso2 = country['iso2'] as String;
                          final name = country['name'] as String;
                          String displayName = name;
                          // Add emoji based on country code
                          switch (iso2) {
                            case 'KR': displayName = '🇰🇷 $name'; break;
                            case 'VN': displayName = '🇻🇳 $name'; break;
                            case 'US': displayName = '🇺🇸 $name'; break;
                            case 'JP': displayName = '🇯🇵 $name'; break;
                            case 'CN': displayName = '🇨🇳 $name'; break;
                            case 'MM': displayName = '🇲🇲 $name'; break;
                            case 'TH': displayName = '🇹🇭 $name'; break;
                            case 'ID': displayName = '🇮🇩 $name'; break;
                            case 'PH': displayName = '🇵🇭 $name'; break;
                            case 'SG': displayName = '🇸🇬 $name'; break;
                          }
                          return DropdownMenuItem(
                            value: iso2,
                            child: Text(displayName),
                          );
                        }).toList(),
                  onChanged: _countries.isEmpty ? null : (value) {
                    if (value != null) {
              setState(() {
                        _registrationData.nationalityIso2 = value;
              });
                    }
            },
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildStep3(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          
          // Icon
          Container(
            padding: const EdgeInsets.all(16),
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
            AppLocalizations.of(context).schoolInformation,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.green[800],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context).tellUsAboutAcademicBackground,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white70 : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          
          // Form fields
          // Student ID input (optional, user can input freely)
          _buildFormField(
            controller: _studentIdController,
            keyboardType: TextInputType.text,
            labelText: AppLocalizations.of(context).studentId,
            prefixIcon: Icons.badge,
            isDark: isDark,
          ),
          const SizedBox(height: 20),
          
          _isLoadingOptions
              ? const Center(child: CircularProgressIndicator())
              : _buildDropdownField<int>(
                  value: _schools.isEmpty 
                      ? 0 
                      : (_schools.any((s) => s['id'] == _registrationData.schoolId)
                          ? _registrationData.schoolId
                          : (_schools.isNotEmpty ? _schools.first['id'] as int : 0)),
                  labelText: AppLocalizations.of(context).university,
            icon: Icons.school_outlined,
                  items: _schools.isEmpty
                      ? [DropdownMenuItem(value: 0, child: Text(AppLocalizations.of(context).loading))]
                      : _schools.map((school) {
                          return DropdownMenuItem(
                            value: school['id'] as int,
                            child: Text(' ${school['name'] as String}'),
                          );
                        }).toList(),
                  onChanged: _schools.isEmpty ? null : (value) {
                    if (value != null && value != 0) {
              setState(() {
                        _registrationData.schoolId = value;
                        // Load departments for selected school
                        _loadDepartments(value);
              });
                    }
            },
            isDark: isDark,
          ),
          const SizedBox(height: 20),
          
          _buildDropdownField<int>(
            value: _departments.isEmpty 
                ? 0 
                : (_departments.any((d) => d['id'] == _registrationData.departmentId)
                    ? _registrationData.departmentId
                    : (_departments.isNotEmpty ? _departments.first['id'] as int : 0)),
            labelText: AppLocalizations.of(context).department,
            icon: Icons.business_center,
            items: _departments.isEmpty
                ? [DropdownMenuItem(value: 0, child: Text(AppLocalizations.of(context).selectSchoolFirst))]
                : _departments.map((dept) {
                    return DropdownMenuItem(
                      value: dept['id'] as int,
                      child: Text(' ${dept['name'] as String}'),
                    );
                  }).toList(),
            onChanged: _departments.isEmpty ? null : (value) {
              if (value != null && value != 0) {
              setState(() {
                  _registrationData.departmentId = value;
              });
              }
            },
            isDark: isDark,
          ),
          const SizedBox(height: 20),
          
          _buildDropdownField(
            value: _registrationData.enrollmentYear,
            labelText: AppLocalizations.of(context).enrollmentYear,
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
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          
          // Icon
          Container(
            padding: const EdgeInsets.all(16),
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
            AppLocalizations.of(context).reviewAndComplete,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.purple[800],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context).pleaseReviewBeforeCompleting,
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
      padding: const EdgeInsets.all(16),
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
            AppLocalizations.of(context).personalInformation,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          _buildReviewItem(AppLocalizations.of(context).email, _registrationData.email, isDark),
          _buildReviewItem(AppLocalizations.of(context).realName, _registrationData.realName, isDark),
          _buildReviewItem(AppLocalizations.of(context).gender, _registrationData.gender == 'male' ? AppLocalizations.of(context).male : AppLocalizations.of(context).female, isDark),
          _buildReviewItem(AppLocalizations.of(context).nickname, _registrationData.nickname, isDark),
          if (_registrationData.studentId.isNotEmpty)
            _buildReviewItem(AppLocalizations.of(context).studentId, _registrationData.studentId, isDark),
          _buildReviewItem(AppLocalizations.of(context).language, _getLanguageName(_registrationData.mainLanguage), isDark),
          _buildReviewItem(AppLocalizations.of(context).nationality, _getNationalityName(_registrationData.nationalityIso2), isDark),
          _buildReviewItem(AppLocalizations.of(context).university, _getSchoolName(_registrationData.schoolId), isDark),
          _buildReviewItem(AppLocalizations.of(context).department, _getDepartmentName(_registrationData.departmentId), isDark),
          _buildReviewItem(AppLocalizations.of(context).enrollmentYear, _registrationData.enrollmentYear.toString(), isDark),
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
    try {
      final lang = _languages.firstWhere((l) => l['code'] == code);
      return lang['native_name'] as String? ?? lang['name'] as String;
    } catch (e) {
      return code;
    }
  }

  String _getNationalityName(String code) {
    try {
      final country = _countries.firstWhere((c) => c['iso2'] == code);
      return country['name'] as String;
    } catch (e) {
      return code;
    }
  }

  String _getDepartmentName(int id) {
    try {
      final dept = _departments.firstWhere((d) => d['id'] == id);
      return dept['name'] as String;
    } catch (e) {
      return 'Department $id';
    }
  }

  String _getSchoolName(int id) {
    try {
      final school = _schools.firstWhere((s) => s['id'] == id);
      return school['name'] as String;
    } catch (e) {
      return 'School $id';
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
            margin: const EdgeInsets.all(6),
            padding: const EdgeInsets.all(6),
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
    ValueChanged<T?>? onChanged,
    required bool isDark,
  }) {
    // Validate that value exists in items to prevent assertion error
    final validValue = items.any((item) => item.value == value) ? value : null;
    
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
        padding: const EdgeInsets.symmetric(horizontal: 10),
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
              padding: const EdgeInsets.all(6),
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
                  value: validValue,
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
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: Colors.red[600]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context).previous,
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
                padding: const EdgeInsets.symmetric(vertical: 12),
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
                      _currentStep == 3 
                          ? AppLocalizations.of(context).completeRegistration 
                          : AppLocalizations.of(context).next,
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
  
  /// Build Gender Selector
  Widget _buildGenderSelector(bool isDark) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.wc,
                    color: Colors.red[600],
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context).gender,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          
          // Gender options
          Row(
            children: [
              Expanded(
                child: _buildGenderOption(
                  value: 'male',
                  label: 'Male',
                  icon: Icons.male,
                  isSelected: _registrationData.gender == 'male',
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGenderOption(
                  value: 'female',
                  label: 'Female',
                  icon: Icons.female,
                  isSelected: _registrationData.gender == 'female',
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  /// Build Gender Option Button
  Widget _buildGenderOption({
    required String value,
    required String label,
    required IconData icon,
    required bool isSelected,
    required bool isDark,
  }) {
    return InkWell(
      onTap: () {
        setState(() {
          _registrationData.gender = value;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.red[600]
              : (isDark ? const Color(0xFF2C2C2C) : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Colors.red[600]!
                : (isDark ? Colors.grey[600]! : Colors.grey[300]!),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.white70 : Colors.grey[700]),
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.grey[700]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
