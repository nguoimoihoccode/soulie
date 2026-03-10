import 'package:equatable/equatable.dart';

enum ProfileStatus { initial, loading, loaded, error }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final String displayName;
  final String username;
  final int totalSent;
  final int totalReceived;
  final int friendCount;
  final int streakDays;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.displayName = '',
    this.username = '',
    this.totalSent = 0,
    this.totalReceived = 0,
    this.friendCount = 0,
    this.streakDays = 0,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    String? displayName,
    String? username,
    int? totalSent,
    int? totalReceived,
    int? friendCount,
    int? streakDays,
  }) {
    return ProfileState(
      status: status ?? this.status,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      totalSent: totalSent ?? this.totalSent,
      totalReceived: totalReceived ?? this.totalReceived,
      friendCount: friendCount ?? this.friendCount,
      streakDays: streakDays ?? this.streakDays,
    );
  }

  @override
  List<Object?> get props =>
      [status, displayName, username, totalSent, totalReceived, friendCount, streakDays];
}
