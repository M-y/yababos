import 'package:yababos/models/wallet.dart';

abstract class WalletEvent {
  const WalletEvent();
}

class WalletAdd extends WalletEvent {
  final Wallet wallet;

  const WalletAdd(this.wallet);
}

class WalletUpdate extends WalletEvent {
  final Wallet wallet;

  const WalletUpdate(this.wallet);
}

class WalletGet extends WalletEvent {
  final int id;

  const WalletGet(this.id);
}

class WalletGetAll extends WalletEvent {}

class WalletDelete extends WalletEvent {
  final int id;

  const WalletDelete(this.id);
}
