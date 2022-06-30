import 'package:yababos/models/tag.dart';
import 'package:yababos/models/transaction.dart';
import 'package:yababos/models/wallet.dart';
import 'package:yababos/repositories/tag.dart';
import 'package:yababos/repositories/transaction.dart';
import 'package:yababos/repositories/wallet.dart';

Future sampleDatabase(
    WalletRepository walletRepository,
    TagRepository tagRepository,
    TransactionRepository transactionRepository) async {
  await tagRepository.clear();
  await transactionRepository.clear();
  await walletRepository.clear();

  Wallet wallet1 =
      Wallet(id: null, name: 'Wallet 1', curreny: 'TRY', amount: 1);
  Wallet wallet2 =
      Wallet(id: null, name: 'Wallet 2', curreny: 'TRY', amount: 10);
  await walletRepository.add(wallet1);
  await walletRepository.add(wallet2);

  List<Transaction> transactions = List.from([
    Transaction(
      id: 1,
      from: 1,
      to: null,
      amount: 100,
      when: DateTime.fromMillisecondsSinceEpoch(1637406526000, isUtc: true),
      description: 'transaction with tags',
      tags: [Tag(name: 't1'), Tag(name: 't2')],
    ),
    Transaction(
      id: 2,
      from: 2,
      to: 1,
      amount: 10,
      when: DateTime.fromMillisecondsSinceEpoch(1637366943000, isUtc: true),
      description: 'transaction from wallet2 to wallet1',
    )
  ]);

  for (Transaction transaction in transactions) {
    if (transaction.tags != null)
      for (Tag tag in transaction.tags) {
        if (await tagRepository.get(tag.name) == null)
          await tagRepository.add(tag);
      }
    await transactionRepository.add(transaction);
  }
}
