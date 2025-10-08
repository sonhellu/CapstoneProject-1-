import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../common/providers/onboarding_provider.dart';

class Step4ProfileScreen extends ConsumerStatefulWidget {
  const Step4ProfileScreen({super.key});

  @override
  ConsumerState<Step4ProfileScreen> createState() => _Step4ProfileState();
}

class _Step4ProfileState extends ConsumerState<Step4ProfileScreen> {
  final _realNameCtrl = TextEditingController();
  final _nickCtrl = TextEditingController();
  final _deptCtrl = TextEditingController();
  int? _entryYear;

  // 유효성
  String? get _realNameError {
    final v = _realNameCtrl.text.trim();
    if (v.isEmpty) return '실명을 입력해주세요.';
    if (v.length < 2) return '2자 이상 입력해주세요.';
    return null;
  }

  String? get _nickError {
    final v = _nickCtrl.text.trim();
    if (v.isEmpty) return '닉네임을 입력해주세요.';
    if (v.length < 2 || v.length > 16) return '닉네임은 2~16자여야 해요.';
    return null;
  }

  String? get _deptError {
    final v = _deptCtrl.text.trim();
    if (v.isEmpty) return '학과(전공)를 입력해주세요.';
    return null;
  }

  String? get _yearError {
    if (_entryYear == null) return '입학연도를 선택해주세요.';
    return null;
  }

  bool get _valid =>
      _realNameError == null &&
      _nickError == null &&
      _deptError == null &&
      _yearError == null;

  List<int> _yearOptions() {
    final now = DateTime.now().year;
    // 최근 20년 + 앞으로 1~2년 정도 여유
    return [for (var y = now + 2; y >= now - 20; y--) y];
  }

  void _next() {
    ref.read(onboardingBasicInfoProvider.notifier)
      ..setRealName(_realNameCtrl.text.trim())
      ..setNickname(_nickCtrl.text.trim())
      ..setDepartment(_deptCtrl.text.trim())
      ..setEntryYear(_entryYear!);

    context.go('/onboarding-step5'); // 다음 단계(약관 동의)로 이동 예정
  }

  @override
  void initState() {
    super.initState();
    // 저장된 값 채워주기(뒤로가기 후 복원)
    final saved = ref.read(onboardingBasicInfoProvider);
    _realNameCtrl.text = saved.realName ?? '';
    _nickCtrl.text = saved.nickname ?? '';
    _deptCtrl.text = saved.department ?? '';
    _entryYear = saved.entryYear;
  }

  @override
  void dispose() {
    _realNameCtrl.dispose();
    _nickCtrl.dispose();
    _deptCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Step 4: 프로필 설정')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Text('프로필 정보를 입력해주세요 ✍️',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),

            // 실명
            TextField(
              controller: _realNameCtrl,
              decoration: InputDecoration(
                labelText: '실명',
                border: const OutlineInputBorder(),
                errorText: _realNameCtrl.text.isEmpty ? null : _realNameError,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // 닉네임
            TextField(
              controller: _nickCtrl,
              decoration: InputDecoration(
                labelText: '닉네임',
                hintText: '예: 하이캠퍼스',
                border: const OutlineInputBorder(),
                errorText: _nickCtrl.text.isEmpty ? null : _nickError,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // 학과
            TextField(
              controller: _deptCtrl,
              decoration: InputDecoration(
                labelText: '학과(전공)',
                hintText: '예: 컴퓨터공학과',
                border: const OutlineInputBorder(),
                errorText: _deptCtrl.text.isEmpty ? null : _deptError,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // 입학연도
            InputDecorator(
              decoration: InputDecoration(
                labelText: '입학연도',
                border: const OutlineInputBorder(),
                errorText: _yearError == null ? null : _yearError,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  isExpanded: true,
                  value: _entryYear,
                  hint: const Text('선택'),
                  items: _yearOptions()
                      .map((y) =>
                          DropdownMenuItem(value: y, child: Text('$y년')))
                      .toList(),
                  onChanged: (v) => setState(() => _entryYear = v),
                ),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _valid ? _next : null,
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
