import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yababos/events/settings.dart';
import 'package:yababos/models/setting.dart';
import 'package:yababos/repositories/settings_repository.dart';
import 'package:yababos/states/settings.dart';

class SettingsBloc extends Bloc<SettingEvent, SettingState> {
  final SettingsRepository _settingsRepository;

  SettingsBloc(this._settingsRepository) : super(SettingsLoading());

  @override
  Stream<SettingState> mapEventToState(SettingEvent event) async* {
    if (event is SettingAdd) {
      yield await _mapAddtoState(event);
    } else if (event is SettingGet) {
      yield await _mapGettoState(event);
    }
  }

  Future<SettingState> _mapAddtoState(SettingAdd event) async {
    Setting oldSetting = await _settingsRepository.get(event.setting.name);
    await _settingsRepository.add(event.setting);
    if (oldSetting == null || oldSetting.value != event.setting.value)
      return SettingChanged(event.setting);
    return SettingLoaded(event.setting);
  }

  Future<SettingState> _mapGettoState(SettingGet event) async {
    Setting setting = await _settingsRepository.get(event.name);
    return SettingLoaded(setting);
  }
}
