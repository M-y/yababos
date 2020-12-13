import 'package:yababos/models/wallet.dart';

abstract class WalletState {
  const WalletState();
}

class WalletLoading extends WalletState {}

class WalletLoaded extends WalletState {
  Wallet wallet;
  Wallet selectedWallet;
  List<Wallet> wallets;

  WalletLoaded({this.wallets, this.selectedWallet}) {
    if (wallets.length > 0 && selectedWallet == null)
      selectedWallet = wallets[wallets.length - 1];
  }
  WalletLoaded.one(this.wallet);
}
