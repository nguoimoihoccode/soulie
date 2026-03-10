import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeState()) {
    on<HomeLoadRequested>(_onLoadRequested);
    on<HomeRefreshRequested>(_onRefreshRequested);
  }

  Future<void> _onLoadRequested(
    HomeLoadRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(status: HomeStatus.loading));

    // Simulate loading mock data
    await Future.delayed(const Duration(milliseconds: 800));

    emit(state.copyWith(
      status: HomeStatus.loaded,
      recentlyShared: _mockRecentlyShared,
      friendsGrid: _mockFriendsGrid,
      liveFeedMessage: 'Wish you were here! 🏔️',
    ));
  }

  Future<void> _onRefreshRequested(
    HomeRefreshRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(status: HomeStatus.loading));
    await Future.delayed(const Duration(milliseconds: 500));
    emit(state.copyWith(
      status: HomeStatus.loaded,
      recentlyShared: _mockRecentlyShared,
      friendsGrid: _mockFriendsGrid,
    ));
  }

  static const List<FriendActivity> _mockRecentlyShared = [
    FriendActivity(name: 'Sarah', avatarUrl: '', timeAgo: '2m ago'),
    FriendActivity(name: 'Alex', avatarUrl: '', timeAgo: '5m ago'),
    FriendActivity(name: 'Luna', avatarUrl: '', timeAgo: '12m ago'),
    FriendActivity(name: 'Marcus', avatarUrl: '', timeAgo: '30m ago'),
  ];

  static const List<FriendWidget> _mockFriendsGrid = [
    FriendWidget(name: 'Sarah Chen', avatarUrl: '', isOnline: true),
    FriendWidget(name: 'Alex Rivera', avatarUrl: '', isOnline: true),
    FriendWidget(name: 'Luna Skye', avatarUrl: '', isOnline: false),
    FriendWidget(name: 'Marcus V.', avatarUrl: '', isOnline: true),
    FriendWidget(name: 'Jordan', avatarUrl: '', isOnline: false),
    FriendWidget(name: 'Chris Kim', avatarUrl: '', isOnline: true),
  ];
}
