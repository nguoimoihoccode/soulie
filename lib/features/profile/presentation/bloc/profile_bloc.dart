import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../soulie/data/soulie_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({required SoulieRepository soulieRepository})
    : _soulieRepository = soulieRepository,
      super(const ProfileState()) {
    on<ProfileLoadRequested>(_onLoad);
    on<ProfileNameChanged>(_onNameChanged);
    on<ProfileUsernameChanged>(_onUsernameChanged);
  }

  final SoulieRepository _soulieRepository;

  Future<void> _onLoad(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));

    try {
      final profile = await _soulieRepository.fetchProfile();
      emit(state.copyWith(
        status: ProfileStatus.loaded,
        id: profile.id,
        email: profile.email,
        displayName: profile.displayName,
        username: profile.username,
        avatarUrl: profile.avatarUrl,
        totalSent: profile.totalSent,
        totalReceived: profile.totalReceived,
        friendCount: profile.friendCount,
        streakDays: profile.streakDays,
        clearErrorMessage: true,
      ));
    } on SoulieRepositoryException catch (error) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: error.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: 'Không thể tải hồ sơ',
      ));
    }
  }

  void _onNameChanged(ProfileNameChanged event, Emitter<ProfileState> emit) {
    emit(state.copyWith(displayName: event.name));
  }

  void _onUsernameChanged(
      ProfileUsernameChanged event, Emitter<ProfileState> emit) {
    emit(state.copyWith(username: event.username));
  }
}
