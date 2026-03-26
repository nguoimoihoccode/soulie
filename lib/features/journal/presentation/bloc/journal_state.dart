import 'package:equatable/equatable.dart';

enum JournalStatus { initial, loading, loaded, error }

class JournalState extends Equatable {
  final JournalStatus status;
  final int selectedTab; // 0 = SENT, 1 = RECEIVED
  final int totalSent;
  final int totalReceived;
  final int totalFriends;
  final int streakDays;
  final List<JournalEntry> sentEntries;
  final List<JournalEntry> receivedEntries;
  final String? errorMessage;

  const JournalState({
    this.status = JournalStatus.initial,
    this.selectedTab = 0,
    this.totalSent = 0,
    this.totalReceived = 0,
    this.totalFriends = 0,
    this.streakDays = 0,
    this.sentEntries = const [],
    this.receivedEntries = const [],
    this.errorMessage,
  });

  List<JournalEntry> get currentEntries =>
      selectedTab == 0 ? sentEntries : receivedEntries;

  JournalState copyWith({
    JournalStatus? status,
    int? selectedTab,
    int? totalSent,
    int? totalReceived,
    int? totalFriends,
    int? streakDays,
    List<JournalEntry>? sentEntries,
    List<JournalEntry>? receivedEntries,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return JournalState(
      status: status ?? this.status,
      selectedTab: selectedTab ?? this.selectedTab,
      totalSent: totalSent ?? this.totalSent,
      totalReceived: totalReceived ?? this.totalReceived,
      totalFriends: totalFriends ?? this.totalFriends,
      streakDays: streakDays ?? this.streakDays,
      sentEntries: sentEntries ?? this.sentEntries,
      receivedEntries: receivedEntries ?? this.receivedEntries,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        selectedTab,
        totalSent,
        totalReceived,
        totalFriends,
        streakDays,
        sentEntries,
        receivedEntries,
        errorMessage,
      ];
}

class JournalEntry extends Equatable {
  final String id;
  final String timeLabel;
  final String friendName;
  final String? caption;
  final String? imageUrl;

  const JournalEntry({
    required this.id,
    required this.timeLabel,
    required this.friendName,
    this.caption,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [id, timeLabel, friendName, caption, imageUrl];
}
