import 'package:collection/collection.dart' show IterableExtension;
import 'package:yababos/models/wallet.dart';
import 'package:yababos/repositories/wallet.dart';

class WalletInmemory extends WalletRepository {
  List<Wallet> _wallets = [];
  int _lastId = 0;

  @override
  Future<int> add(Wallet wallet) {
    return Future(() {
      _lastId = _lastId + 1;
      wallet.id = _lastId;
      _wallets.add(wallet);
      return _lastId;
    });
  }

  @override
  Future<List<Wallet>> getAll() {
    return Future(() => _wallets);
  }

  @override
  Future delete(int id) {
    return Future(() async {
      Wallet? wallet = await get(id);
      _wallets.remove(wallet);
    });
  }

  @override
  Future<Wallet?> get(int id) {
    return Future(() {
      return _wallets.firstWhereOrNull(
        (element) => element.id == id,
      );
    });
  }

  @override
  Future update(Wallet wallet) {
    return Future(() {
      _wallets[_wallets.indexWhere((element) => element.id == wallet.id)] =
          wallet;
    });
  }

  @override
  Future clear() {
    return Future(() {
      _wallets.clear();
      _lastId = 0;
    });
  }
}
