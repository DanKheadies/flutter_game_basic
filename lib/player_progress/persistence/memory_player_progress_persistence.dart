import 'package:flutter_game_basic/player_progress/player.dart';

class MemoryOnlyPlayerProgressPersistence implements PlayerProgressPersistence {
  int level = 0;

  @override
  Future<int> getHighestLevelReached() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return level;
  }

  @override
  Future<void> saveHighestLevelReached(int level) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    this.level = level;
  }
}
