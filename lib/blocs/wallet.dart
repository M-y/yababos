import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yababos/blocs/settings.dart';
import 'package:yababos/blocs/transaction.dart';
import 'package:yababos/events/settings.dart';
import 'package:yababos/events/transaction.dart';
import 'package:yababos/events/wallet.dart';
import 'package:yababos/models/setting.dart';
import 'package:yababos/models/wallet.dart';
import 'package:yababos/repositories/wallet.dart';
import 'package:yababos/states/settings.dart';
import 'package:yababos/states/wallet.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletRepository _walletRepository;
  final SettingsBloc _settingsBloc;
  final TransactionBloc _transactionBloc;
  Wallet _selectedWallet;

  WalletBloc(this._walletRepository, this._settingsBloc, this._transactionBloc)
      : super(WalletLoading()) {
    // listen SettingsBloc for selected wallet change
    _settingsBloc.listen((state) async {
      if (state is SettingChanged && state.setting.name == 'wallet')
        await _loadSelectedWallet(state.setting.value);
      if (state is SettingLoaded && state.setting.name == 'wallet')
        await _loadSelectedWallet(state.setting.value);
    });
  }

  Future _loadSelectedWallet(Object value) async {
    _selectedWallet = await _walletRepository.get(value);
    if (_selectedWallet != null) {
      this.add(WalletGetAll());
      _transactionBloc.add(TransactionGetWallet(_selectedWallet.id));
    }
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
    } else if (event is WalletGetNone) {
      yield await _mapGetNonetoState(event);
    }
  }

  Future<WalletState> _mapAddtoState(WalletAdd event) async {
    await _walletRepository.add(event.wallet);
    await _selectedWalletFix();
    return WalletsLoaded(
      wallets: await _walletRepository.getAll(),
      selectedWallet: _selectedWallet,
    );
  }

  Future<WalletState> _mapDeletetoState(WalletDelete event) async {
    await _walletRepository.delete(event.id);
    await _selectedWalletFix();
    return WalletsLoaded(
      wallets: await _walletRepository.getAll(),
      selectedWallet: _selectedWallet,
    );
  }

  Future<WalletState> _mapUpdatetoState(WalletUpdate event) async {
    await _walletRepository.update(event.wallet);
    return WalletsLoaded(
      wallets: await _walletRepository.getAll(),
      selectedWallet: _selectedWallet,
    );
  }

  Future<WalletState> _mapGettoState(WalletGet event) async {
    return WalletLoaded(await _walletRepository.get(event.id));
  }

  Future<WalletState> _mapGetAlltoState(WalletGetAll event) async {
    return WalletsLoaded(
      wallets: await _walletRepository.getAll(),
      selectedWallet: _selectedWallet,
    );
  }

  Future<WalletState> _mapGetNonetoState(WalletGetNone event) async {
    return WalletsLoaded(wallets: List<Wallet>(), selectedWallet: null);
  }

  Future _selectedWalletFix() async {
    List<Wallet> wallets = await _walletRepository.getAll();

    // select the only wallet
    if (wallets.length == 1) {
      _selectFirstWallet(wallets);
    } else {
      // check if selected wallet still exists
      if (_selectedWallet != null &&
          await _walletRepository.get(_selectedWallet.id) == null)
        _selectFirstWallet(wallets);
    }
  }

  void _selectFirstWallet(List<Wallet> wallets) {
    _selectedWallet = wallets[0];
    _settingsBloc.add(SettingAdd(Setting(
      name: 'wallet',
      value: _selectedWallet.id,
    )));
  }
}
