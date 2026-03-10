import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

class ProfileLoadRequested extends ProfileEvent {
  const ProfileLoadRequested();
}

class ProfileNameChanged extends ProfileEvent {
  final String name;
  const ProfileNameChanged(this.name);
  @override
  List<Object?> get props => [name];
}

class ProfileUsernameChanged extends ProfileEvent {
  final String username;
  const ProfileUsernameChanged(this.username);
  @override
  List<Object?> get props => [username];
}
