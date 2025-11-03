import 'package:flutter/material.dart';
import '../screens/home/language_order/language_order_screen.dart';

class LanguageOrderSection extends StatelessWidget {
  final bool isDark;

  const LanguageOrderSection({
    super.key,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LanguageOrderScreen(),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text('Language Order Section - Tap to navigate'),
        ),
      ),
    );
  }
}
