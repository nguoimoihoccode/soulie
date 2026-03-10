import 'package:equatable/equatable.dart';

enum HomeStatus { initial, loading, loaded, error }

class HomeState extends Equatable {
  final HomeStatus status;
  final List<FriendActivity> recentlyShared;
  final List<FriendWidget> friendsGrid;
  final String? liveFeedMessage;
  final String? errorMessage;

  const HomeState({
    this.status = HomeStatus.initial,
    this.recentlyShared = const [],
    this.friendsGrid = const [],
    this.liveFeedMessage,
    this.errorMessage,
  });

  HomeState copyWith({
    HomeStatus? status,
    List<FriendActivity>? recentlyShared,
    List<FriendWidget>? friendsGrid,
    String? liveFeedMessage,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      recentlyShared: recentlyShared ?? this.recentlyShared,
      friendsGrid: friendsGrid ?? this.friendsGrid,
      liveFeedMessage: liveFeedMessage ?? this.liveFeedMessage,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, recentlyShared, friendsGrid, liveFeedMessage, errorMessage];
}

class FriendActivity extends Equatable {
  final String name;
  final String avatarUrl;
  final String timeAgo;
  final String? imageUrl;

  const FriendActivity({
    required this.name,
    required this.avatarUrl,
    required this.timeAgo,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [name, avatarUrl, timeAgo, imageUrl];
}

class FriendWidget extends Equatable {
  final String name;
  final String avatarUrl;
  final bool isOnline;

  const FriendWidget({
    required this.name,
    required this.avatarUrl,
    this.isOnline = false,
  });

  @override
  List<Object?> get props => [name, avatarUrl, isOnline];
}
