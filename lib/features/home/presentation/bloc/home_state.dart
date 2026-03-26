import 'package:equatable/equatable.dart';

enum HomeStatus { initial, loading, loaded, error }

class HomeState extends Equatable {
  final HomeStatus status;
  final List<FriendActivity> recentlyShared;
  final List<FriendWidget> friendsGrid;
  final String? liveFeedMessage;
  final int notificationCount;
  final String? errorMessage;

  const HomeState({
    this.status = HomeStatus.initial,
    this.recentlyShared = const [],
    this.friendsGrid = const [],
    this.liveFeedMessage,
    this.notificationCount = 0,
    this.errorMessage,
  });

  HomeState copyWith({
    HomeStatus? status,
    List<FriendActivity>? recentlyShared,
    List<FriendWidget>? friendsGrid,
    String? liveFeedMessage,
    int? notificationCount,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return HomeState(
      status: status ?? this.status,
      recentlyShared: recentlyShared ?? this.recentlyShared,
      friendsGrid: friendsGrid ?? this.friendsGrid,
      liveFeedMessage: liveFeedMessage ?? this.liveFeedMessage,
      notificationCount: notificationCount ?? this.notificationCount,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props =>
      [
        status,
        recentlyShared,
        friendsGrid,
        liveFeedMessage,
        notificationCount,
        errorMessage,
      ];
}

class FriendActivity extends Equatable {
  final String id;
  final String name;
  final String avatarUrl;
  final String timeAgo;
  final String? imageUrl;

  const FriendActivity({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.timeAgo,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [id, name, avatarUrl, timeAgo, imageUrl];
}

class FriendWidget extends Equatable {
  final String id;
  final String name;
  final String avatarUrl;
  final bool isOnline;

  const FriendWidget({
    required this.id,
    required this.name,
    required this.avatarUrl,
    this.isOnline = false,
  });

  @override
  List<Object?> get props => [id, name, avatarUrl, isOnline];
}
