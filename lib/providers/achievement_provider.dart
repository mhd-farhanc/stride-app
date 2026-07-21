import 'package:flutter/foundation.dart';

import 'package:stride/services/achievement_service.dart';
import 'package:stride/services/step_repository.dart';

/// Manages achievement badge state.
class AchievementProvider extends ChangeNotifier {
  final StepRepository _repository;

  AchievementProvider({
    required StepRepository repository,
  }) : _repository = repository;
  List<AchievementDef> get achievements {
    return List.unmodifiable(AchievementService.allAchievements);
  }

  bool isUnlocked(String id) {
    return _repository.getUnlockedAchievements().contains(id);
  }
}
