import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthState()) {
    on<AuthCheckRequested>(_onCheck);
    on<AuthLoginRequested>(_onLogin);
    on<AuthGoogleLoginRequested>(_onGoogleLogin);
    on<AuthAppleLoginRequested>(_onAppleLogin);
    on<AuthLogoutRequested>(_onLogout);
  }

  Future<void> _onCheck(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Check saved auth - for now always unauthenticated
    await Future.delayed(const Duration(milliseconds: 500));
    emit(state.copyWith(status: AuthStatus.unauthenticated));
  }

  Future<void> _onLogin(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    await Future.delayed(const Duration(milliseconds: 1200));

    if (event.email.isNotEmpty && event.password.isNotEmpty) {
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        userName: event.email.split('@').first,
      ));
    } else {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Please enter email and password',
      ));
    }
  }

  Future<void> _onGoogleLogin(
    AuthGoogleLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    await Future.delayed(const Duration(milliseconds: 1000));
    emit(state.copyWith(
      status: AuthStatus.authenticated,
      userName: 'Alex Rivera',
    ));
  }

  Future<void> _onAppleLogin(
    AuthAppleLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    await Future.delayed(const Duration(milliseconds: 1000));
    emit(state.copyWith(
      status: AuthStatus.authenticated,
      userName: 'Alex Rivera',
    ));
  }

  void _onLogout(AuthLogoutRequested event, Emitter<AuthState> emit) {
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
