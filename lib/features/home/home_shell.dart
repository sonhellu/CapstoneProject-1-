import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: _go,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.forum_outlined), selectedIcon: Icon(Icons.forum), label: 'Feed'),
          NavigationDestination(icon: Icon(Icons.work_outline), selectedIcon: Icon(Icons.work), label: 'Jobs'),
          NavigationDestination(icon: Icon(Icons.language_outlined), selectedIcon: Icon(Icons.language), label: 'Exchange'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
