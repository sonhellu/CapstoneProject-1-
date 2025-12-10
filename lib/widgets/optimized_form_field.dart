import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class OptimizedFormField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData prefixIcon;
  final String? Function(String?) validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final bool isDark;
  final int animationDelay;

  const OptimizedFormField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.prefixIcon,
    required this.validator,
    required this.isDark,
    this.obscureText = false,
    this.keyboardType,
    this.animationDelay = 0,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: AppConstants.animationNormal.inMilliseconds + animationDelay),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              obscureText: obscureText,
              decoration: InputDecoration(
                labelText: labelText,
                prefixIcon: Icon(prefixIcon),
                filled: true,
                fillColor: isDark ? AppConstants.darkCardColor : AppConstants.lightSurfaceColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusL),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusL),
                  borderSide: const BorderSide(color: AppConstants.primaryColor, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusL),
                  borderSide: BorderSide(
                    color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
                  ),
                ),
                labelStyle: TextStyle(
                  color: isDark ? Colors.white70 : Colors.grey[600],
                  fontSize: AppConstants.fontSizeM,
                ),
              ),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: AppConstants.fontSizeM,
              ),
              validator: validator,
            ),
          ),
        );
      },
    );
  }
}
