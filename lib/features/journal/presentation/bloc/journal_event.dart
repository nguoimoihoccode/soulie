import 'package:equatable/equatable.dart';

abstract class JournalEvent extends Equatable {
  const JournalEvent();
  @override
  List<Object?> get props => [];
}

class JournalLoadRequested extends JournalEvent {
  const JournalLoadRequested();
}

class JournalTabChanged extends JournalEvent {
  final int tabIndex;
  const JournalTabChanged(this.tabIndex);
  @override
  List<Object?> get props => [tabIndex];
}
