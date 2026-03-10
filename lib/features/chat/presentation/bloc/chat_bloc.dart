import 'package:flutter_bloc/flutter_bloc.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(const ChatState()) {
    on<ChatLoadRequested>(_onLoad);
    on<ChatMessageSent>(_onSend);
  }

  Future<void> _onLoad(
    ChatLoadRequested event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(
      status: ChatStatus.loading,
      friendName: event.friendName,
    ));
    await Future.delayed(const Duration(milliseconds: 400));
    emit(state.copyWith(
      status: ChatStatus.loaded,
      messages: _mockMessages(event.friendName),
    ));
  }

  void _onSend(ChatMessageSent event, Emitter<ChatState> emit) {
    final newMessage = ChatMessage(
      text: event.message,
      isMe: true,
      time: 'Just now',
    );
    emit(state.copyWith(messages: [...state.messages, newMessage]));
  }

  List<ChatMessage> _mockMessages(String name) {
    return [
      ChatMessage(text: 'Hey! 👋', isMe: false, time: '2:30 PM'),
      ChatMessage(text: 'Hiii! How are you?', isMe: true, time: '2:31 PM'),
      ChatMessage(text: 'I\'m great! Check this out', isMe: false, time: '2:32 PM'),
      ChatMessage(text: '📸', isMe: false, time: '2:32 PM', type: MessageType.photo),
      ChatMessage(text: 'Omg that\'s amazing! 🔥', isMe: true, time: '2:33 PM'),
      ChatMessage(text: '❤️', isMe: true, time: '2:33 PM', type: MessageType.reaction),
      ChatMessage(text: 'Thanks!! Miss you 💕', isMe: false, time: '2:34 PM'),
    ];
  }
}
