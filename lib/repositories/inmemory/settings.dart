import 'package:collection/collection.dart' show IterableExtension;
import 'package:yababos/models/setting.dart';
import 'package:yababos/repositories/settings.dart';

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
  Future<Setting?> get(String name) {
    return Future(() {
      return _settings.firstWhereOrNull((element) => element.name == name);
    });
  }

  @override
  Future clear() {
    return Future(() {
      _settings.clear();
    });
  }
}
