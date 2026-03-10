import 'package:equatable/equatable.dart';

enum ChatStatus { initial, loading, loaded, error }

class ChatState extends Equatable {
  final ChatStatus status;
  final String friendName;
  final List<ChatMessage> messages;

  const ChatState({
    this.status = ChatStatus.initial,
    this.friendName = '',
    this.messages = const [],
  });

  ChatState copyWith({
    ChatStatus? status,
    String? friendName,
    List<ChatMessage>? messages,
  }) {
    return ChatState(
      status: status ?? this.status,
      friendName: friendName ?? this.friendName,
      messages: messages ?? this.messages,
    );
  }

  @override
  List<Object?> get props => [status, friendName, messages];
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
