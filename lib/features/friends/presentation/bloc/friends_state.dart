import 'package:equatable/equatable.dart';

enum FriendsStatus { initial, loading, loaded, error }

class FriendsState extends Equatable {
  final FriendsStatus status;
  final List<Friend> friends;
  final List<Friend> filteredFriends;
  final String searchQuery;

  const FriendsState({
    this.status = FriendsStatus.initial,
    this.friends = const [],
    this.filteredFriends = const [],
    this.searchQuery = '',
  });

  FriendsState copyWith({
    FriendsStatus? status,
    List<Friend>? friends,
    List<Friend>? filteredFriends,
    String? searchQuery,
  }) {
    return FriendsState(
      status: status ?? this.status,
      friends: friends ?? this.friends,
      filteredFriends: filteredFriends ?? this.filteredFriends,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [status, friends, filteredFriends, searchQuery];
}

class Friend extends Equatable {
  final String name;
  final String username;
  final String status;
  final bool isOnline;

  const Friend({
    required this.name,
    required this.username,
    required this.status,
    this.isOnline = false,
  });

  @override
  List<Object?> get props => [name, username, status, isOnline];
}
