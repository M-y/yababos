import 'package:equatable/equatable.dart';
import 'package:yababos/models/wallet.dart';

abstract class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object> get props => [];
}

class WalletLoading extends WalletState {}

class WalletLoaded extends WalletState {
  Wallet wallet;

  WalletLoaded(this.wallet);

  @override
  List<Object> get props => [wallet];
}

class WalletsLoaded extends WalletState {
  Wallet selectedWallet;
  List<Wallet> wallets;

  WalletsLoaded({this.wallets, this.selectedWallet});

  @override
  List<Object> get props => [wallets, selectedWallet];
}
