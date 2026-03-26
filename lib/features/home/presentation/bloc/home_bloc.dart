import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/home_widget_sync_service.dart';
import '../../../soulie/data/soulie_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({
    required SoulieRepository soulieRepository,
    required HomeWidgetSyncService homeWidgetSyncService,
  }) : _soulieRepository = soulieRepository,
       _homeWidgetSyncService = homeWidgetSyncService,
       super(const HomeState()) {
    on<HomeLoadRequested>(_onLoadRequested);
    on<HomeRefreshRequested>(_onRefreshRequested);
  }

  final SoulieRepository _soulieRepository;
  final HomeWidgetSyncService _homeWidgetSyncService;

  Future<void> _onLoadRequested(
    HomeLoadRequested event,
    Emitter<HomeState> emit,
  ) async {
    await _loadHome(emit);
  }

  Future<void> _onRefreshRequested(
    HomeRefreshRequested event,
    Emitter<HomeState> emit,
  ) async {
    await _loadHome(emit);
  }

  Future<void> _loadHome(Emitter<HomeState> emit) async {
    emit(state.copyWith(status: HomeStatus.loading, clearErrorMessage: true));

    try {
      final home = await _soulieRepository.fetchHome();
      final nextState = state.copyWith(
        status: HomeStatus.loaded,
        recentlyShared: home.recentlyShared
            .map(
              (activity) => FriendActivity(
                id: activity.id,
                name: activity.name,
                avatarUrl: activity.avatarUrl,
                timeAgo: activity.timeAgo,
                imageUrl: activity.imageUrl,
              ),
            )
            .toList(growable: false),
        friendsGrid: home.friendsGrid
            .map(
              (friend) => FriendWidget(
                id: friend.id,
                name: friend.name,
                avatarUrl: friend.avatarUrl,
                isOnline: friend.isOnline,
              ),
            )
            .toList(growable: false),
        liveFeedMessage: home.liveFeedMessage,
        notificationCount: home.notificationCount,
      );
      emit(nextState);
      await _homeWidgetSyncService.syncHome(nextState);
    } on SoulieRepositoryException catch (error) {
      emit(
        state.copyWith(status: HomeStatus.error, errorMessage: error.message),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: HomeStatus.error,
          errorMessage: 'Không thể tải trang chủ',
        ),
      );
    }
  }
}
