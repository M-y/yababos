import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yababos/events/settings.dart';
import 'package:yababos/models/setting.dart';
import 'package:yababos/repositories/settings.dart';
import 'package:yababos/states/settings.dart';

class SettingsBloc extends Bloc<SettingEvent, SettingState> {
  final SettingsRepository _settingsRepository;

  SettingsBloc(this._settingsRepository) : super(SettingsLoading()) {
    on<SettingAdd>(_mapAddtoState);
    on<SettingGet>(_mapGettoState);
  }

  Future<void> _mapAddtoState(
      SettingAdd event, Emitter<SettingState> emit) async {
    Setting? oldSetting = await _settingsRepository.get(event.setting.name);
    await _settingsRepository.add(event.setting);
    if (oldSetting == null || oldSetting.value != event.setting.value)
      return emit(SettingChanged(event.setting));
    return emit(SettingLoaded(event.setting));
  }

  Future<void> _mapGettoState(
      SettingGet event, Emitter<SettingState> emit) async {
    Setting? setting = await _settingsRepository.get(event.name);
    return emit(SettingLoaded(setting));
  }
}
