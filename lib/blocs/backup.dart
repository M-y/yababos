import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yababos/events/backup.dart';
import 'package:yababos/models/tag.dart';
import 'package:yababos/models/transaction.dart';
import 'package:yababos/models/wallet.dart';
import 'package:yababos/repositories/csv.dart';
import 'package:yababos/repositories/tag.dart';
import 'package:yababos/repositories/transaction.dart';
import 'package:yababos/repositories/wallet.dart';
import 'package:yababos/states/backup.dart';

class BackupBloc extends Bloc<BackupEvent, BackupState> {
  final TagRepository _tagRepository;
  final TransactionRepository _transactionRepository;
  final WalletRepository _walletRepository;
  final CsvRepository _csvRepository;

  BackupBloc(this._csvRepository, this._tagRepository,
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
      List<Object> row = transaction.props;
      row[1] = await _getWalletName(row.elementAt(1));
      row[2] = await _getWalletName(row.elementAt(2));
      rows.add(row);
    }

    String csv = _csvRepository.listToCsv(rows);
    return BackupComplete(csv);
  }

  Future<BackupState> _mapBackupLoadtoState(BackupLoad event) async {
    List<List<dynamic>> rows = _csvRepository.csvToList(event.csv);
    for (var row in rows) {
      Transaction transaction = await _mapRow(row);

      for (Tag tag in transaction.tags) {
        if (await _tagRepository.get(tag.name) == null)
          await _tagRepository.add(tag);
      }
      await _transactionRepository.add(transaction);
    }

    return BackupLoaded(rows.length);
  }

  Future<Transaction> _mapRow(List<dynamic> row) async {
    int from = await _getWalletId(row.elementAt(1));
    int to = await _getWalletId(row.elementAt(2));
    double amount = double.tryParse(row.elementAt(3).toString());
    DateTime when = DateTime.tryParse(row.elementAt(4));
    String description = row.elementAt(6);

    List<Tag> tags = List<Tag>();
    String s = row.elementAt(5).toString().replaceAll(RegExp(r'\[|\]'), "");
    List<String> s2 = s.split(',');
    for (var i = 0; i < s2.length; i = i + 2) {
      Tag tag = Tag(name: s2[i], color: Color(int.parse(s2[i + 1])));
      tags.add(tag);
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

  Future<String> _getWalletName(int walletId) async {
    Wallet wallet = await _walletRepository.get(walletId);
    if (wallet == null) return null;
    return wallet.name;
  }

  Future<int> _getWalletId(String walletName) async {
    if (walletName != null) {
      return (await _findWallet(walletName)).id;
    }
    return null;
  }

  Future<Wallet> _findWallet(String walletName) async {
    List<Wallet> wallets = await _walletRepository.getAll();
    Wallet foundWallet = wallets.firstWhere(
      (wallet) => wallet.name == walletName,
      orElse: () => null,
    );

    // add wallet if not found
    if (foundWallet == null) {
      int lastInsertId =
          await _walletRepository.add(Wallet(id: null, name: walletName));
      foundWallet = await _walletRepository.get(lastInsertId);
    }

    return foundWallet;
  }
}