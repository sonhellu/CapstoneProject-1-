import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 온보딩에서 수집하는 기본 정보 모델
class OnboardingBasicInfo {
  final String? language;
  final String? university;
  final String? country;
  final String? univEmail;
  final String? username;
  final String? password;

  final String? realName;
  final String? nickname;
  final String? department;
  final int? entryYear;

  final bool? agreeTerms;
  final bool? agreePrivacy;
  final bool? agreeNotifications;
  final bool? agreeMarketing;

  const OnboardingBasicInfo({
    this.language,
    this.university,
    this.country,
    this.univEmail,
    this.username,
    this.password,
    this.realName,
    this.nickname,
    this.department,
    this.entryYear,

    this.agreeTerms = false,
    this.agreePrivacy = false,
    this.agreeNotifications = false,
    this.agreeMarketing = false,
  });

  OnboardingBasicInfo copyWith({
    String? language,
    String? university,
    String? country,
    String? univEmail, 
    String? username,
    String? password,
    String? realName,
    String? nickname,
    String? department,
    int? entryYear,

    bool? agreeTerms,
    bool? agreePrivacy,
    bool? agreeNotifications,
    bool? agreeMarketing,
  }) {
    return OnboardingBasicInfo(
      language: language ?? this.language,
      university: university ?? this.university,
      country: country ?? this.country,
      univEmail: univEmail ?? this.univEmail,
      username: username ?? this.username,
      password: password ?? this.password,
      realName: realName ?? this.realName,
      nickname: nickname ?? this.nickname,
      department: department ?? this.department,
      entryYear: entryYear ?? this.entryYear,

      agreeTerms: agreeTerms ?? this.agreeTerms,
      agreePrivacy: agreePrivacy ?? this.agreePrivacy,
      agreeNotifications: agreeNotifications ?? this.agreeNotifications,
      agreeMarketing: agreeMarketing ?? this.agreeMarketing,
    );
  }

  /// Step1 완료 여부 판단 (언어/대학/국가 3개)
  bool get isComplete =>
      (language?.isNotEmpty ?? false) &&
      (university?.isNotEmpty ?? false) &&
      (country?.isNotEmpty ?? false);
}

/// 상태 변경 Notifier
class OnboardingBasicInfoNotifier extends StateNotifier<OnboardingBasicInfo> {
  OnboardingBasicInfoNotifier() : super(const OnboardingBasicInfo());

  void setLanguage(String? v)  => state = state.copyWith(language: v);
  void setUniversity(String? v)=> state = state.copyWith(university: v);
  void setCountry(String? v)   => state = state.copyWith(country: v);
  void setUnivEmail(String email) => state = state.copyWith(univEmail: email); 

  void setUsername(String v) => state = state.copyWith(username: v);
  void setPassword(String v) => state = state.copyWith(password: v);

  void setRealName(String v) => state = state.copyWith(realName: v);
  void setNickname(String v) => state = state.copyWith(nickname: v);
  void setDepartment(String v) => state = state.copyWith(department: v);
  void setEntryYear(int v) => state = state.copyWith(entryYear: v);

void setAgreeTerms(bool v) => state = state.copyWith(agreeTerms: v);
void setAgreePrivacy(bool v) => state = state.copyWith(agreePrivacy: v);
void setAgreeNotifications(bool v) => state = state.copyWith(agreeNotifications: v);
void setAgreeMarketing(bool v) => state = state.copyWith(agreeMarketing: v);
}

/// Provider
final onboardingBasicInfoProvider =
    StateNotifierProvider<OnboardingBasicInfoNotifier, OnboardingBasicInfo>(
  (ref) => OnboardingBasicInfoNotifier(),
);
