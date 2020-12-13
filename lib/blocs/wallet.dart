import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yababos/blocs/settings.dart';
import 'package:yababos/events/wallet.dart';
import 'package:yababos/models/wallet.dart';
import 'package:yababos/models/wallet_repository.dart';
import 'package:yababos/states/settings.dart';
import 'package:yababos/states/wallet.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletRepository _walletRepository;
  final SettingsBloc _settingsBloc;
  Wallet _selectedWallet;

  WalletBloc(this._walletRepository, this._settingsBloc)
      : super(WalletLoading()) {
    _settingsBloc.listen((state) async {
      if (state is SettingChanged && state.setting.name == 'wallet') {
        _selectedWallet = await _walletRepository.get(state.setting.value);
        this.add(WalletGetAll());
      }
    });
  }

  @override
  Stream<WalletState> mapEventToState(WalletEvent event) async* {
    if (event is WalletAdd) {
      yield await _mapAddtoState(event);
    } else if (event is WalletDelete) {
      yield await _mapDeletetoState(event);
    } else if (event is WalletUpdate) {
      yield await _mapUpdatetoState(event);
    } else if (event is WalletGet) {
      yield await _mapGettoState(event);
    } else if (event is WalletGetAll) {
      yield await _mapGetAlltoState(event);
    }
  }

  Future<WalletState> _mapAddtoState(WalletAdd event) async {
    await _walletRepository.add(event.wallet);
    return WalletLoaded(
      wallets: await _walletRepository.getAll(),
      selectedWallet: _selectedWallet,
    );
  }

  Future<WalletState> _mapDeletetoState(WalletDelete event) async {
    await _walletRepository.delete(event.id);
    return WalletLoaded(
      wallets: await _walletRepository.getAll(),
      selectedWallet: _selectedWallet,
    );
  }

  Future<WalletState> _mapUpdatetoState(WalletUpdate event) async {
    await _walletRepository.update(event.wallet);
    return WalletLoaded(
      wallets: await _walletRepository.getAll(),
      selectedWallet: _selectedWallet,
    );
  }

  Future<WalletState> _mapGettoState(WalletGet event) async {
    return WalletLoaded.one(await _walletRepository.get(event.id));
  }

  _mapGetAlltoState(WalletGetAll event) async {
    return WalletLoaded(
      wallets: await _walletRepository.getAll(),
      selectedWallet: _selectedWallet,
    );
  }
}
