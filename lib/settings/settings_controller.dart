import 'package:flutter/foundation.dart';
import 'package:flutter_game_basic/settings/settings.dart';
import 'package:logging/logging.dart';

// TODO: conver to bloc
class SettingsController {
  static final log = Logger('SettingsController');

  final SettingsPersistence store;

  ValueNotifier<bool> audioOn = ValueNotifier(true);
  ValueNotifier<String> playerName = ValueNotifier('Player');
  ValueNotifier<bool> soundsOn = ValueNotifier(true);
  ValueNotifier<bool> musicOn = ValueNotifier(true);

  SettingsController({SettingsPersistence? localStore})
      : store = localStore ?? LocalStorageSettingsPersistence() {
    loadStateFromPersistence();
  }

  void setPlayerName(String name) {
    playerName.value = name;
    store.savePlayerName(playerName.value);
  }

  void toggleAudioOn() {
    audioOn.value = !audioOn.value;
    store.saveAudioOn(audioOn.value);
  }

  void toggleMusicOn() {
    musicOn.value = !musicOn.value;
    store.saveMusicOn(musicOn.value);
  }

  void toggleSoundsOn() {
    soundsOn.value = !soundsOn.value;
    store.saveSoundsOn(soundsOn.value);
  }

  Future<void> loadStateFromPersistence() async {
    final loadedValues = await Future.wait([
      store.getAudioOn(defaultValue: true).then((value) {
        if (kIsWeb) {
          return audioOn.value = false;
        }
        return audioOn.value = value;
      }),
      store
          .getSoundsOn(defaultValue: true)
          .then((value) => soundsOn.value = value),
      store
          .getMusicOn(defaultValue: true)
          .then((value) => musicOn.value = value),
      store.getPlayerName().then((value) => playerName.value = value),
    ]);

    log.fine(() => 'Loaded settings: $loadedValues');
  }
}
