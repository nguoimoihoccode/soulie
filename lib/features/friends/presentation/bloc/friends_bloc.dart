import 'package:flutter_bloc/flutter_bloc.dart';
import 'friends_event.dart';
import 'friends_state.dart';

class FriendsBloc extends Bloc<FriendsEvent, FriendsState> {
  FriendsBloc() : super(const FriendsState()) {
    on<FriendsLoadRequested>(_onLoad);
    on<FriendsSearchChanged>(_onSearch);
  }

  Future<void> _onLoad(
    FriendsLoadRequested event,
    Emitter<FriendsState> emit,
  ) async {
    emit(state.copyWith(status: FriendsStatus.loading));
    await Future.delayed(const Duration(milliseconds: 600));
    emit(state.copyWith(
      status: FriendsStatus.loaded,
      friends: _mockFriends,
      filteredFriends: _mockFriends,
    ));
  }

  void _onSearch(FriendsSearchChanged event, Emitter<FriendsState> emit) {
    final query = event.query.toLowerCase();
    if (query.isEmpty) {
      emit(state.copyWith(
        filteredFriends: state.friends,
        searchQuery: '',
      ));
    } else {
      final filtered = state.friends
          .where((f) => f.name.toLowerCase().contains(query))
          .toList();
      emit(state.copyWith(
        filteredFriends: filtered,
        searchQuery: query,
      ));
    }
  }

  static const List<Friend> _mockFriends = [
    Friend(name: 'Alex Rivera', username: '@arivera', status: 'Active now', isOnline: true),
    Friend(name: 'Sarah Chen', username: '@schen', status: 'Sent a photo 2m ago', isOnline: true),
    Friend(name: 'Marcus V.', username: '@marcusv', status: 'Active 15m ago', isOnline: true),
    Friend(name: 'Luna Skye', username: '@lunaskye', status: 'Typing...', isOnline: true),
    Friend(name: 'Jordan Day', username: '@jday', status: 'Active 1h ago', isOnline: false),
    Friend(name: 'Chris Kim', username: '@ckim', status: 'Away for 3h', isOnline: false),
    Friend(name: 'Elena Rose', username: '@erose', status: 'Active 5m ago', isOnline: true),
    Friend(name: 'Mike T.', username: '@miket', status: 'Viewing your story', isOnline: true),
    Friend(name: 'Riley Cooper', username: '@rcooper', status: 'Last seen yesterday', isOnline: false),
    Friend(name: 'Sam Wilson', username: '@swilson', status: 'Last seen 2 days ago', isOnline: false),
  ];
}
