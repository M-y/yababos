import 'package:yababos/models/wallet.dart';

abstract class WalletRepository {
  Future<List<Wallet>> getAll();
  Future<Wallet> get(int id);

  Future add(Wallet transaction);
  Future update(Wallet transaction);
  Future delete(int id);
}
