import 'package:equatable/equatable.dart';

enum ProfileStatus { initial, loading, loaded, error }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final String id;
  final String email;
  final String displayName;
  final String username;
  final String avatarUrl;
  final int totalSent;
  final int totalReceived;
  final int friendCount;
  final int streakDays;
  final String? errorMessage;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.id = '',
    this.email = '',
    this.displayName = '',
    this.username = '',
    this.avatarUrl = '',
    this.totalSent = 0,
    this.totalReceived = 0,
    this.friendCount = 0,
    this.streakDays = 0,
    this.errorMessage,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    String? id,
    String? email,
    String? displayName,
    String? username,
    String? avatarUrl,
    int? totalSent,
    int? totalReceived,
    int? friendCount,
    int? streakDays,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return ProfileState(
      status: status ?? this.status,
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      totalSent: totalSent ?? this.totalSent,
      totalReceived: totalReceived ?? this.totalReceived,
      friendCount: friendCount ?? this.friendCount,
      streakDays: streakDays ?? this.streakDays,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props =>
      [
        status,
        id,
        email,
        displayName,
        username,
        avatarUrl,
        totalSent,
        totalReceived,
        friendCount,
        streakDays,
        errorMessage,
      ];
}
