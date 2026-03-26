import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../soulie/data/soulie_repository.dart';
import 'chat_list_event.dart';
import 'chat_list_state.dart';

class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  ChatListBloc({required SoulieRepository soulieRepository})
    : _soulieRepository = soulieRepository,
      super(const ChatListState()) {
    on<ChatListLoadRequested>(_onLoad);
    on<ChatListSearchChanged>(_onSearch);
  }

  final SoulieRepository _soulieRepository;

  Future<void> _onLoad(
    ChatListLoadRequested event,
    Emitter<ChatListState> emit,
  ) async {
    await _loadChats(emit, query: state.searchQuery);
  }

  Future<void> _onSearch(
    ChatListSearchChanged event,
    Emitter<ChatListState> emit,
  ) async {
    emit(state.copyWith(searchQuery: event.query, clearErrorMessage: true));
    await _loadChats(emit, query: event.query);
  }

  Future<void> _loadChats(
    Emitter<ChatListState> emit, {
    required String query,
  }) async {
    emit(state.copyWith(status: ChatListStatus.loading, clearErrorMessage: true));

    try {
      final chats = await _soulieRepository.fetchChats(query: query);
      emit(state.copyWith(
        status: ChatListStatus.loaded,
        chats: chats
            .map(
              (chat) => ChatPreview(
                friendId: chat.friendId,
                friendName: chat.friendName,
                avatarUrl: chat.avatarUrl,
                lastMessage: chat.lastMessage,
                time: chat.time,
                isOnline: chat.isOnline,
                unread: chat.unread,
                isPhoto: chat.isPhoto,
              ),
            )
            .toList(growable: false),
      ));
    } on SoulieRepositoryException catch (error) {
      emit(state.copyWith(
        status: ChatListStatus.error,
        errorMessage: error.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: ChatListStatus.error,
        errorMessage: 'Không thể tải danh sách tin nhắn',
      ));
    }
  }
}
