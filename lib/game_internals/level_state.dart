import 'package:flutter/foundation.dart';

class LevelState extends ChangeNotifier {
  final VoidCallback onWin;

  final int goal;

  LevelState({
    required this.onWin,
    this.goal = 100,
  });

  int levelProgress = 0;

  int get progress => levelProgress;

  void setProgress(int value) {
    levelProgress = value;
    notifyListeners();
  }

  void evaluate() {
    if (levelProgress >= goal) {
      onWin();
    }
  }
}
