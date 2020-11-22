import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yababos/events/wallet.dart';
import 'package:yababos/models/wallet_repository.dart';
import 'package:yababos/states/wallet.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletRepository _walletRepository;

  WalletBloc(this._walletRepository) : super(WalletLoading());

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
    _walletRepository.add(event.wallet);
    return WalletLoaded(await _walletRepository.getAll());
  }

  Future<WalletState> _mapDeletetoState(WalletDelete event) async {
    _walletRepository.delete(event.id);
    return WalletLoaded(await _walletRepository.getAll());
  }

  Future<WalletState> _mapUpdatetoState(WalletUpdate event) async {
    _walletRepository.update(event.wallet);
    return WalletLoaded(await _walletRepository.getAll());
  }

  Future<WalletState> _mapGettoState(WalletGet event) async {
    return WalletLoaded.one(await _walletRepository.get(event.id));
  }

  _mapGetAlltoState(WalletGetAll event) async {
    return WalletLoaded(await _walletRepository.getAll());
  }
}
