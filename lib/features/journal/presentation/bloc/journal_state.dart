import 'package:equatable/equatable.dart';

enum JournalStatus { initial, loading, loaded, error }

class JournalState extends Equatable {
  final JournalStatus status;
  final int selectedTab; // 0 = SENT, 1 = RECEIVED
  final int totalSent;
  final int totalFriends;
  final int streakDays;
  final List<JournalEntry> sentEntries;
  final List<JournalEntry> receivedEntries;

  const JournalState({
    this.status = JournalStatus.initial,
    this.selectedTab = 0,
    this.totalSent = 0,
    this.totalFriends = 0,
    this.streakDays = 0,
    this.sentEntries = const [],
    this.receivedEntries = const [],
  });

  List<JournalEntry> get currentEntries =>
      selectedTab == 0 ? sentEntries : receivedEntries;

  JournalState copyWith({
    JournalStatus? status,
    int? selectedTab,
    int? totalSent,
    int? totalFriends,
    int? streakDays,
    List<JournalEntry>? sentEntries,
    List<JournalEntry>? receivedEntries,
  }) {
    return JournalState(
      status: status ?? this.status,
      selectedTab: selectedTab ?? this.selectedTab,
      totalSent: totalSent ?? this.totalSent,
      totalFriends: totalFriends ?? this.totalFriends,
      streakDays: streakDays ?? this.streakDays,
      sentEntries: sentEntries ?? this.sentEntries,
      receivedEntries: receivedEntries ?? this.receivedEntries,
    );
  }

  @override
  List<Object?> get props => [
        status,
        selectedTab,
        totalSent,
        totalFriends,
        streakDays,
        sentEntries,
        receivedEntries,
      ];
}

class JournalEntry extends Equatable {
  final String timeLabel;
  final String friendName;
  final String? caption;

  const JournalEntry({
    required this.timeLabel,
    required this.friendName,
    this.caption,
  });

  @override
  List<Object?> get props => [timeLabel, friendName, caption];
}
