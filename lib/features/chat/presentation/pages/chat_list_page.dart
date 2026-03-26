import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../soulie/data/soulie_repository.dart';
import '../bloc/chat_list_bloc.dart';
import '../bloc/chat_list_event.dart';
import '../bloc/chat_list_state.dart';

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChatListBloc(
        soulieRepository: context.read<SoulieRepository>(),
      )..add(const ChatListLoadRequested()),
      child: const _ChatListView(),
    );
  }
}

class _ChatListView extends StatelessWidget {
  const _ChatListView();

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
                  onChanged: (value) => context.read<ChatListBloc>().add(
                    ChatListSearchChanged(value),
                  ),
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
              child: BlocBuilder<ChatListBloc, ChatListState>(
                builder: (context, state) {
                  if (state.status == ChatListStatus.loading &&
                      state.chats.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    );
                  }

                  if (state.status == ChatListStatus.error &&
                      state.chats.isEmpty) {
                    return Center(
                      child: Text(
                        state.errorMessage ?? 'Không thể tải danh sách tin nhắn',
                        style: TextStyle(
                          color: AppColors.textTertiary.withValues(alpha: 0.8),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: state.chats.length,
                    itemBuilder: (context, index) {
                      final chat = state.chats[index];
                      return _ChatListItem(
                        chat: chat,
                        onTap: () => context.pushNamed(
                          'chat',
                          pathParameters: {'friendKey': chat.friendId},
                          queryParameters: {'name': chat.friendName},
                        ),
                      );
                    },
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

class _ChatListItem extends StatelessWidget {
  final ChatPreview chat;
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
    final color = colors[chat.friendName.hashCode.abs() % colors.length];

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
                      chat.friendName[0],
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
                    chat.friendName,
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
