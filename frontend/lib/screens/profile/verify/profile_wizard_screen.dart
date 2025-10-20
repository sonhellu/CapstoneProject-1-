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
  String _verificationCode = '';
  bool _isEmailVerified = false;
  bool _isCodeSent = false;
  bool _agreeToTerms = false;

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

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _confirmEmailController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('userName') ?? '';
      _usernameController.text = prefs.getString('userUsername') ?? '';
      _selectedUniversity = prefs.getString('userUniversity') ?? '';
      _selectedMajor = prefs.getString('userMajor') ?? '';
      _selectedYear = prefs.getString('userYear') ?? '';
      _selectedNationality = prefs.getString('userNationality') ?? '';
      _emailController.text = prefs.getString('userEmail') ?? '';
    });
  }

  void _nextStep() {
    if (_currentStep == 1) {
      // Check if terms are agreed for step 2
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

  Future<void> _sendVerificationCode() async {
    if (_emailController.text.contains('@stu.')) {
      setState(() {
        _isCodeSent = true;
        _verificationCode = '123456'; // Simulate code generation
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verification code sent to ${_emailController.text}'),
          backgroundColor: Colors.green[600],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid student email (@stu.)'),
          backgroundColor: Colors.red[600],
        ),
      );
    }
  }

  void _verifyCode() {
    if (_verificationCode == '123456') {
      setState(() {
        _isEmailVerified = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Email verified successfully!'),
          backgroundColor: Colors.green[600],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid verification code'),
          backgroundColor: Colors.red[600],
        ),
      );
    }
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', _nameController.text);
    await prefs.setString('userUsername', _usernameController.text);
    await prefs.setString('userUniversity', _selectedUniversity);
    await prefs.setString('userMajor', _selectedMajor);
    await prefs.setString('userYear', _selectedYear);
    await prefs.setString('userNationality', _selectedNationality);
    await prefs.setString('userEmail', _emailController.text);

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
                setState(() {
                  _verificationCode = value;
                });
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
