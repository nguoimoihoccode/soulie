import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(const ProfileState()) {
    on<ProfileLoadRequested>(_onLoad);
    on<ProfileNameChanged>(_onNameChanged);
    on<ProfileUsernameChanged>(_onUsernameChanged);
  }

  Future<void> _onLoad(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    await Future.delayed(const Duration(milliseconds: 400));
    emit(state.copyWith(
      status: ProfileStatus.loaded,
      displayName: 'Alex Rivera',
      username: '@arivera',
      totalSent: 1284,
      totalReceived: 956,
      friendCount: 42,
      streakDays: 15,
    ));
  }

  void _onNameChanged(ProfileNameChanged event, Emitter<ProfileState> emit) {
    emit(state.copyWith(displayName: event.name));
  }

  void _onUsernameChanged(
      ProfileUsernameChanged event, Emitter<ProfileState> emit) {
    emit(state.copyWith(username: event.username));
  }
}
