import 'package:equatable/equatable.dart';

abstract class BackupState extends Equatable {
  const BackupState();

  @override
  List<Object> get props => [];
}

class BackupProcessing extends BackupState {}

class BackupComplete extends BackupState {
  final String csv;

  const BackupComplete(this.csv);

  @override
  List<Object> get props => [csv];
}

class BackupLoaded extends BackupState {
  final int count;

  const BackupLoaded(this.count);

  @override
  List<Object> get props => [count];
}
