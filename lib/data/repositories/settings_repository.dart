import 'package:hive_ce/hive.dart';

import '../models/settings.dart';

class SettingsRepository {
  final Box<Settings> _box;

  SettingsRepository(this._box);

  Settings get() {
    final settings = _box.get('singleton');
    if (settings != null) return settings;
    final defaults = Settings.defaults();
    _box.put('singleton', defaults);
    return defaults;
  }

  Future<void> update(Settings settings) =>
      _box.put('singleton', settings);
}
