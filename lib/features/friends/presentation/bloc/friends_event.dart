import 'package:equatable/equatable.dart';

abstract class FriendsEvent extends Equatable {
  const FriendsEvent();
  @override
  List<Object?> get props => [];
}

class FriendsLoadRequested extends FriendsEvent {
  const FriendsLoadRequested();
}

class FriendsSearchChanged extends FriendsEvent {
  final String query;
  const FriendsSearchChanged(this.query);
  @override
  List<Object?> get props => [query];
}
