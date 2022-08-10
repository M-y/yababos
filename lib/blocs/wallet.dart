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
    // TODO avoid tight-coupling
    // listen SettingsBloc for selected wallet change
    _settingsBloc.stream.listen((state) async {
      if (state is SettingChanged && state.setting.name == 'wallet')
        await _loadSelectedWallet(state.setting.value);
      if (state is SettingLoaded && state.setting.name == 'wallet')
        await _loadSelectedWallet(state.setting.value);
    });

    on<WalletAdd>(_mapAddtoState);
    on<WalletDelete>(_mapDeletetoState);
    on<WalletUpdate>(_mapUpdatetoState);
    on<WalletGet>(_mapGettoState);
    on<WalletGetAll>(_mapGetAlltoState);
    on<WalletGetNone>(_mapGetNonetoState);
  }

  Future _loadSelectedWallet(Object value) async {
    _selectedWallet = await _walletRepository.get(value);
    if (_selectedWallet != null) {
      if (!this.isClosed) this.add(WalletGetAll());
      _transactionBloc.add(TransactionGetWallet(
          _selectedWallet.id, DateTime.now().year, DateTime.now().month));
    }
  }

  Future<void> _mapAddtoState(
      WalletAdd event, Emitter<WalletState> emit) async {
    await _walletRepository.add(event.wallet);
    await _selectedWalletFix();
    emit(WalletsLoaded(
      wallets: await _walletRepository.getAll(),
      selectedWallet: _selectedWallet,
    ));
  }

  Future<void> _mapDeletetoState(
      WalletDelete event, Emitter<WalletState> emit) async {
    await _walletRepository.delete(event.id);
    await _selectedWalletFix();
    emit(WalletsLoaded(
      wallets: await _walletRepository.getAll(),
      selectedWallet: _selectedWallet,
    ));
  }

  Future<void> _mapUpdatetoState(
      WalletUpdate event, Emitter<WalletState> emit) async {
    await _walletRepository.update(event.wallet);
    emit(WalletsLoaded(
      wallets: await _walletRepository.getAll(),
      selectedWallet: _selectedWallet,
    ));
  }

  Future<void> _mapGettoState(
      WalletGet event, Emitter<WalletState> emit) async {
    emit(WalletLoaded(await _walletRepository.get(event.id)));
  }

  Future<void> _mapGetAlltoState(
      WalletGetAll event, Emitter<WalletState> emit) async {
    emit(WalletsLoaded(
      wallets: await _walletRepository.getAll(),
      selectedWallet: _selectedWallet,
    ));
  }

  Future<void> _mapGetNonetoState(
      WalletGetNone event, Emitter<WalletState> emit) async {
    emit(WalletsLoaded(wallets: <Wallet>[], selectedWallet: null));
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
