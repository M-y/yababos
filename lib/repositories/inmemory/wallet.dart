import 'package:yababos/models/wallet.dart';
import 'package:yababos/repositories/wallet_repository.dart';

class WalletInmemory extends WalletRepository {
  List<Wallet> _wallets = [];

  @override
  Future add(Wallet wallet) {
    return Future(() {
      wallet.id = _wallets.length + 1;
      _wallets.add(wallet);
    });
  }

  @override
  Future<List<Wallet>> getAll() {
    return Future(() => _wallets);
  }

  @override
  Future delete(int id) {
    return Future(() async {
      Wallet wallet = await get(id);
      _wallets.remove(wallet);
    });
  }

  @override
  Future<Wallet> get(int id) {
    return Future(() {
      return _wallets.firstWhere((element) => element.id == id);
    });
  }

  @override
  Future update(Wallet wallet) {
    return Future(() {
      _wallets[_wallets.indexWhere((element) => element.id == wallet.id)] =
          wallet;
    });
  }
}
