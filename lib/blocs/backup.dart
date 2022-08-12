import 'package:collection/collection.dart' show IterableExtension;
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
      : super(BackupProcessing()) {
    on<BackupCreate>(_mapBackupCreatetoState);
    on<BackupLoad>(_mapBackupLoadtoState);
  }

  Future<void> _mapBackupCreatetoState(
      BackupCreate event, Emitter<BackupState> emit) async {
    List<Transaction> transactions =
        await _transactionRepository.getAll(isUtc: true);
    List<List<dynamic>> rows = <List<dynamic>>[];

    // wallets' initial amounts
    for (Wallet wallet in await _walletRepository.getAll()) {
      if (wallet.amount! > 0)
        transactions.add(Transaction(
          id: 0,
          from: 0,
          to: wallet.id,
          amount: wallet.amount!,
          when: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
          description: 'Wallet initial balance',
        ));
    }
    for (Transaction transaction in transactions) {
      List<Object?> row = transaction.props;
      row[1] = await _getWalletName(row.elementAt(1) as int?);
      row[2] = await _getWalletName(row.elementAt(2) as int?);
      rows.add(row);
    }

    String csv = _csvRepository.listToCsv(rows);
    return emit(BackupComplete(csv));
  }

  Future<void> _mapBackupLoadtoState(
      BackupLoad event, Emitter<BackupState> emit) async {
    List<List<dynamic>> rows = _csvRepository.csvToList(event.csv);
    for (var row in rows) {
      if (_checkRow(row)) {
        Transaction transaction = await _mapRow(row);

        for (Tag tag in transaction.tags!) {
          if (await _tagRepository.get(tag.name) == null)
            await _tagRepository.add(tag);
        }
        await _transactionRepository.add(transaction);
      }
    }

    return emit(BackupLoaded(rows.length));
  }

  Future<Transaction> _mapRow(List<dynamic> row) async {
    // fix nulls
    for (var i = 0; i < row.length; i++) {
      if (row[i] == 'null') row[i] = null;
    }

    int from = await _getWalletId(row.elementAt(1));
    int to = await _getWalletId(row.elementAt(2));
    double amount = double.tryParse(row.elementAt(3).toString())!;
    DateTime when = DateTime.tryParse(row.elementAt(4))!;
    String? description = row.elementAt(6);

    List<Tag> tags = <Tag>[];
    String? tagString = (row.elementAt(5) as String?);
    if (tagString != null) {
      tagString = tagString.replaceAll(RegExp(r'\[|\]'), "");
      List<String> tagStringSplit = tagString.split(',');
      for (var i = 0; i < tagStringSplit.length; i = i + 2) {
        Tag tag = Tag(
            name: tagStringSplit[i],
            color: Color(int.parse(tagStringSplit[i + 1])));
        tags.add(tag);
      }
    }

    return Transaction(
      id: 0,
      from: from,
      to: to,
      amount: amount,
      when: when,
      tags: tags,
      description: description,
    );
  }

  Future<String?> _getWalletName(int? walletId) async {
    if (walletId == null) return null;
    Wallet? wallet = await _walletRepository.get(walletId);
    if (wallet == null) return null;
    return wallet.name;
  }

  Future<int> _getWalletId(String? walletName) async {
    if (walletName != null) {
      return (await _findWallet(walletName)).id;
    }
    return 0;
  }

  Future<Wallet> _findWallet(String walletName) async {
    List<Wallet> wallets = await _walletRepository.getAll();
    Wallet? foundWallet = wallets.firstWhereOrNull(
      (wallet) => wallet.name == walletName,
    );

    // add wallet if not found
    if (foundWallet == null) {
      int lastInsertId = await _walletRepository
          .add(Wallet(id: 0, name: walletName, curreny: 'TRY'));
      foundWallet = await _walletRepository.get(lastInsertId);
    }

    return foundWallet!;
  }

  bool _checkRow(List row) {
    if (row.length == 7) return true;
    return false;
  }
}
