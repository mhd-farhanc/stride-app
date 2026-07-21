import 'package:flutter/foundation.dart';

import 'package:stride/services/step_repository.dart';

/// Manages theme (dark/light mode) state via Hive.
class ThemeProvider extends ChangeNotifier {
  final StepRepository _repository;
  late bool _isDarkMode;

  ThemeProvider({required StepRepository repository})
      : _repository = repository {
    _isDarkMode = _repository.getIsDarkMode();
  }

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _repository.setIsDarkMode(_isDarkMode);
    notifyListeners();
  }

  void setDarkMode(bool value) {
    if (_isDarkMode == value) return;
    _isDarkMode = value;
    _repository.setIsDarkMode(value);
    notifyListeners();
  }
}
