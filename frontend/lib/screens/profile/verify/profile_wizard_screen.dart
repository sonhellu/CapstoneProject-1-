import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../l10n/app_localizations.dart';

class ProfileWizardScreen extends StatefulWidget {
  const ProfileWizardScreen({super.key});

  @override
  State<ProfileWizardScreen> createState() => _ProfileWizardScreenState();
}

class _ProfileWizardScreenState extends State<ProfileWizardScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Step 1: Basic Info
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  String _selectedUniversity = '';
  String _selectedMajor = '';
  String _selectedYear = '';
  String _selectedNationality = '';

  // Step 2: Email Verification
  final _emailController = TextEditingController();
  final _confirmEmailController = TextEditingController();
  final _verificationCodeController = TextEditingController();
  bool _isEmailVerified = false;
  bool _isCodeSent = false;
  bool _agreeToTerms = false;
  String _generatedCode = '';

  // Step 3: Final Review
  bool _isLoading = false;

  final List<String> _universities = [
    'Seoul National University',
    'Korea University',
    'Yonsei University',
    'Keimyung university',
    'Sungkyunkwan University',
    'Hanyang University',
    'Kyung Hee University',
    'Chung-Ang University',
    'Ewha Womans University',
  ];

  final List<String> _majors = [
    'Computer Science',
    'Computer Engineering',
    'Business Administration',
    'International Studies',
    'Korean Language',
    'Engineering',
    'Medicine',
    'Law',
    'Economics',
    'Psychology',
    'Art & Design',
  ];

  final List<String> _years = [
    '1st Year',
    '2nd Year',
    '3rd Year',
    '4th Year',
    'Graduate Student',
    'PhD Student',
  ];

  final List<String> _nationalities = [
    'Vietnam',
    'Korea',
    'China',
    'Japan',
    'Thailand',
    'Indonesia',
    'Malaysia',
    'Philippines',
    'India',
    'Mongolia',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Load from registration data
      _nameController.text = prefs.getString('realName') ?? '';
      _usernameController.text = prefs.getString('nickname') ?? '';
      _emailController.text = prefs.getString('email') ?? '';
      _confirmEmailController.text = prefs.getString('email') ?? '';
      _selectedUniversity = _getSchoolName(prefs.getInt('schoolId') ?? 1);
      _selectedMajor = _getDepartmentName(prefs.getInt('departmentId') ?? 1);
      _selectedYear = prefs.getInt('enrollmentYear')?.toString() ?? '';
      _selectedNationality = _getNationalityName(prefs.getString('nationalityIso2') ?? 'KR');
    });
  }

  String _getSchoolName(int id) {
    switch (id) {
      case 1: return 'Keimyung University';
      case 2: return 'Seoul National University';
      case 3: return 'Korea University';
      case 4: return 'Yonsei University';
      case 5: return 'KAIST';
      case 6: return 'Sungkyunkwan University';
      case 7: return 'Hongik University';
      case 8: return 'Hanyang University';
      case 9: return 'Chung-Ang University';
      case 10: return 'Kyung Hee University';
      case 11: return 'Ewha Womans University';
      case 12: return 'Sogang University';
      case 13: return 'Pusan National University';
      case 14: return 'Inha University';
      case 15: return 'Other University';
      default: return 'School $id';
    }
  }

  String _getDepartmentName(int id) {
    switch (id) {
      case 1: return 'Computer Science';
      case 2: return 'Business Administration';
      case 3: return 'Engineering';
      case 4: return 'Liberal Arts';
      case 5: return 'Medicine';
      case 6: return 'Law';
      case 7: return 'Fine Arts';
      case 8: return 'Music';
      case 9: return 'Physical Education';
      case 10: return 'Natural Sciences';
      case 11: return 'International Studies';
      case 12: return 'Media & Communication';
      case 13: return 'Architecture';
      case 14: return 'Culinary Arts';
      case 15: return 'Early Childhood Education';
      case 16: return 'Environmental Science';
      case 17: return 'Psychology';
      case 18: return 'Economics';
      case 19: return 'Information Technology';
      case 20: return 'Theater & Film';
      default: return 'Department $id';
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

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _confirmEmailController.dispose();
    _verificationCodeController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  String _generateVerificationCode() {
    final random = DateTime.now().millisecondsSinceEpoch;
    return (random % 900000 + 100000).toString(); // 6-digit code
  }

  void _sendVerificationCode() {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email address'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_emailController.text.contains('@stu')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid student email (@stu)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _generatedCode = _generateVerificationCode();
      _isCodeSent = true;
    });

    // Show the code for testing (in real app, this would be sent via email)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Verification code sent! Code: $_generatedCode'),
        backgroundColor: Colors.green[600],
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void _verifyCode() {
    if (_verificationCodeController.text == _generatedCode) {
      setState(() {
        _isEmailVerified = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email verified successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid verification code'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  void _nextStep() {
    if (_currentStep == 1) {
      // Check if email is verified and terms are agreed for step 2
      if (!_isEmailVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please verify your email address first'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      if (!_agreeToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please agree to the terms and conditions to continue',
            ),
            backgroundColor: Colors.red[600],
          ),
        );
        return;
      }
    }

    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _saveProfile();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }



  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    
    // Save to registration keys for consistency
    await prefs.setString('realName', _nameController.text);
    await prefs.setString('nickname', _usernameController.text);
    await prefs.setString('email', _emailController.text);
    
    // Convert university name back to ID
    int schoolId = _getSchoolIdFromName(_selectedUniversity);
    await prefs.setInt('schoolId', schoolId);
    
    // Convert major name back to ID
    int departmentId = _getDepartmentIdFromName(_selectedMajor);
    await prefs.setInt('departmentId', departmentId);
    
    // Convert year string to int
    int enrollmentYear = int.tryParse(_selectedYear) ?? DateTime.now().year;
    await prefs.setInt('enrollmentYear', enrollmentYear);
    
    // Convert nationality name back to ISO2 code
    String nationalityIso2 = _getNationalityIso2FromName(_selectedNationality);
    await prefs.setString('nationalityIso2', nationalityIso2);

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green[600],
        ),
      );

      Navigator.pop(context);
    }
  }

  int _getSchoolIdFromName(String name) {
    switch (name) {
      case 'Keimyung University': return 1;
      case 'Seoul National University': return 2;
      case 'Korea University': return 3;
      case 'Yonsei University': return 4;
      case 'KAIST': return 5;
      case 'Sungkyunkwan University': return 6;
      case 'Hongik University': return 7;
      case 'Hanyang University': return 8;
      case 'Chung-Ang University': return 9;
      case 'Kyung Hee University': return 10;
      case 'Ewha Womans University': return 11;
      case 'Sogang University': return 12;
      case 'Pusan National University': return 13;
      case 'Inha University': return 14;
      case 'Other University': return 15;
      default: return 1;
    }
  }

  int _getDepartmentIdFromName(String name) {
    switch (name) {
      case 'Computer Science': return 1;
      case 'Business Administration': return 2;
      case 'Engineering': return 3;
      case 'Liberal Arts': return 4;
      case 'Medicine': return 5;
      case 'Law': return 6;
      case 'Fine Arts': return 7;
      case 'Music': return 8;
      case 'Physical Education': return 9;
      case 'Natural Sciences': return 10;
      case 'International Studies': return 11;
      case 'Media & Communication': return 12;
      case 'Architecture': return 13;
      case 'Culinary Arts': return 14;
      case 'Early Childhood Education': return 15;
      case 'Environmental Science': return 16;
      case 'Psychology': return 17;
      case 'Economics': return 18;
      case 'Information Technology': return 19;
      case 'Theater & Film': return 20;
      default: return 1;
    }
  }

  String _getNationalityIso2FromName(String name) {
    if (name.contains('🇰🇷')) return 'KR';
    if (name.contains('🇻🇳')) return 'VN';
    if (name.contains('🇺🇸')) return 'US';
    if (name.contains('🇯🇵')) return 'JP';
    if (name.contains('🇨🇳')) return 'CN';
    if (name.contains('🇲🇲')) return 'MM';
    return 'KR';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.red[50],
      appBar: AppBar(
        backgroundColor: Colors.red[600],
        title: Text(
          'Edit Profile - Step ${_currentStep + 1}/3',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: List.generate(3, (index) {
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: index < 2 ? 10 : 0),
                    height: 4,
                    decoration: BoxDecoration(
                      color: index <= _currentStep
                          ? Colors.red[600]
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),

          // Page content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              children: [_buildStep1(), _buildStep2(), _buildStep3()],
            ),
          ),

          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _previousStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Previous'),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(_currentStep == 2 ? 'Save Profile' : 'Next'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Basic Information',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.red[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please provide your basic information',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white70 : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),

          // Name field
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).fullName,
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red[600]!, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Username field
          TextFormField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).username,
              prefixIcon: const Icon(Icons.alternate_email),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red[600]!, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // University dropdown
          DropdownButtonFormField<String>(
            initialValue: _selectedUniversity.isEmpty
                ? null
                : _selectedUniversity,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).university,
              prefixIcon: const Icon(Icons.school),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red[600]!, width: 2),
              ),
            ),
            items: _universities.map((String university) {
              return DropdownMenuItem<String>(
                value: university,
                child: Text(university),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedUniversity = newValue ?? '';
              });
            },
          ),
          const SizedBox(height: 16),

          // Major dropdown
          DropdownButtonFormField<String>(
            initialValue: _selectedMajor.isEmpty ? null : _selectedMajor,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).major,
              prefixIcon: const Icon(Icons.book),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red[600]!, width: 2),
              ),
            ),
            items: _majors.map((String major) {
              return DropdownMenuItem<String>(value: major, child: Text(major));
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedMajor = newValue ?? '';
              });
            },
          ),
          const SizedBox(height: 16),

          // Year dropdown
          DropdownButtonFormField<String>(
            initialValue: _selectedYear.isEmpty ? null : _selectedYear,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).year,
              prefixIcon: const Icon(Icons.calendar_today),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red[600]!, width: 2),
              ),
            ),
            items: _years.map((String year) {
              return DropdownMenuItem<String>(value: year, child: Text(year));
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedYear = newValue ?? '';
              });
            },
          ),
          const SizedBox(height: 16),

          // Nationality dropdown
          DropdownButtonFormField<String>(
            initialValue: _selectedNationality.isEmpty
                ? null
                : _selectedNationality,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).nationality,
              prefixIcon: const Icon(Icons.flag),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red[600]!, width: 2),
              ),
            ),
            items: _nationalities.map((String nationality) {
              return DropdownMenuItem<String>(
                value: nationality,
                child: Text(nationality),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedNationality = newValue ?? '';
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Email Verification',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.red[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Verify your student email address',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          // Email field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Student Email (@stu.)',
              prefixIcon: const Icon(Icons.email),
              hintText: 'example@stu.university.ac.kr',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red[600]!, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Send code button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isCodeSent ? null : _sendVerificationCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(_isCodeSent ? 'Code Sent' : 'Send Verification Code'),
            ),
          ),
          const SizedBox(height: 24),

          if (_isCodeSent) ...[
            Text(
              'Enter 6-digit verification code',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.red[800],
              ),
            ),
            const SizedBox(height: 16),

            // Verification code field
            TextFormField(
              controller: _verificationCodeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                labelText: 'Verification Code',
                prefixIcon: const Icon(Icons.security),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.red[600]!, width: 2),
                ),
              ),
              onChanged: (value) {
                // Verification code changed
              },
            ),
            const SizedBox(height: 16),

            // Verify button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isEmailVerified ? null : _verifyCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isEmailVerified
                      ? Colors.green[600]
                      : Colors.red[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isEmailVerified) ...[
                      const Icon(Icons.check),
                      const SizedBox(width: 8),
                    ],
                    Text(_isEmailVerified ? 'Email Verified' : 'Verify Code'),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Terms and Conditions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Terms and Conditions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'By continuing, you agree to our Terms of Service and Privacy Policy. You consent to receive important notifications about your account and campus activities via email.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Checkbox(
                      value: _agreeToTerms,
                      onChanged: (bool? value) {
                        setState(() {
                          _agreeToTerms = value ?? false;
                        });
                      },
                      activeColor: Colors.red[600],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _agreeToTerms = !_agreeToTerms;
                          });
                        },
                        child: Text(
                          'I agree to the Terms and Conditions',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review & Save',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.red[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please review your information before saving',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          // Review cards
          _buildReviewCard(AppLocalizations.of(context).fullName, _nameController.text),
          const SizedBox(height: 16),
          _buildReviewCard(AppLocalizations.of(context).username, _usernameController.text),
          const SizedBox(height: 16),
          _buildReviewCard(AppLocalizations.of(context).university, _selectedUniversity),
          const SizedBox(height: 16),
          _buildReviewCard(AppLocalizations.of(context).major, _selectedMajor),
          const SizedBox(height: 16),
          _buildReviewCard(AppLocalizations.of(context).year, _selectedYear),
          const SizedBox(height: 16),
          _buildReviewCard(AppLocalizations.of(context).nationality, _selectedNationality),
          const SizedBox(height: 16),
          _buildReviewCard(AppLocalizations.of(context).email, _emailController.text),
          const SizedBox(height: 16),
          _buildReviewCard(
            'Email Status',
            _isEmailVerified ? 'Verified ✓' : 'Not Verified',
          ),
          const SizedBox(height: 16),
          _buildReviewCard(
            'Terms & Conditions',
            _agreeToTerms ? 'Agreed ✓' : 'Not Agreed',
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(String label, String value) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.red[800],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value.isEmpty ? 'Not provided' : value,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
