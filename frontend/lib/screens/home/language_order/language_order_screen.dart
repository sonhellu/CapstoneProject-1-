import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/profile_service.dart';
import 'match_chat_screen.dart';

class LanguageOrderScreen extends StatefulWidget {
  const LanguageOrderScreen({super.key});

  @override
  State<LanguageOrderScreen> createState() => _LanguageOrderScreenState();
}

class _LanguageOrderScreenState extends State<LanguageOrderScreen> {
  final _formKey = GlobalKey<FormState>();

  final List<Map<String, String>> _languages = const [
    {'code': 'ko', 'label': '대한민국 · 한국어 🇰🇷'},
    {'code': 'en', 'label': 'United States · English 🇺🇸'},
    {'code': 'ja', 'label': '日本 · 日本語 🇯🇵'},
    {'code': 'vi', 'label': 'Việt Nam · Tiếng Việt 🇻🇳'},
    {'code': 'zh', 'label': '中国 · 中文 🇨🇳'},
    {'code': 'my', 'label': 'Myanmar · မြန်မာ 🇲🇲'},
  ];

  final List<String> _colleges = const [
    '인문국제학대학','사범대학','경영대학','사회과학대학','자연과학대학','공과대학',
    '음악공연예술대학','미술대학','체육대학','Keimyung Adams College','의과대학',
    '간호대학','Tabula Rasa College','약학대학','이부대학','상관없음',
  ];

  String? _selectedLangCode;
  String? _selectedGender;
  String? _selectedCollege;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMainLanguage();
  }

  Future<void> _loadMainLanguage() async {
    try {
      // Try to load main_language from profile API
      final profileData = await ProfileService.getMyProfile();
      final mainLang = profileData['main_language']?.toString();
      
      if (mainLang != null && _languages.any((lang) => lang['code'] == mainLang)) {
        if (mounted) {
          setState(() {
            _selectedLangCode = mainLang;
            _isLoading = false;
          });
        }
        return;
      }
    } catch (e) {
      // Fallback to SharedPreferences
    }
    
    // Fallback to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final mainLang = prefs.getString('mainLanguage');
    
    if (mounted) {
      if (mainLang != null && _languages.any((lang) => lang['code'] == mainLang)) {
        setState(() {
          _selectedLangCode = mainLang;
        });
      }
      
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.languageOrder),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    Text(
                      l10n.selectLanguageGenderCollege,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),

                    // 언어(국가)
                    DropdownButtonFormField<String>(
                      value: _selectedLangCode,
                      decoration: InputDecoration(
                        labelText: l10n.selectLanguageToLearn,
                        border: const OutlineInputBorder(),
                      ),
                      items: _languages
                          .map((e) => DropdownMenuItem<String>(
                                value: e['code'],
                                child: Text(e['label']!),
                              ))
                          .toList(),
                      validator: (v) => v == null ? l10n.selectLanguageToLearnRequired : null,
                      onChanged: (v) => setState(() => _selectedLangCode = v),
                    ),
                    const SizedBox(height: 12),

                    // 성별
                    InputDecorator(
                      decoration: InputDecoration(
                        labelText: l10n.preferredGender,
                        border: const OutlineInputBorder(),
                      ),
                      child: Builder(
                        builder: (context) {
                          final genderOptions = [l10n.female, l10n.male, l10n.noPreference];
                          // Initialize with noPreference if null
                          final currentGender = _selectedGender ?? l10n.noPreference;
                          return Wrap(
                            spacing: 8,
                            children: genderOptions.map((opt) {
                              final selected = currentGender == opt;
                              return ChoiceChip(
                                label: Text(opt),
                                selected: selected,
                                onSelected: (_) => setState(() => _selectedGender = opt),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 단과대학
                    DropdownButtonFormField<String>(
                      value: _selectedCollege ?? l10n.noPreference,
                      decoration: InputDecoration(
                        labelText: l10n.college,
                        border: const OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem<String>(
                          value: l10n.noPreference,
                          child: Text(l10n.noPreference),
                        ),
                        ..._colleges.map((c) => DropdownMenuItem<String>(
                              value: c,
                              child: Text(c),
                            )),
                      ],
                      onChanged: (v) => setState(() => _selectedCollege = v ?? l10n.noPreference),
                    ),
              const SizedBox(height: 16),

              // 찾기 버튼
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.search),
                  label: Text(AppLocalizations.of(context).findMatch),
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MatchChatScreen(
                          targetLanguageCode: _selectedLangCode!,
                          preferredGender: _selectedGender ?? l10n.noPreference,
                          preferredCollege: _selectedCollege ?? l10n.noPreference,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
