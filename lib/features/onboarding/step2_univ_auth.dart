// lib/features/onboarding/step2_univ_auth.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Step2UnivAuthScreen extends StatelessWidget {
  const Step2UnivAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Step 2: 대학 이메일 인증')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('학교 이메일을 입력해주세요', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: '예: student@kmu.ac.kr',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  final email = controller.text.trim();
                  if (email.isEmpty || !email.contains('@')) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('유효한 이메일을 입력해주세요')),
                    );
                    return;
                  }
                  // TODO: 중복 체크 후
                  context.go('/onboarding-step3');
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('인증하기'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
