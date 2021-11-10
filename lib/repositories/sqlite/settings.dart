import 'package:yababos/models/setting.dart';
import 'package:yababos/repositories/settings.dart';
import 'package:yababos/repositories/sqlite/yababos.dart';

class SettingsSqlite extends SettingsRepository {
  @override
  Future add(Setting setting) {
    return Future(() async {
      if (await get(setting.name) == null)
        _insert(setting);
      else
        _update(setting);
    });
  }

  @override
  Future<Setting> get(String name) {
    return Future(() async {
      List<Map<String, Object>> record =
          await (await YababosSqlite.getDatabase())
              .rawQuery('SELECT * FROM settings WHERE name = ?', [name]);
      if (record.isEmpty) return null;

      return Setting(
        name: record[0]['name'],
        value: record[0]['value'],
      );
    });
  }

  Future _insert(Setting setting) {
    return Future(() async {
      await (await YababosSqlite.getDatabase()).rawInsert('''
        INSERT INTO settings
        (
          name,
          value
        )
        VALUES
        (
          ?,
          ?
        )
        ''', [
        setting.name,
        setting.value,
      ]);
    });
  }

  Future _update(Setting setting) {
    return Future(() async {
      await (await YababosSqlite.getDatabase()).rawUpdate('''
        UPDATE settings SET
          value = ?
        WHERE name = ?
        ''', [
        setting.value,
        setting.name,
      ]);
    });
  }
}
