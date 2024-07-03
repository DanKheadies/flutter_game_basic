class GameLevel {
  final int number;
  final int difficulty;
  final String? achievementIdIOS;
  final String? achievementIdAndroid;

  const GameLevel({
    required this.number,
    required this.difficulty,
    this.achievementIdIOS,
    this.achievementIdAndroid,
  }) : assert(
          (achievementIdAndroid != null && achievementIdIOS != null) ||
              (achievementIdAndroid == null && achievementIdIOS == null),
          'Either both iOS and Android achievement ID must be provided, '
          'or none',
        );

  bool get awardsAchievement => achievementIdAndroid != null;
}

const gameLevels = [
  GameLevel(
    number: 1,
    difficulty: 5,
    achievementIdIOS: 'first_win',
    achievementIdAndroid: 'NhkIwB69ejkMAOOLDb',
  ),
  GameLevel(
    number: 2,
    difficulty: 42,
  ),
  GameLevel(
    number: 3,
    difficulty: 100,
    achievementIdIOS: 'finished',
    achievementIdAndroid: 'CdfIhE96aspNWLGSQg',
  ),
];
