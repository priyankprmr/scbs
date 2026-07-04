import 'package:equatable/equatable.dart';

import '../../../data/models/settings.dart';

sealed class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

final class LoadSettings extends SettingsEvent {
  const LoadSettings();
}

final class UpdateSettings extends SettingsEvent {
  final Settings settings;

  const UpdateSettings(this.settings);

  @override
  List<Object?> get props => [settings];
}
