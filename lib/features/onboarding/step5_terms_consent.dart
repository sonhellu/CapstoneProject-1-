import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../common/providers/onboarding_provider.dart';

class Step5TermsConsentScreen extends ConsumerStatefulWidget {
  const Step5TermsConsentScreen({super.key});

  @override
  ConsumerState<Step5TermsConsentScreen> createState() => _Step5TermsConsentState();
}

class _Step5TermsConsentState extends ConsumerState<Step5TermsConsentScreen> {
  bool agreeTerms = false;
  bool agreePrivacy = false;
  bool agreeNotifications = false;
  bool agreeMarketing = false;

  bool get _canComplete => agreeTerms && agreePrivacy;

  void _completeSignup() {
    // 저장 (필요 시 서버 전송 로직으로 대체 가능)
    ref.read(onboardingBasicInfoProvider.notifier)
      ..setAgreeTerms(agreeTerms)
      ..setAgreePrivacy(agreePrivacy)
      ..setAgreeNotifications(agreeNotifications)
      ..setAgreeMarketing(agreeMarketing);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🎉 회원가입이 완료되었습니다!')),
    );

    // 홈으로 이동
    context.go('/feed');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Step 5: 약관 및 동의')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('앱 이용을 위한 약관 동의가 필요합니다 📄',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),

            // 필수 약관
            CheckboxListTile(
              title: const Text('[필수] 이용약관에 동의합니다.'),
              value: agreeTerms,
              onChanged: (v) => setState(() => agreeTerms = v ?? false),
            ),
            CheckboxListTile(
              title: const Text('[필수] 개인정보 처리방침에 동의합니다.'),
              value: agreePrivacy,
              onChanged: (v) => setState(() => agreePrivacy = v ?? false),
            ),

            // 선택 항목
            const Divider(height: 32),
            CheckboxListTile(
              title: const Text('[선택] 필수 알림 수신에 동의합니다.'),
              value: agreeNotifications,
              onChanged: (v) => setState(() => agreeNotifications = v ?? false),
            ),
            CheckboxListTile(
              title: const Text('[선택] 마케팅 정보 수신에 동의합니다.'),
              value: agreeMarketing,
              onChanged: (v) => setState(() => agreeMarketing = v ?? false),
            ),

            const SizedBox(height: 12),
            const Text(
              '세부 알림 설정은 앱 내부 설정에서 변경하실 수 있습니다.',
              style: TextStyle(color: Colors.black54),
            ),
            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _canComplete ? _completeSignup : null,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('회원가입 완료'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
