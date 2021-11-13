import 'dart:convert';

import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yababos/events/backup.dart';
import 'package:yababos/models/tag.dart';
import 'package:yababos/models/transaction.dart';
import 'package:yababos/repositories/csv.dart';
import 'package:yababos/repositories/settings.dart';
import 'package:yababos/repositories/tag.dart';
import 'package:yababos/repositories/transaction.dart';
import 'package:yababos/repositories/wallet.dart';
import 'package:yababos/states/backup.dart';

class BackupBloc extends Bloc<BackupEvent, BackupState> {
  final SettingsRepository _settingsRepository;
  final TagRepository _tagRepository;
  final TransactionRepository _transactionRepository;
  final WalletRepository _walletRepository;
  final CsvRepository _csvRepository;

  BackupBloc(this._csvRepository, this._settingsRepository, this._tagRepository,
      this._transactionRepository, this._walletRepository)
      : super(BackupProcessing());

  @override
  Stream<BackupState> mapEventToState(BackupEvent event) async* {
    if (event is BackupCreate) {
      yield await _mapBackupCreatetoState(event);
    } else if (event is BackupLoad) {
      yield await _mapBackupLoadtoState(event);
    }
  }

  Future<BackupState> _mapBackupCreatetoState(BackupCreate event) async {
    List<Transaction> transactions = await _transactionRepository.getAll();
    List<List<dynamic>> rows = List<List<dynamic>>();
    for (Transaction transaction in transactions) {
      rows.add(transaction.props);
    }

    String csv = _csvRepository.listToCsv(rows);
    return BackupComplete(csv);
  }

  Future<BackupState> _mapBackupLoadtoState(BackupLoad event) async {
    List<List<dynamic>> rows = _csvRepository.csvToList(event.csv);
    for (var row in rows) {
      await _transactionRepository.add(_mapRow(row));
    }

    return BackupLoaded(rows.length);
  }

  Transaction _mapRow(List<dynamic> row) {
    int from = int.tryParse(row.elementAt(1).toString());
    int to = int.tryParse(row.elementAt(2).toString());
    double amount = double.tryParse(row.elementAt(3).toString());
    DateTime when = DateTime.tryParse(row.elementAt(4));
    String description = row.elementAt(6);

    List<Tag> tags = List<Tag>();
    String s = row.elementAt(5).toString().replaceAll(RegExp(r'\[|\]'), "");
    List<String> s2 = s.split(',');
    for (var i = 0; i < s2.length; i = i + 2) {
      tags.add(Tag(name: s2[i], color: Color(int.parse(s2[i + 1]))));
    }

    return Transaction(
      id: null,
      from: from,
      to: to,
      amount: amount,
      when: when,
      tags: tags,
      description: description,
    );
  }
}
