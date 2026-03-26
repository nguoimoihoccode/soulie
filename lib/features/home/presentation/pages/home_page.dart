import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/home_widget_sync_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../soulie/data/soulie_repository.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/recently_shared_section.dart';
import '../widgets/friends_grid_section.dart';
import '../widgets/live_feed_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeBloc(
        soulieRepository: context.read<SoulieRepository>(),
        homeWidgetSyncService: context.read<HomeWidgetSyncService>(),
      )..add(const HomeLoadRequested()),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state.status == HomeStatus.loading &&
              state.recentlyShared.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state.status == HomeStatus.error &&
              state.recentlyShared.isEmpty &&
              state.friendsGrid.isEmpty) {
            return Center(
              child: Text(
                state.errorMessage ?? 'Không thể tải trang chủ',
                style: TextStyle(
                  color: AppColors.textTertiary.withValues(alpha: 0.8),
                ),
              ),
            );
          }

          final leadActivity = state.recentlyShared.isNotEmpty
              ? state.recentlyShared.first
              : null;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // App Bar
              SliverAppBar(
                floating: true,
                backgroundColor: AppColors.background,
                elevation: 0,
                title: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: AppColors.background,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Soulie',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    onPressed: () => context.push('/main/profile'),
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(
                          Icons.notifications_outlined,
                          color: AppColors.textSecondary,
                        ),
                        if (state.notificationCount > 0)
                          Positioned(
                            right: -4,
                            top: -2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 1,
                              ),
                              decoration: const BoxDecoration(
                                color: AppColors.accentPink,
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                              child: Text(
                                state.notificationCount > 99
                                    ? '99+'
                                    : state.notificationCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
              ),

              // Content
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 8),
                    // Recently Shared
                    RecentlySharedSection(friends: state.recentlyShared),
                    const SizedBox(height: 24),
                    // Friends Grid
                    FriendsGridSection(
                      friends: state.friendsGrid,
                      onFriendTap: (friend) => context.pushNamed(
                        'chat',
                        pathParameters: {'friendKey': friend.id},
                        queryParameters: {'name': friend.name},
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Live Feed
                    LiveFeedCard(
                      message: state.liveFeedMessage ?? '',
                      friendName: leadActivity?.name ?? 'Soulie',
                      timeAgo: leadActivity?.timeAgo ?? 'Just now',
                    ),
                    const SizedBox(height: 120),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
