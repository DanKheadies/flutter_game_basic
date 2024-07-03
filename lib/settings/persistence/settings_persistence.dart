abstract class SettingsPersistence {
  Future<bool> getAudioOn({required bool defaultValue});
  Future<bool> getMusicOn({required bool defaultValue});
  Future<bool> getSoundsOn({required bool defaultValue});
  Future<String> getPlayerName();
  Future<void> saveAudioOn(bool value);
  Future<void> saveMusicOn(bool value);
  Future<void> savePlayerName(String value);
  Future<void> saveSoundsOn(bool value);
}
