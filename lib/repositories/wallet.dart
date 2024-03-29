import 'package:yababos/models/wallet.dart';

abstract class WalletRepository {
  Future<List<Wallet>> getAll();
  Future<Wallet?> get(int id);

  Future<int> add(Wallet wallet);
  Future update(Wallet wallet);
  Future delete(int id);

  Future clear();
}
