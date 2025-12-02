// lib/widgets/board_section.dart
import 'package:flutter/material.dart';
import '../screens/community/board_screen.dart';

class BoardSection extends StatelessWidget {
  final bool isDark;
  const BoardSection({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.06)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.forum_outlined,
                size: 28,
                color: isDark ? Colors.white : Colors.black87,
              ),
              const SizedBox(width: 12),
              Text(
                '게시판',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _BoardCategoryChip(
                label: '공지게시판',
                icon: Icons.campaign,
                category: BoardCategory.notice,
              ),
              _BoardCategoryChip(
                label: '자유게시판',
                icon: Icons.chat_bubble_outline,
                category: BoardCategory.free,
              ),
              _BoardCategoryChip(
                label: '정보게시판',
                icon: Icons.info_outline,
                category: BoardCategory.info,
              ),
              _BoardCategoryChip(
                label: '홍보게시판',
                icon: Icons.campaign_outlined,
                category: BoardCategory.promo,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BoardCategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final BoardCategory category;

  const _BoardCategoryChip({
    required this.label,
    required this.icon,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BoardScreen(initialCategory: category),
          ),
        );
      },
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: const LinearGradient(
            colors: [Color(0xFFE53935), Color(0xFF1E88E5)],
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
