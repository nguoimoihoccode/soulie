import 'package:equatable/equatable.dart';

enum AuthStatus { unknown, authenticated, unauthenticated, loading, error }

class AuthState extends Equatable {
  final AuthStatus status;
  final String? errorMessage;
  final String? displayName;
  final String? email;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.errorMessage,
    this.displayName,
    this.email,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    String? displayName,
    String? email,
    bool clearErrorMessage = false,
    bool clearUserInfo = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      displayName: clearUserInfo ? null : (displayName ?? this.displayName),
      email: clearUserInfo ? null : (email ?? this.email),
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, displayName, email];
}
