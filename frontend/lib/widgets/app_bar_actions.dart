import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'language_picker.dart';

class AppBarActions extends StatelessWidget {
  final Function(String)? onLanguageChanged;
  
  const AppBarActions({super.key, this.onLanguageChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Theme toggle button
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return IconButton(
              onPressed: () {
                themeProvider.toggleTheme();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(
                          themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          themeProvider.isDarkMode 
                            ? 'Switched to Dark Mode' 
                            : 'Switched to Light Mode',
                        ),
                      ],
                    ),
                    backgroundColor: themeProvider.isDarkMode 
                      ? Colors.grey[800] 
                      : Colors.orange[600],
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  key: ValueKey(themeProvider.isDarkMode),
                  color: Colors.white,
                ),
              ),
              tooltip: themeProvider.isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            );
          },
        ),
        const SizedBox(width: 4),
        // Language picker
        LanguagePicker(onLanguageChanged: onLanguageChanged),
      ],
    );
  }
}
