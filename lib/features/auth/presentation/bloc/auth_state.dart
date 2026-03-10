import 'package:equatable/equatable.dart';

enum AuthStatus { unknown, authenticated, unauthenticated, loading, error }

class AuthState extends Equatable {
  final AuthStatus status;
  final String? errorMessage;
  final String? userName;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.errorMessage,
    this.userName,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    String? userName,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      userName: userName ?? this.userName,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, userName];
}
