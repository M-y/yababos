abstract class BackupEvent {
  const BackupEvent();
}

class BackupCreate extends BackupEvent {}

class BackupLoad extends BackupEvent {
  final String csv;

  const BackupLoad(this.csv);
}
