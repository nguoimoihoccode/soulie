import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../soulie/data/soulie_repository.dart';
import 'journal_event.dart';
import 'journal_state.dart';

class JournalBloc extends Bloc<JournalEvent, JournalState> {
  JournalBloc({required SoulieRepository soulieRepository})
    : _soulieRepository = soulieRepository,
      super(const JournalState()) {
    on<JournalLoadRequested>(_onLoad);
    on<JournalTabChanged>(_onTabChanged);
  }

  final SoulieRepository _soulieRepository;

  Future<void> _onLoad(
    JournalLoadRequested event,
    Emitter<JournalState> emit,
  ) async {
    emit(state.copyWith(status: JournalStatus.loading));

    try {
      final journal = await _soulieRepository.fetchJournal();
      emit(state.copyWith(
        status: JournalStatus.loaded,
        totalSent: journal.totalSent,
        totalReceived: journal.totalReceived,
        totalFriends: journal.totalFriends,
        streakDays: journal.streakDays,
        sentEntries: journal.sentEntries
            .map(
              (entry) => JournalEntry(
                id: entry.id,
                timeLabel: entry.timeLabel,
                friendName: entry.friendName,
                caption: entry.caption,
                imageUrl: entry.imageUrl,
              ),
            )
            .toList(growable: false),
        receivedEntries: journal.receivedEntries
            .map(
              (entry) => JournalEntry(
                id: entry.id,
                timeLabel: entry.timeLabel,
                friendName: entry.friendName,
                caption: entry.caption,
                imageUrl: entry.imageUrl,
              ),
            )
            .toList(growable: false),
        clearErrorMessage: true,
      ));
    } on SoulieRepositoryException catch (error) {
      emit(state.copyWith(
        status: JournalStatus.error,
        errorMessage: error.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: JournalStatus.error,
        errorMessage: 'Không thể tải lịch sử',
      ));
    }
  }

  void _onTabChanged(JournalTabChanged event, Emitter<JournalState> emit) {
    emit(state.copyWith(selectedTab: event.tabIndex));
  }
}
