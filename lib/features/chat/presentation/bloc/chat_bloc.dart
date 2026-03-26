import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../soulie/data/soulie_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc({required SoulieRepository soulieRepository})
    : _soulieRepository = soulieRepository,
      super(const ChatState()) {
    on<ChatLoadRequested>(_onLoad);
    on<ChatMessageSent>(_onSend);
  }

  final SoulieRepository _soulieRepository;

  Future<void> _onLoad(
    ChatLoadRequested event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(
      status: ChatStatus.loading,
      friendKey: event.friendKey,
      friendName: event.initialFriendName,
      clearErrorMessage: true,
    ));

    try {
      final conversationId = await _soulieRepository.openDirectConversation(
        event.friendKey,
      );
      final thread = await _soulieRepository.fetchConversationThread(
        conversationId,
      );
      await _soulieRepository.markConversationRead(conversationId);
      emit(state.copyWith(
        status: ChatStatus.loaded,
        conversationId: thread.conversationId,
        friendName: thread.friend.name,
        friendStatus: thread.friend.status,
        messages: thread.messages
            .map(
              (message) => ChatMessage(
                text: message.text,
                isMe: message.isMe,
                time: message.time,
                type: _mapMessageType(message.type),
              ),
            )
            .toList(growable: false),
      ));
    } on SoulieRepositoryException catch (error) {
      emit(state.copyWith(
        status: ChatStatus.error,
        errorMessage: error.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: ChatStatus.error,
        errorMessage: 'Không thể tải cuộc trò chuyện',
      ));
    }
  }

  Future<void> _onSend(ChatMessageSent event, Emitter<ChatState> emit) async {
    if (state.conversationId.isEmpty) {
      return;
    }

    try {
      final message = await _soulieRepository.sendConversationMessage(
        conversationId: state.conversationId,
        message: event.message,
      );
      emit(state.copyWith(
        status: ChatStatus.loaded,
        messages: [
          ...state.messages,
          ChatMessage(
            text: message.text,
            isMe: message.isMe,
            time: message.time,
            type: _mapMessageType(message.type),
          ),
        ],
        clearErrorMessage: true,
      ));
    } on SoulieRepositoryException catch (error) {
      emit(state.copyWith(
        status: ChatStatus.error,
        errorMessage: error.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: ChatStatus.error,
        errorMessage: 'Không thể gửi tin nhắn',
      ));
    }
  }

  MessageType _mapMessageType(String type) {
    switch (type) {
      case 'photo':
        return MessageType.photo;
      case 'reaction':
        return MessageType.reaction;
      default:
        return MessageType.text;
    }
  }
}
