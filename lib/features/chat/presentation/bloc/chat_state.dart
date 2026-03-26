import 'package:equatable/equatable.dart';

enum ChatStatus { initial, loading, loaded, error }

class ChatState extends Equatable {
  final ChatStatus status;
  final String friendKey;
  final String conversationId;
  final String friendName;
  final String friendStatus;
  final List<ChatMessage> messages;
  final String? errorMessage;

  const ChatState({
    this.status = ChatStatus.initial,
    this.friendKey = '',
    this.conversationId = '',
    this.friendName = '',
    this.friendStatus = '',
    this.messages = const [],
    this.errorMessage,
  });

  ChatState copyWith({
    ChatStatus? status,
    String? friendKey,
    String? conversationId,
    String? friendName,
    String? friendStatus,
    List<ChatMessage>? messages,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return ChatState(
      status: status ?? this.status,
      friendKey: friendKey ?? this.friendKey,
      conversationId: conversationId ?? this.conversationId,
      friendName: friendName ?? this.friendName,
      friendStatus: friendStatus ?? this.friendStatus,
      messages: messages ?? this.messages,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props =>
      [
        status,
        friendKey,
        conversationId,
        friendName,
        friendStatus,
        messages,
        errorMessage,
      ];
}

class ChatMessage extends Equatable {
  final String text;
  final bool isMe;
  final String time;
  final MessageType type;

  const ChatMessage({
    required this.text,
    required this.isMe,
    required this.time,
    this.type = MessageType.text,
  });

  @override
  List<Object?> get props => [text, isMe, time, type];
}

enum MessageType { text, photo, reaction }
