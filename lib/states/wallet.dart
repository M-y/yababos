import 'package:yababos/models/wallet.dart';

abstract class WalletState {
  const WalletState();
}

class WalletLoading extends WalletState {}

class WalletLoaded extends WalletState {
  Wallet wallet;
  List<Wallet> wallets;

  WalletLoaded(this.wallets);
  WalletLoaded.one(this.wallet);
}
