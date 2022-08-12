import 'package:yababos/models/setting.dart';

abstract class SettingsRepository {
  Future<Setting?> get(String name);

  // updates setting if available
  Future add(Setting setting);

  Future clear();
}
