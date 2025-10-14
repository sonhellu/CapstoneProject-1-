import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../common/providers/locale_provider.dart';
import 'package:hi_cam_app/l10n/app_localizations.dart';

class HomeShell extends StatefulWidget {
  final Widget child;
  final String location;

  const HomeShell({
    super.key, 
    required this.child,
    required this.location});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _indexFromLocation(String location) {
    if (location.startsWith('/jobs')) return 1;
    if (location.startsWith('/exchange')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  void _go(int idx) {
    switch (idx) {
      case 0: context.go('/feed'); break;
      case 1: context.go('/jobs'); break;
      case 2: context.go('/exchange'); break;
      case 3: context.go('/profile'); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    //final location = GoRouter.of(context).uri.toString();
    final currentIndex = _indexFromLocation(widget.location);

    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.appTitle),
        actions: [
          _LanguageMenu(),
        ],
      ),
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: _go,
        destinations: [
          NavigationDestination(icon: const Icon(Icons.forum_outlined), selectedIcon: const Icon(Icons.forum), label: t.feed),
          NavigationDestination(icon: const Icon(Icons.work_outline), selectedIcon: const Icon(Icons.work), label: t.jobs),
          NavigationDestination(icon: const Icon(Icons.language_outlined), selectedIcon: const Icon(Icons.language), label: t.exchange),
          NavigationDestination(icon: const Icon(Icons.person_outline), selectedIcon: const Icon(Icons.person), label: t.profile),
        ],
      ),
    );
  }
}

class _LanguageMenu extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(localeProvider);
    final t = AppLocalizations.of(context)!;
    return PopupMenuButton<String>(
      tooltip: t.language,
      icon: const Icon(Icons.language),
      onSelected: (value) {
        final notifier = ref.read(localeProvider.notifier);
        switch (value) {
          case 'ko':
            notifier.setKorean();
            break;
          case 'vi':
            notifier.setVietnamese();
            break;
          default:
            notifier.setEnglish();
        }
      },
      itemBuilder: (context) => [
        CheckedPopupMenuItem(
          value: 'en',
          checked: (current?.languageCode ?? 'en') == 'en',
          child: Text(t.english),
        ),
        CheckedPopupMenuItem(
          value: 'ko',
          checked: (current?.languageCode ?? 'en') == 'ko',
          child: Text(t.korean),
        ),
        CheckedPopupMenuItem(
          value: 'vi',
          checked: (current?.languageCode ?? 'en') == 'vi',
          child: Text(t.vietnamese),
        ),
      ],
    );
  }
}
