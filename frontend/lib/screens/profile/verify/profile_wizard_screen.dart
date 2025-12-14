import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/profile_service.dart';
import '../../../services/options_service.dart';
import '../../../services/api_service.dart';
import '../../../services/api_config.dart';
import '../../../providers/news_provider.dart';

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
  String _selectedMainLanguage = '';

  // Step 2: Final Review
  bool _isLoading = false;

  final List<String> _universities = [
    'Keimyung University',
    'Seoul National University',
    'Korea University',
    'Yonsei University',
    'KAIST',
    'Sungkyunkwan University',
    'Hongik University',
    'Hanyang University',
    'Chung-Ang University',
    'Kyung Hee University',
    'Ewha Womans University',
    'Sogang University',
    'Pusan National University',
    'Inha University',
    'Other University',
  ];

  final List<String> _majors = [
    'Computer Science',
    'Business Administration',
    'Engineering',
    'Liberal Arts',
    'Medicine',
    'Law',
    'Fine Arts',
    'Music',
    'Physical Education',
    'Natural Sciences',
    'International Studies',
    'Media & Communication',
    'Architecture',
    'Culinary Arts',
    'Early Childhood Education',
    'Environmental Science',
    'Psychology',
    'Economics',
    'Information Technology',
    'Theater & Film',
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
    '🇰🇷 Hàn Quốc',
    '🇻🇳 Việt Nam',
    '🇺🇸 United States',
    '🇯🇵 Japan',
    '🇨🇳 China',
    '🇲🇲 Myanmar',
  ];

  final List<Map<String, String>> _languages = const [
    {'code': 'ko', 'label': '🇰🇷 한국어 (Korean)'},
    {'code': 'en', 'label': '🇺🇸 English'},
    {'code': 'vi', 'label': '🇻🇳 Tiếng Việt (Vietnamese)'},
    {'code': 'zh', 'label': '🇨🇳 中文 (Chinese)'},
    {'code': 'ja', 'label': '🇯🇵 日本語 (Japanese)'},
    {'code': 'my', 'label': '🇲🇲 မြန်မာ (Myanmar)'},
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      // Try to load from API first
      final profileData = await ProfileService.getMyProfile();
      setState(() {
        _nameController.text = profileData['realname']?.toString() ?? '';
        _usernameController.text = profileData['nickname']?.toString() ?? '';
        _selectedUniversity = _getSchoolNameFromProfile(profileData);
        _selectedMajor = _getDepartmentNameFromProfile(profileData);
        _selectedYear = _getYearStringFromEnrollmentYear(
          profileData['enrollment_year'] is int 
            ? profileData['enrollment_year'] 
            : int.tryParse(profileData['enrollment_year']?.toString() ?? '')
        );
        _selectedNationality = _getNationalityName(profileData['nationality_iso2']?.toString() ?? 'KR');
        _selectedMainLanguage = profileData['main_language']?.toString() ?? 'en';
      });
    } catch (e) {
      // Fallback to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _nameController.text = prefs.getString('realName') ?? '';
        _usernameController.text = prefs.getString('nickname') ?? '';
        _selectedUniversity = _getSchoolName(prefs.getInt('schoolId') ?? 1);
        _selectedMajor = _getDepartmentName(prefs.getInt('departmentId') ?? 1);
        _selectedYear = _getYearStringFromEnrollmentYear(prefs.getInt('enrollmentYear'));
        _selectedNationality = _getNationalityName(prefs.getString('nationalityIso2') ?? 'KR');
        _selectedMainLanguage = prefs.getString('mainLanguage') ?? 'en';
      });
    }
  }

  String _getSchoolNameFromProfile(Map<String, dynamic> profileData) {
    if (profileData['school'] != null && profileData['school'] is Map<String, dynamic>) {
      return profileData['school']['school_name']?.toString() ?? '';
    } else if (profileData['school_id'] != null) {
      final schoolId = profileData['school_id'];
      final sid = schoolId is int ? schoolId : int.tryParse(schoolId.toString()) ?? 1;
      return _getSchoolName(sid);
    }
    return '';
  }

  String _getDepartmentNameFromProfile(Map<String, dynamic> profileData) {
    if (profileData['department'] != null && profileData['department'] is Map<String, dynamic>) {
      return profileData['department']['department_name']?.toString() ?? '';
    } else if (profileData['department_id'] != null) {
      final deptId = profileData['department_id'];
      final did = deptId is int ? deptId : int.tryParse(deptId.toString()) ?? 1;
      return _getDepartmentName(did);
    }
    return '';
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

  String _getYearStringFromEnrollmentYear(int? enrollmentYear) {
    if (enrollmentYear == null) return '';
    
    int currentYear = DateTime.now().year;
    int yearDiff = currentYear - enrollmentYear;
    
    if (yearDiff < 0) {
      return '1st Year'; // Future enrollment
    } else if (yearDiff == 0) {
      return '1st Year';
    } else if (yearDiff == 1) {
      return '2nd Year';
    } else if (yearDiff == 2) {
      return '3rd Year';
    } else if (yearDiff == 3) {
      return '4th Year';
    } else if (yearDiff >= 4 && yearDiff <= 6) {
      return 'Graduate Student';
    } else {
      return 'PhD Student';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 1) {
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

    try {
      // Validate required fields
      final nickname = _usernameController.text.trim();
      final realname = _nameController.text.trim();
      
      if (nickname.isEmpty) {
        throw ApiException('Nickname cannot be empty');
      }
      if (realname.isEmpty) {
        throw ApiException('Real name cannot be empty');
      }
      
      // Convert university name back to ID
      int schoolId = _getSchoolIdFromName(_selectedUniversity);
      if (schoolId <= 0) {
        throw ApiException(AppLocalizations.of(context).pleaseSelectUniversity);
      }
      
      // Convert major name back to ID
      int departmentId = _getDepartmentIdFromName(_selectedMajor);
      if (departmentId <= 0) {
        throw ApiException(AppLocalizations.of(context).majorRequired);
      }
      
      // Convert year string to int
      int enrollmentYear = _getEnrollmentYearFromString(_selectedYear);
      
      // Convert nationality name back to ISO2 code
      String nationalityIso2 = _getNationalityIso2FromName(_selectedNationality);
      if (nationalityIso2.isEmpty) {
        throw ApiException(AppLocalizations.of(context).nationalityRequired);
      }

      // Convert main language code
      String mainLanguageCode = _selectedMainLanguage.isNotEmpty 
          ? _selectedMainLanguage 
          : 'en';

      // Call API to update profile and get updated data
      final updatedProfile = await ProfileService.updateMyProfile(
        nickname: nickname,
        realname: realname,
        schoolId: schoolId,
        departmentId: departmentId,
        enrollmentYear: enrollmentYear,
        nationalityIso2: nationalityIso2,
        mainLanguage: mainLanguageCode,
      );

      // Update local SharedPreferences with data from API response
      final prefs = await SharedPreferences.getInstance();
      if (updatedProfile['realname'] != null) {
        await prefs.setString('realName', updatedProfile['realname'].toString());
      }
      if (updatedProfile['nickname'] != null) {
        await prefs.setString('nickname', updatedProfile['nickname'].toString());
      }
      if (updatedProfile['school_id'] != null) {
        final sid = updatedProfile['school_id'];
        await prefs.setInt('schoolId', sid is int ? sid : int.tryParse(sid.toString()) ?? schoolId);
      }
      if (updatedProfile['department_id'] != null) {
        final did = updatedProfile['department_id'];
        await prefs.setInt('departmentId', did is int ? did : int.tryParse(did.toString()) ?? departmentId);
      }
      if (updatedProfile['enrollment_year'] != null) {
        final year = updatedProfile['enrollment_year'];
        await prefs.setInt('enrollmentYear', year is int ? year : int.tryParse(year.toString()) ?? enrollmentYear);
      }
      if (updatedProfile['nationality_iso2'] != null) {
        await prefs.setString('nationalityIso2', updatedProfile['nationality_iso2'].toString());
      }
      if (updatedProfile['main_language'] != null) {
        final mainLang = updatedProfile['main_language'].toString();
        await prefs.setString('mainLanguage', mainLang);
        // Sync main_language với language (ngôn ngữ hiển thị của app)
        await prefs.setString('language', mainLang);
        
        // Clear cache cho school translation để link trường được dịch theo ngôn ngữ mới
        ApiService.clearCacheEntry(ApiConfig.schoolTranslationEndpoint);
        
        // Reload NewsProvider để cập nhật Domestic tab theo main_language mới
        if (mounted) {
          try {
            final newsProvider = context.read<NewsProvider>();
            await newsProvider.setUserMainLanguage(mainLang);
          } catch (e) {
            // Ignore if NewsProvider is not available
          }
        }
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.profileUpdated),
            backgroundColor: Colors.green[600],
            duration: const Duration(seconds: 2),
          ),
        );

        // Return true with updated profile data to indicate successful update
        // Include main_language để trigger reload app language
        Navigator.pop(context, {
          'success': true, 
          'profile': updatedProfile,
          'main_language': updatedProfile['main_language'],
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context).error}: ${e.message}'),
            backgroundColor: Colors.red[600],
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context).failedToUpdateProfile}: ${e.toString()}'),
            backgroundColor: Colors.red[600],
            duration: const Duration(seconds: 3),
          ),
        );
      }
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

  int _getEnrollmentYearFromString(String yearString) {
    int currentYear = DateTime.now().year;
    
    if (yearString.contains('1st Year')) {
      return currentYear;
    } else if (yearString.contains('2nd Year')) {
      return currentYear - 1;
    } else if (yearString.contains('3rd Year')) {
      return currentYear - 2;
    } else if (yearString.contains('4th Year')) {
      return currentYear - 3;
    } else if (yearString.contains('Graduate Student')) {
      return currentYear - 4;
    } else if (yearString.contains('PhD Student')) {
      return currentYear - 6;
    } else {
      return currentYear; // Default to current year
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
          AppLocalizations.of(context).editProfileStep(_currentStep + 1),
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
            padding: const EdgeInsets.all(12),
            child: Row(
              children: List.generate(2, (index) {
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: index < 1 ? 10 : 0),
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
              children: [_buildStep1(), _buildStep2()],
            ),
          ),

          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _previousStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(AppLocalizations.of(context).previous),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
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
                        : Text(_currentStep == 1 
                            ? AppLocalizations.of(context).saveProfile 
                            : AppLocalizations.of(context).next),
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
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).basicInformation,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.red[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context).pleaseProvideBasicInformation,
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
            value: _selectedUniversity.isEmpty || !_universities.contains(_selectedUniversity)
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
            value: _selectedMajor.isEmpty || !_majors.contains(_selectedMajor)
                ? null
                : _selectedMajor,
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
            value: _selectedYear.isEmpty || !_years.contains(_selectedYear)
                ? null
                : _selectedYear,
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
            value: _selectedNationality.isEmpty || !_nationalities.contains(_selectedNationality)
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
          const SizedBox(height: 16),

          // Main Language dropdown
          DropdownButtonFormField<String>(
            value: _selectedMainLanguage.isNotEmpty && _languages.any((lang) => lang['code'] == _selectedMainLanguage)
                ? _selectedMainLanguage
                : null,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).mainLanguage,
              prefixIcon: const Icon(Icons.language),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red[600]!, width: 2),
              ),
            ),
            items: _languages.map((Map<String, String> lang) {
              return DropdownMenuItem<String>(
                value: lang['code'],
                child: Text(lang['label']!),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedMainLanguage = newValue ?? 'en';
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).reviewAndSave,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.red[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context).pleaseReviewBeforeSaving,
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
          _buildReviewCard(
            AppLocalizations.of(context).mainLanguage,
            _languages.firstWhere(
              (lang) => lang['code'] == _selectedMainLanguage,
              orElse: () => {'code': 'en', 'label': '🇺🇸 English'},
            )['label']!,
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(String label, String value) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
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
