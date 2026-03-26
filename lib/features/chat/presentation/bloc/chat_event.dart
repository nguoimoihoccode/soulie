import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object?> get props => [];
}

class ChatLoadRequested extends ChatEvent {
  final String friendKey;
  final String initialFriendName;
  const ChatLoadRequested(this.friendKey, {this.initialFriendName = ''});
  @override
  List<Object?> get props => [friendKey, initialFriendName];
}

class ChatMessageSent extends ChatEvent {
  final String message;
  const ChatMessageSent(this.message);
  @override
  List<Object?> get props => [message];
}
