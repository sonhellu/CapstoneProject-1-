import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../common/providers/onboarding_provider.dart';

class Step3AccountInfoScreen extends ConsumerStatefulWidget {
  const Step3AccountInfoScreen({super.key});

  @override
  ConsumerState<Step3AccountInfoScreen> createState() => _Step3AccountInfoState();
}

class _Step3AccountInfoState extends ConsumerState<Step3AccountInfoScreen> {
  final _idCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  final _pw2Ctrl = TextEditingController();

  bool _showPw = false;
  bool _showPw2 = false;

  // 규칙:
  // - 아이디: 영문(필수) + 숫자(선택)만, 길이 4~20
  final _idReg = RegExp(r'^(?=.*[A-Za-z])[A-Za-z0-9]{4,20}$');

  // - 비밀번호: 영문(필수) + 숫자(필수) 혼합, 길이 8~32
  final _pwReg = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,32}$');

  String? get _idError {
    final v = _idCtrl.text.trim();
    if (v.isEmpty) return '아이디를 입력하세요.';
    if (!_idReg.hasMatch(v)) return '영문(필수)+숫자(선택), 4~20자만 가능해요.';
    return null;
  }

  String? get _pwError {
    final v = _pwCtrl.text;
    if (v.isEmpty) return '비밀번호를 입력하세요.';
    if (!_pwReg.hasMatch(v)) return '영문+숫자 조합, 8~32자여야 해요.';
    return null;
  }

  String? get _pw2Error {
    final v1 = _pwCtrl.text;
    final v2 = _pw2Ctrl.text;
    if (v2.isEmpty) return '비밀번호를 한 번 더 입력하세요.';
    if (v1 != v2) return '비밀번호가 일치하지 않아요.';
    return null;
  }

  bool get _valid => _idError == null && _pwError == null && _pw2Error == null;

  void _goNext() {
    // 상태 저장 (임시 저장 용도)
    ref.read(onboardingBasicInfoProvider.notifier)
      ..setUsername(_idCtrl.text.trim())
      ..setPassword(_pwCtrl.text);

    // Step4로 이동
    context.go('/onboarding-step4');
  }

  @override
  void dispose() {
    _idCtrl.dispose();
    _pwCtrl.dispose();
    _pw2Ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 기존에 값이 있으면 초기화(뒤로 왔다가 올 때 편의)
    final saved = ref.watch(onboardingBasicInfoProvider);
    if (_idCtrl.text.isEmpty && (saved.username ?? '').isNotEmpty) {
      _idCtrl.text = saved.username!;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Step 3: 계정 설정')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Text('아이디와 비밀번호를 설정해주세요 🔐',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),

            // 아이디
            TextField(
              controller: _idCtrl,
              decoration: InputDecoration(
                labelText: '아이디 (영문 필수, 숫자 선택)',
                hintText: '예: hicampus2025',
                border: const OutlineInputBorder(),
                errorText: _idCtrl.text.isEmpty ? null : _idError,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // 비밀번호
            TextField(
              controller: _pwCtrl,
              obscureText: !_showPw,
              decoration: InputDecoration(
                labelText: '비밀번호 (영문+숫자)',
                hintText: '8~32자, 영문/숫자 조합',
                border: const OutlineInputBorder(),
                errorText: _pwCtrl.text.isEmpty ? null : _pwError,
                suffixIcon: IconButton(
                  icon: Icon(_showPw ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _showPw = !_showPw),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // 비밀번호 확인
            TextField(
              controller: _pw2Ctrl,
              obscureText: !_showPw2,
              decoration: InputDecoration(
                labelText: '비밀번호 확인',
                border: const OutlineInputBorder(),
                errorText: _pw2Ctrl.text.isEmpty ? null : _pw2Error,
                suffixIcon: IconButton(
                  icon: Icon(_showPw2 ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _showPw2 = !_showPw2),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 24),

            // 안내 문구(옵션)
            const Text(
              '아이디는 영문(필수) + 숫자(선택)만 사용 가능합니다.\n'
              '비밀번호는 영문과 숫자를 반드시 포함해야 합니다.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _valid ? _goNext : null,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('Next'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
