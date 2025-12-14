import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../l10n/app_localizations.dart';
import 'verify/profile_wizard_screen.dart';
import '../../services/profile_service.dart';

class ProfileScreen extends StatefulWidget {
  final Function(String)? onLanguageChanged;
  
  const ProfileScreen({super.key, this.onLanguageChanged});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with WidgetsBindingObserver {
  final _nameController = TextEditingController();
  
  String _selectedUniversity = '';
  String _selectedMajor = '';
  String _selectedYear = '';
  String _selectedNationality = '';
  String _selectedMainLanguage = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUserData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _nameController.dispose();
    super.dispose();
  }



  // Public method to reload data (can be called from outside)
  void reloadData() {
    _loadUserData();
  }

  // Map profile data to UI fields (extracted for reuse)
  void _mapProfileDataToUI(Map<String, dynamic> profileData) {
    if (!mounted) return;
    
    // Prepare data before setState
    String newRealname = profileData['realname']?.toString() ?? '';
    String newUniversity = '';
    String newMajor = '';
    String newYear = '';
    String newNationality = '';
    
    // Get school name from nested object or use ID
    if (profileData['school'] != null && profileData['school'] is Map<String, dynamic>) {
      newUniversity = profileData['school']['school_name']?.toString() ?? '';
    } else if (profileData['school_id'] != null) {
      final schoolId = profileData['school_id'];
      final sid = schoolId is int ? schoolId : int.tryParse(schoolId.toString()) ?? 1;
      newUniversity = _getSchoolName(sid);
    }
    
    // Get department name from nested object or use ID
    if (profileData['department'] != null && profileData['department'] is Map<String, dynamic>) {
      newMajor = profileData['department']['department_name']?.toString() ?? '';
    } else if (profileData['department_id'] != null) {
      final deptId = profileData['department_id'];
      final did = deptId is int ? deptId : int.tryParse(deptId.toString()) ?? 1;
      newMajor = _getDepartmentName(did);
    }
    
    // Get enrollment year
    if (profileData['enrollment_year'] != null) {
      final year = profileData['enrollment_year'];
      final yearInt = year is int ? year : int.tryParse(year.toString());
      newYear = _getYearStringFromEnrollmentYear(yearInt);
    }
    
    // Get nationality
    if (profileData['nationality_iso2'] != null) {
      newNationality = _getNationalityName(profileData['nationality_iso2'].toString());
    }
    
    // Get main language
    String newMainLanguage = '';
    if (profileData['main_language'] != null) {
      newMainLanguage = _getMainLanguageDisplayName(profileData['main_language'].toString());
    }
    
    // Update UI in setState
    if (mounted) {
      setState(() {
        _nameController.text = newRealname;
        _selectedUniversity = newUniversity;
        _selectedMajor = newMajor;
        _selectedYear = newYear;
        _selectedNationality = newNationality;
        _selectedMainLanguage = newMainLanguage;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      // Call API to get profile data using JWT token
      final profileData = await ProfileService.getMyProfile();
      
      if (!mounted) return;
      
      // Use the extracted mapping method
      _mapProfileDataToUI(profileData);
      
      // Also save to SharedPreferences for backward compatibility
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('realName', _nameController.text);
      if (profileData['school_id'] != null) {
        final schoolId = profileData['school_id'];
        await prefs.setInt('schoolId', schoolId is int ? schoolId : int.tryParse(schoolId.toString()) ?? 1);
      }
      if (profileData['department_id'] != null) {
        final deptId = profileData['department_id'];
        await prefs.setInt('departmentId', deptId is int ? deptId : int.tryParse(deptId.toString()) ?? 1);
      }
      if (profileData['enrollment_year'] != null) {
        final year = profileData['enrollment_year'];
        await prefs.setInt('enrollmentYear', year is int ? year : int.tryParse(year.toString()) ?? DateTime.now().year);
      }
      if (profileData['nationality_iso2'] != null) {
        await prefs.setString('nationalityIso2', profileData['nationality_iso2'].toString());
      }
      if (profileData['main_language'] != null) {
        await prefs.setString('mainLanguage', profileData['main_language'].toString());
      }
    } catch (e) {
      // Fallback to SharedPreferences if API fails
      if (!mounted) return;
      
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _nameController.text = prefs.getString('realName') ?? '';
        _selectedUniversity = _getSchoolName(prefs.getInt('schoolId') ?? 1);
        _selectedMajor = _getDepartmentName(prefs.getInt('departmentId') ?? 1);
        _selectedYear = _getYearStringFromEnrollmentYear(prefs.getInt('enrollmentYear'));
        _selectedNationality = _getNationalityName(prefs.getString('nationalityIso2') ?? 'KR');
        final mainLangCode = prefs.getString('mainLanguage') ?? 'en';
        _selectedMainLanguage = _getMainLanguageDisplayName(mainLangCode);
        _isLoading = false;
      });
    }
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

  String _getMainLanguageDisplayName(String code) {
    switch (code) {
      case 'ko': return '🇰🇷 한국어 (Korean)';
      case 'en': return '🇺🇸 English';
      case 'vi': return '🇻🇳 Tiếng Việt (Vietnamese)';
      case 'zh': return '🇨🇳 中文 (Chinese)';
      case 'ja': return '🇯🇵 日本語 (Japanese)';
      case 'my': return '🇲🇲 မြန်မာ (Myanmar)';
      default: return '🇺🇸 English';
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


  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Row(
      children: [
        Icon(icon, color: Colors.red[600], size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white70 : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value.isEmpty ? 'Not provided' : value,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.red[800],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                // Profile header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.red[600],
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.red[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _nameController.text.isEmpty ? 'User' : _nameController.text,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedUniversity.isEmpty ? 'Student' : _selectedUniversity,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                // Edit button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context).editProfile,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.red[800],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfileWizardScreen(),
                          ),
                        );
                        // Reload data immediately if update was successful
                        if (result != null) {
                          // Check if result is a map with success flag or just a boolean
                          bool isSuccess = false;
                          Map<String, dynamic>? updatedProfileData;
                          String? newMainLanguage;
                          
                          if (result is Map<String, dynamic>) {
                            isSuccess = result['success'] == true;
                            updatedProfileData = result['profile'] as Map<String, dynamic>?;
                            newMainLanguage = result['main_language']?.toString();
                          } else if (result == true) {
                            isSuccess = true;
                          }
                          
                          if (isSuccess) {
                            // If main_language changed, trigger app language reload
                            if (newMainLanguage != null && widget.onLanguageChanged != null) {
                              widget.onLanguageChanged!(newMainLanguage);
                            }
                            
                            // If we have updated profile data from response, use it directly
                            if (updatedProfileData != null) {
                              _mapProfileDataToUI(updatedProfileData);
                            } else {
                              // Otherwise, fetch fresh data from API
                              await Future.delayed(const Duration(milliseconds: 200));
                              await _loadUserData();
                            }
                          }
                        }
                      },
                      icon: const Icon(Icons.edit),
                      label: Text(AppLocalizations.of(context).edit),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Profile information display
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: isDark 
                          ? Colors.black.withValues(alpha: 0.3)
                          : Colors.grey.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(Icons.person, 'Name', _nameController.text),
                      const SizedBox(height: 16),
                      _buildInfoRow(Icons.school, 'University', _selectedUniversity),
                      const SizedBox(height: 16),
                      _buildInfoRow(Icons.book, 'Major', _selectedMajor),
                      const SizedBox(height: 16),
                      _buildInfoRow(Icons.calendar_today, 'Year', _selectedYear),
                      const SizedBox(height: 16),
                      _buildInfoRow(Icons.flag, 'Nationality', _selectedNationality),
                      const SizedBox(height: 16),
                      _buildInfoRow(Icons.language, AppLocalizations.of(context).mainLanguage, _selectedMainLanguage),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Logout button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _logout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.logout),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context).logout,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
          ),
        ),
      ),
    );
  }
}
