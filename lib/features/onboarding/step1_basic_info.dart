import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../common/providers/onboarding_provider.dart';

class Step1BasicInfoScreen extends ConsumerWidget {
  const Step1BasicInfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = ref.watch(onboardingBasicInfoProvider);
    final notifier = ref.read(onboardingBasicInfoProvider.notifier);

    // 요청해 준 옵션들 포함
    final languages = <String>[
      '한국어',
      'English',
      '中文',
      '日本語',
      'Tiếng Việt (Vietnamese)',      // 베트남어
      'Монгол хэл (Mongolian)',       // 몽골어
      'မြန်မာဘာသာ (Burmese/Myanmar)', // 미얀마어
      'Oʻzbek (Uzbek)',               // 우즈베크어
    ];

    final universities = <String>[
      '서울대학교 (Seoul University)',
      '연세대학교 (Yonsei University)',
      '고려대학교 (Korea University)',
      '계명대학교 (Keimyung University)',
      '경북대학교 (Kyungpook National University)',
      '영남대학교 (Yeungnam University)',
      '기타 (Other)',
    ];

    final countries = <String>[
      '대한민국 (Korea)',
      'USA',
      'China',
      'Japan',
      'Vietnam',
      'Mongolia',
      'Myanmar',
      'Uzbekistan',
      'Other',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('기본 정보 입력'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Language'),
              DropdownButtonFormField<String>(
                value: info.language, // ❗️nullable 그대로 사용
                decoration: const InputDecoration(
                  hintText: '언어를 선택하세요',
                  border: OutlineInputBorder(),
                ),
                items: languages
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => notifier.setLanguage(val), // ❗️null 허용
              ),
              const SizedBox(height: 24),

              _label('University'),
              DropdownButtonFormField<String>(
                value: info.university, // ❗️nullable 그대로
                decoration: const InputDecoration(
                  hintText: '대학교를 선택하세요',
                  border: OutlineInputBorder(),
                ),
                items: universities
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => notifier.setUniversity(val), // ❗️null 허용
              ),
              const SizedBox(height: 24),

              _label('Country'),
              DropdownButtonFormField<String>(
                value: info.country, // ❗️nullable 그대로
                decoration: const InputDecoration(
                  hintText: '국가를 선택하세요',
                  border: OutlineInputBorder(),
                ),
                items: countries
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => notifier.setCountry(val), // ❗️null 허용
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: info.isComplete
                      ? () => context.go('/onboarding-step2')
                      : null,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text('Next'),
                  ),
                ),
              ),
            ],
          ),
        ),
      )
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      );
}
