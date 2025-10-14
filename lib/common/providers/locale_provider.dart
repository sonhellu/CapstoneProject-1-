import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds the current app locale. `null` means follow system.
class LocaleNotifier extends StateNotifier<Locale?> {
  LocaleNotifier() : super(const Locale('en'));

  void setEnglish() => state = const Locale('en');
  void setKorean() => state = const Locale('ko');
  void setVietnamese() => state = const Locale('vi');
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>(
  (ref) => LocaleNotifier(),
);


