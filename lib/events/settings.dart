import 'package:yababos/models/setting.dart';

abstract class SettingEvent {
  const SettingEvent();
}

class SettingAdd extends SettingEvent {
  final Setting setting;

  const SettingAdd(this.setting);
}

class SettingGet extends SettingEvent {
  final String name;

  const SettingGet(this.name);
}
