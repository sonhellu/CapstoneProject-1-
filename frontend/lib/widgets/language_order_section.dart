import 'package:flutter/material.dart';
import '../../screens/home/language_order/language_order_screen.dart';

class LanguageOrderSection extends StatelessWidget {
  final bool isDark;
  const LanguageOrderSection({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LanguageOrderScreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(16),
        height: 180,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.05),
          ),
        ),
        child: const Center(
          child: Text(
            'Language Order Section - Tap to navigate',
            style: TextStyle(fontSize: 15),
          ),
        ),
      ),
    );
  }
}
