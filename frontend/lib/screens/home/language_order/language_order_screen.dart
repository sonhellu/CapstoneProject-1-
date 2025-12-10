import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
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
  String _selectedGender = '상관없음';
  String _selectedCollege = '상관없음';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(title: Text(l10n.languageOrder)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                l10n.selectLanguageToLearn,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),

              // 언어(국가)
              DropdownButtonFormField<String>(
                value: _selectedLangCode,
                decoration: InputDecoration(
                  labelText: l10n.selectLanguageToLearnLabel,
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
                child: Wrap(
                  spacing: 8,
                  children: ['여','남','상관없음'].map((opt) {
                    final selected = _selectedGender == opt;
                    return ChoiceChip(
                      label: Text(opt),
                      selected: selected,
                      onSelected: (_) => setState(() => _selectedGender = opt),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),

              // 단과대학
              DropdownButtonFormField<String>(
                value: _selectedCollege,
                decoration: InputDecoration(
                  labelText: l10n.college,
                  border: const OutlineInputBorder(),
                ),
                items: _colleges
                    .map((c) => DropdownMenuItem<String>(
                          value: c,
                          child: Text(c),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCollege = v ?? '상관없음'),
              ),
              const SizedBox(height: 16),

              // 찾기 버튼
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.search),
                  label: Text(l10n.findMatch),
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MatchChatScreen(
                          targetLanguageCode: _selectedLangCode!,
                          preferredGender: _selectedGender,
                          preferredCollege: _selectedCollege,
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
