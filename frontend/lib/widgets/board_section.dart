// lib/widgets/board_section.dart
import 'package:flutter/material.dart';
import '../screens/community/board_screen.dart';
import '../l10n/app_localizations.dart';

/// 게시판별 최근 글 제목 (임시 더미 데이터)
/// 나중에 실제 DB / API 연동하면 이 부분만 바꿔주면 됨.
Map<BoardCategory, String> _getLatestTitles(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  return {
    BoardCategory.notice: l10n.latestNoticeTitle,
    BoardCategory.free: l10n.latestFreeTitle,
    BoardCategory.info: l10n.latestInfoTitle,
    BoardCategory.promo: l10n.latestPromoTitle,
  };
}

class BoardSection extends StatelessWidget {
  final bool isDark;
  const BoardSection({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark
        ? Colors.white.withOpacity(0.06)
        : Colors.white.withOpacity(0.9);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─ 헤더: "게시판" ─
          Row(
            children: [
              const Icon(Icons.chat_bubble_outline, size: 26),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context).board,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ─ 공지게시판 ─
          Builder(
            builder: (context) {
              final latestTitles = _getLatestTitles(context);
              return _BoardPreviewCard(
                icon: Icons.campaign_outlined,
                title: AppLocalizations.of(context).noticeBoard,
                subtitle: latestTitles[BoardCategory.notice] ?? AppLocalizations.of(context).noPostsYet,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BoardScreen(
                    initialCategory: BoardCategory.notice,
                  ),
                ),
              );
            },
          );
            },
          ),
          const SizedBox(height: 8),

          // ─ 자유게시판 ─
          Builder(
            builder: (context) {
              final latestTitles = _getLatestTitles(context);
              return _BoardPreviewCard(
                icon: Icons.chat_bubble_outline,
                title: AppLocalizations.of(context).freeBoard,
                subtitle: latestTitles[BoardCategory.free] ?? AppLocalizations.of(context).noPostsYet,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BoardScreen(
                    initialCategory: BoardCategory.free,
                  ),
                ),
              );
            },
          );
            },
          ),
          const SizedBox(height: 8),

          // ─ 정보게시판 ─
          Builder(
            builder: (context) {
              final latestTitles = _getLatestTitles(context);
              return _BoardPreviewCard(
                icon: Icons.info_outline,
                title: AppLocalizations.of(context).infoBoard,
                subtitle: latestTitles[BoardCategory.info] ?? AppLocalizations.of(context).noPostsYet,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BoardScreen(
                    initialCategory: BoardCategory.info,
                  ),
                ),
              );
            },
          );
            },
          ),
          const SizedBox(height: 8),

          // ─ 홍보게시판 ─
          Builder(
            builder: (context) {
              final latestTitles = _getLatestTitles(context);
              return _BoardPreviewCard(
                icon: Icons.campaign,
                title: AppLocalizations.of(context).promoBoard,
                subtitle: latestTitles[BoardCategory.promo] ?? AppLocalizations.of(context).noPostsYet,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BoardScreen(
                    initialCategory: BoardCategory.promo,
                  ),
                ),
              );
            },
          );
            },
          ),
        ],
      ),
    );
  }
}

/// 뉴스 리스트처럼 보이는 한 줄짜리 카드
class _BoardPreviewCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _BoardPreviewCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // 왼쪽 동그란 그라디언트 아이콘 영역
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFE53935), // 빨강
                      Color(0xFF1E88E5), // 파랑
                    ],
                  ),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),

              // 제목 + 최근 글 제목
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
