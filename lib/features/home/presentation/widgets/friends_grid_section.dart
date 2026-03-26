import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/home_state.dart';

class FriendsGridSection extends StatelessWidget {
  final List<FriendWidget> friends;
  final ValueChanged<FriendWidget>? onFriendTap;

  const FriendsGridSection({
    super.key,
    required this.friends,
    this.onFriendTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Friends',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            Icon(Icons.search, color: AppColors.textTertiary, size: 22),
          ],
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.85,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: friends.length,
          itemBuilder: (context, index) {
            return _FriendGridItem(
              friend: friends[index],
              onTap: onFriendTap == null
                  ? null
                  : () => onFriendTap!(friends[index]),
            );
          },
        ),
      ],
    );
  }
}

class _FriendGridItem extends StatelessWidget {
  final FriendWidget friend;
  final VoidCallback? onTap;

  const _FriendGridItem({required this.friend, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = [
      AppColors.accentPurple,
      AppColors.accentCyan,
      AppColors.primary,
      AppColors.accentPink,
      AppColors.accentOrange,
      AppColors.info,
    ];
    final colorIndex = friend.name.hashCode.abs() % colors.length;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.cardBorder, width: 0.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          Stack(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors[colorIndex].withValues(alpha: 0.2),
                ),
                child: Center(
                  child: Text(
                    friend.name[0].toUpperCase(),
                    style: TextStyle(
                      color: colors[colorIndex],
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              if (friend.isOnline)
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.online,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.cardDark,
                        width: 2.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            friend.name.split(' ').first,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          ],
        ),
      ),
    );
  }
}
