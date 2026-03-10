import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object?> get props => [];
}

class ChatLoadRequested extends ChatEvent {
  final String friendName;
  const ChatLoadRequested(this.friendName);
  @override
  List<Object?> get props => [friendName];
}

class ChatMessageSent extends ChatEvent {
  final String message;
  const ChatMessageSent(this.message);
  @override
  List<Object?> get props => [message];
}
