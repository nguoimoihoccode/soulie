import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../soulie/data/soulie_repository.dart';
import 'friends_event.dart';
import 'friends_state.dart';

class FriendsBloc extends Bloc<FriendsEvent, FriendsState> {
  FriendsBloc({required SoulieRepository soulieRepository})
    : _soulieRepository = soulieRepository,
      super(const FriendsState()) {
    on<FriendsLoadRequested>(_onLoad);
    on<FriendsSearchChanged>(_onSearch);
  }

  final SoulieRepository _soulieRepository;

  Future<void> _onLoad(
    FriendsLoadRequested event,
    Emitter<FriendsState> emit,
  ) async {
    await _loadFriends(emit, query: state.searchQuery);
  }

  Future<void> _onSearch(
    FriendsSearchChanged event,
    Emitter<FriendsState> emit,
  ) async {
    emit(state.copyWith(searchQuery: event.query));
    await _loadFriends(emit, query: event.query);
  }

  Future<void> _loadFriends(
    Emitter<FriendsState> emit, {
    required String query,
  }) async {
    emit(state.copyWith(status: FriendsStatus.loading));

    try {
      final friends = await _soulieRepository.fetchFriends(query: query);
      final mappedFriends = friends
          .map(
            (friend) => Friend(
              id: friend.id,
              name: friend.name,
              username: friend.username,
              status: friend.status,
              isOnline: friend.isOnline,
              avatarUrl: friend.avatarUrl,
            ),
          )
          .toList(growable: false);
      emit(state.copyWith(
        status: FriendsStatus.loaded,
        friends: mappedFriends,
        filteredFriends: mappedFriends,
      ));
    } on SoulieRepositoryException {
      emit(state.copyWith(
        status: FriendsStatus.error,
        friends: const [],
        filteredFriends: const [],
      ));
    } catch (_) {
      emit(state.copyWith(
        status: FriendsStatus.error,
        friends: const [],
        filteredFriends: const [],
      ));
    }
  }
}
