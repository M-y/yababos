import 'package:yababos/models/setting.dart';
import 'package:yababos/models/settings_repository.dart';

class SettingsInmemory extends SettingsRepository {
  List<Setting> _settings = [];

  @override
  Future add(Setting setting) {
    return Future(() async {
      if (await get(setting.name) == null) {
        _settings.add(setting);
      } else {
        _settings[_settings
            .indexWhere((element) => element.name == setting.name)] = setting;
      }
    });
  }

  @override
  Future<Setting> get(String name) {
    return Future(() {
      return _settings.firstWhere((element) => element.name == name,
          orElse: () => null);
    });
  }
}
