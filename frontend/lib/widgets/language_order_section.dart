import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../../screens/home/language_order/language_order_screen.dart';
import '../../screens/home/language_order/chat_room_screen.dart';

class LanguageOrderSection extends StatelessWidget {
  final bool isDark;
  const LanguageOrderSection({super.key, required this.isDark});

  // Sample online users data
  final List<_OnlineUser> _sampleUsers = const [
    _OnlineUser('alice', '경영대학', 'https://i.pravatar.cc/150?img=1'),
    _OnlineUser('bob', '공과대학', 'https://i.pravatar.cc/150?img=2'),
    _OnlineUser('chloe', '간호대학', 'https://i.pravatar.cc/150?img=3'),
    _OnlineUser('dan', '사회과학대학', 'https://i.pravatar.cc/150?img=4'),
    _OnlineUser('emma', '경영대학', 'https://i.pravatar.cc/150?img=5'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with More button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.people,
                    color: isDark ? Colors.white70 : Colors.grey[700],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context).onlineUsers,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_sampleUsers.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LanguageOrderScreen(),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppLocalizations.of(context).viewMore,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white70 : Colors.grey[700],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: isDark ? Colors.white70 : Colors.grey[700],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Divider line
          Divider(
            height: 1,
            thickness: 0.5,
            color: isDark 
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.2),
          ),
          
          const SizedBox(height: 12),
          
          // Online users list
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _sampleUsers.length,
              itemBuilder: (context, index) {
                final user = _sampleUsers[index];
                return _buildUserAvatar(context, user, isDark);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserAvatar(BuildContext context, _OnlineUser user, bool isDark) {
    return InkWell(
      onTap: () {
        // Generate a conversation ID based on user name
        // In production, this should come from backend API
        final conversationId = user.name.hashCode.abs() % 1000000;
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatRoomScreen(
              conversationId: conversationId,
              partnerName: user.name,
              targetLanguageLabel: '언어교류', // Default language label
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(40),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: isDark ? Colors.grey[700] : Colors.grey[300],
                  backgroundImage: user.avatarUrl.isNotEmpty 
                      ? NetworkImage(user.avatarUrl)
                      : null,
                  onBackgroundImageError: (_, __) {},
                  child: user.avatarUrl.isEmpty
                      ? Icon(Icons.person, size: 28, color: isDark ? Colors.grey[400] : Colors.grey[600])
                      : null,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? Colors.grey[900]! : Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 56,
              child: Text(
                user.name,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white70 : Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnlineUser {
  final String name;
  final String college;
  final String avatarUrl;

  const _OnlineUser(this.name, this.college, this.avatarUrl);
}
