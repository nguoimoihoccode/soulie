import 'package:equatable/equatable.dart';

enum ChatListStatus { initial, loading, loaded, error }

class ChatPreview extends Equatable {
  final String friendId;
  final String friendName;
  final String avatarUrl;
  final String lastMessage;
  final String time;
  final bool isOnline;
  final int unread;
  final bool isPhoto;

  const ChatPreview({
    required this.friendId,
    required this.friendName,
    required this.avatarUrl,
    required this.lastMessage,
    required this.time,
    required this.isOnline,
    required this.unread,
    required this.isPhoto,
  });

  @override
  List<Object?> get props => [
        friendId,
        friendName,
        avatarUrl,
        lastMessage,
        time,
        isOnline,
        unread,
        isPhoto,
      ];
}

class ChatListState extends Equatable {
  final ChatListStatus status;
  final List<ChatPreview> chats;
  final String searchQuery;
  final String? errorMessage;

  const ChatListState({
    this.status = ChatListStatus.initial,
    this.chats = const [],
    this.searchQuery = '',
    this.errorMessage,
  });

  ChatListState copyWith({
    ChatListStatus? status,
    List<ChatPreview>? chats,
    String? searchQuery,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return ChatListState(
      status: status ?? this.status,
      chats: chats ?? this.chats,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, chats, searchQuery, errorMessage];
}
