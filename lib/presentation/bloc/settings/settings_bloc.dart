import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/settings_repository.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository _repository;

  SettingsBloc(this._repository) : super(const SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateSettings>(_onUpdateSettings);
  }

  void _onLoadSettings(LoadSettings event, Emitter<SettingsState> emit) {
    emit(const SettingsLoading());
    try {
      final settings = _repository.get();
      emit(SettingsLoaded(settings));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onUpdateSettings(
      UpdateSettings event, Emitter<SettingsState> emit) async {
    await _repository.update(event.settings);
    emit(SettingsLoaded(event.settings));
  }
}
