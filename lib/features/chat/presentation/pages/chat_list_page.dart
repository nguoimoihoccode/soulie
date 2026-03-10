import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Messages',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: const Icon(
                      Icons.edit_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.cardBorder, width: 0.5),
                ),
                child: TextField(
                  style:
                      const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search messages...',
                    hintStyle: TextStyle(
                      color: AppColors.textTertiary.withValues(alpha: 0.5),
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.textTertiary,
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Chat list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _mockChats.length,
                itemBuilder: (context, index) {
                  final chat = _mockChats[index];
                  return _ChatListItem(
                    chat: chat,
                    onTap: () => context.push('/main/chat/${chat.name}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatData {
  final String name;
  final String lastMessage;
  final String time;
  final bool isOnline;
  final int unread;
  final bool isPhoto;

  const _ChatData({
    required this.name,
    required this.lastMessage,
    required this.time,
    this.isOnline = false,
    this.unread = 0,
    this.isPhoto = false,
  });
}

final _mockChats = [
  const _ChatData(
    name: 'Sarah Chen',
    lastMessage: 'Sent a photo',
    time: '2m',
    isOnline: true,
    unread: 2,
    isPhoto: true,
  ),
  const _ChatData(
    name: 'Alex Rivera',
    lastMessage: 'Omg that\'s amazing! 🔥',
    time: '15m',
    isOnline: true,
    unread: 1,
  ),
  const _ChatData(
    name: 'Luna Skye',
    lastMessage: 'Miss you 💕',
    time: '1h',
    isOnline: false,
  ),
  const _ChatData(
    name: 'Marcus V.',
    lastMessage: 'Sent a photo',
    time: '2h',
    isOnline: false,
    isPhoto: true,
  ),
  const _ChatData(
    name: 'Jordan Day',
    lastMessage: 'See you tomorrow!',
    time: '3h',
    isOnline: true,
  ),
  const _ChatData(
    name: 'Chris Kim',
    lastMessage: '👏👏👏',
    time: '5h',
    isOnline: false,
  ),
  const _ChatData(
    name: 'Elena Rose',
    lastMessage: 'That looks so good',
    time: '8h',
    isOnline: false,
  ),
  const _ChatData(
    name: 'Riley Cooper',
    lastMessage: 'Haha thanks!',
    time: '1d',
    isOnline: false,
  ),
];

class _ChatListItem extends StatelessWidget {
  final _ChatData chat;
  final VoidCallback onTap;

  const _ChatListItem({required this.chat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = [
      AppColors.primary,
      AppColors.accentPurple,
      AppColors.accentCyan,
      AppColors.accentOrange,
      AppColors.accentRose,
    ];
    final color = colors[chat.name.hashCode.abs() % colors.length];

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        margin: const EdgeInsets.symmetric(vertical: 1),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.15),
                  ),
                  child: Center(
                    child: Text(
                      chat.name[0],
                      style: TextStyle(
                        color: color,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                if (chat.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.background,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // Name + last message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat.name,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight:
                          chat.unread > 0 ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      if (chat.isPhoto)
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Icon(
                            Icons.image_rounded,
                            size: 14,
                            color: AppColors.primary,
                          ),
                        ),
                      Expanded(
                        child: Text(
                          chat.lastMessage,
                          style: TextStyle(
                            color: chat.unread > 0
                                ? AppColors.textSecondary
                                : AppColors.textTertiary,
                            fontSize: 13,
                            fontWeight: chat.unread > 0
                                ? FontWeight.w500
                                : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Time + unread badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  chat.time,
                  style: TextStyle(
                    color: chat.unread > 0
                        ? AppColors.primary
                        : AppColors.textTertiary,
                    fontSize: 12,
                    fontWeight:
                        chat.unread > 0 ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                if (chat.unread > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      chat.unread.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
