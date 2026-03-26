import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const AuthState()) {
    on<AuthCheckRequested>(_onCheck);
    on<AuthLoginRequested>(_onLogin);
    on<AuthRegisterRequested>(_onRegister);
    on<AuthGoogleLoginRequested>(_onGoogleLogin);
    on<AuthAppleLoginRequested>(_onAppleLogin);
    on<AuthLogoutRequested>(_onLogout);
  }

  final AuthRepository _authRepository;

  Future<void> _onCheck(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearErrorMessage: true));

    try {
      final user = await _authRepository.restoreSession();

      if (user == null) {
        emit(const AuthState(status: AuthStatus.unauthenticated));
        return;
      }

      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          displayName: user.displayName,
          email: user.email,
          clearErrorMessage: true,
        ),
      );
    } on AuthException catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: error.message,
          clearUserInfo: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Đã xảy ra lỗi khi kiểm tra phiên đăng nhập',
          clearUserInfo: true,
        ),
      );
    }
  }

  Future<void> _onLogin(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (event.email.isEmpty || event.password.isEmpty) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Vui lòng nhập email và mật khẩu',
          clearUserInfo: true,
        ),
      );
      return;
    }

    emit(state.copyWith(status: AuthStatus.loading, clearErrorMessage: true));

    try {
      final user = await _authRepository.login(
        email: event.email,
        password: event.password,
      );

      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          displayName: user.displayName,
          email: user.email,
          clearErrorMessage: true,
        ),
      );
    } on AuthException catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: error.message,
          clearUserInfo: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Đăng nhập thất bại. Vui lòng thử lại.',
          clearUserInfo: true,
        ),
      );
    }
  }

  Future<void> _onGoogleLogin(
    AuthGoogleLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        status: AuthStatus.error,
        errorMessage:
            'Tính năng đăng nhập Google chưa được bật cho backend hiện tại',
        clearUserInfo: true,
      ),
    );
  }

  Future<void> _onAppleLogin(
    AuthAppleLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        status: AuthStatus.error,
        errorMessage:
            'Tính năng đăng nhập Apple chưa được bật cho backend hiện tại',
        clearUserInfo: true,
      ),
    );
  }

  Future<void> _onRegister(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (event.email.isEmpty || event.password.isEmpty) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Vui lòng nhập email và mật khẩu',
          clearUserInfo: true,
        ),
      );
      return;
    }

    emit(state.copyWith(status: AuthStatus.loading, clearErrorMessage: true));

    try {
      final user = await _authRepository.register(
        email: event.email,
        password: event.password,
      );

      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          displayName: user.displayName,
          email: user.email,
          clearErrorMessage: true,
        ),
      );
    } on AuthException catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: error.message,
          clearUserInfo: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Đăng ký thất bại. Vui lòng thử lại.',
          clearUserInfo: true,
        ),
      );
    }
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authRepository.logout();
    } finally {
      emit(const AuthState(status: AuthStatus.unauthenticated));
    }
  }
}
