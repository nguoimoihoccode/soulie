import 'package:flutter_bloc/flutter_bloc.dart';
import 'journal_event.dart';
import 'journal_state.dart';

class JournalBloc extends Bloc<JournalEvent, JournalState> {
  JournalBloc() : super(const JournalState()) {
    on<JournalLoadRequested>(_onLoad);
    on<JournalTabChanged>(_onTabChanged);
  }

  Future<void> _onLoad(
    JournalLoadRequested event,
    Emitter<JournalState> emit,
  ) async {
    emit(state.copyWith(status: JournalStatus.loading));
    await Future.delayed(const Duration(milliseconds: 600));
    emit(state.copyWith(
      status: JournalStatus.loaded,
      totalSent: 1284,
      totalFriends: 42,
      streakDays: 15,
      sentEntries: _mockSent,
      receivedEntries: _mockReceived,
    ));
  }

  void _onTabChanged(JournalTabChanged event, Emitter<JournalState> emit) {
    emit(state.copyWith(selectedTab: event.tabIndex));
  }

  static const List<JournalEntry> _mockSent = [
    JournalEntry(timeLabel: 'TODAY, 2:45 PM', friendName: 'Sarah Chen'),
    JournalEntry(timeLabel: 'TODAY, 11:12 AM', friendName: 'Alex Rivera'),
    JournalEntry(timeLabel: 'YESTERDAY', friendName: 'Luna Skye', caption: 'Beautiful sunset! 🌅'),
    JournalEntry(timeLabel: 'YESTERDAY', friendName: 'Marcus V.'),
    JournalEntry(timeLabel: '2 DAYS AGO', friendName: 'Jordan Day'),
    JournalEntry(timeLabel: '2 DAYS AGO', friendName: 'Chris Kim', caption: 'Coffee time ☕'),
  ];

  static const List<JournalEntry> _mockReceived = [
    JournalEntry(timeLabel: 'TODAY, 3:10 PM', friendName: 'Sarah Chen', caption: 'Miss you! 💕'),
    JournalEntry(timeLabel: 'TODAY, 12:30 PM', friendName: 'Marcus V.'),
    JournalEntry(timeLabel: 'YESTERDAY', friendName: 'Elena Rose'),
    JournalEntry(timeLabel: 'YESTERDAY', friendName: 'Mike T.', caption: 'Check this out!'),
    JournalEntry(timeLabel: '3 DAYS AGO', friendName: 'Riley Cooper'),
  ];
}
