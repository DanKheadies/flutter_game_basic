import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_game_basic/app_lifecycle/app_lifecycle.dart';
import 'package:flutter_game_basic/audio/audio.dart';
import 'package:flutter_game_basic/settings/settings.dart';
import 'package:logging/logging.dart';

class AudioController {
  static final log = Logger('AudioController');
  final AudioPlayer musicPlayer;
  final List<AudioPlayer> sfxPlayers;
  final Queue<Song> playlist;
  final Random random = Random();

  int currentSfxPlayer = 0;
  SettingsController? settings;
  ValueNotifier<AppLifecycleState>? lifecycleNotifier;

  AudioController({int polyphony = 2})
      : assert(polyphony >= 1),
        musicPlayer = AudioPlayer(playerId: 'musicPlayer'),
        sfxPlayers = Iterable.generate(
          polyphony,
          (i) => AudioPlayer(playerId: 'sfxPlayers#$i'),
        ).toList(growable: false),
        playlist = Queue.of(List<Song>.of(songs)..shuffle()) {
    musicPlayer.onPlayerComplete.listen(handleSongFinished);
    unawaited(preloadSfx());
  }

  // TODO: see when / where this is called
  // Update: in main.dart
  void attachDependencies(
    AppLifecycleStateNotifier lifecycleNotifier,
    SettingsController settingsController,
  ) {
    attachLifecycleNotifier(lifecycleNotifier);
    attachSettings(settingsController);
  }

  void attachLifecycleNotifier(AppLifecycleStateNotifier appLifecycleNotifier) {
    lifecycleNotifier?.removeListener(handleAppLifecycle);

    appLifecycleNotifier.addListener(handleAppLifecycle);
    lifecycleNotifier = appLifecycleNotifier;
  }

  void handleAppLifecycle() {
    switch (lifecycleNotifier!.value) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        stopAllSound();
      case AppLifecycleState.resumed:
        if (settings!.audioOn.value && settings!.musicOn.value) {
          startOrResumeMusic();
        }
      case AppLifecycleState.inactive:
        break;
    }
  }

  void attachSettings(SettingsController settingsController) {
    if (settings == settingsController) {
      return;
    }

    final oldSettings = settings;
    if (oldSettings != null) {
      oldSettings.audioOn.removeListener(audioOnHandler);
      oldSettings.musicOn.removeListener(musicOnHandler);
      oldSettings.soundsOn.removeListener(soundsOnHandler);
    }

    settings = settingsController;

    settingsController.audioOn.addListener(audioOnHandler);
    settingsController.musicOn.addListener(musicOnHandler);
    settingsController.soundsOn.addListener(soundsOnHandler);

    if (settingsController.audioOn.value && settingsController.musicOn.value) {
      if (kIsWeb) {
        log.info('On the web, music can only start after user interaction.');
      } else {
        playCurrentSongInPlaylist();
      }
    }
  }

  void audioOnHandler() {
    log.fine('audioOn changed to ${settings!.audioOn.value}');
    if (settings!.audioOn.value) {
      if (settings!.musicOn.value) {
        startOrResumeMusic();
      }
    } else {
      stopAllSound();
    }
  }

  void musicOnHandler() {
    if (settings!.musicOn.value) {
      if (settings!.audioOn.value) {
        startOrResumeMusic();
      }
    } else {
      musicPlayer.pause();
    }
  }

  void soundsOnHandler() {
    for (final player in sfxPlayers) {
      if (player.state == PlayerState.playing) {
        player.stop();
      }
    }
  }

  void handleSongFinished(void _) {
    log.info('Last song finished playing.');
    playlist.addLast(playlist.removeFirst());
    playCurrentSongInPlaylist();
  }

  void playSfx(SfxType type) {
    final audioOn = settings?.audioOn.value ?? false;
    if (!audioOn) {
      log.fine(() => 'Ignoring player sound ($type) because audio is muted.');
      return;
    }
    final soundsOn = settings?.soundsOn.value ?? false;
    if (!soundsOn) {
      log.fine(() =>
          'Ignoring playing sound ($type) because sounds are turned off.');
      return;
    }

    log.fine(() => 'Playing sound: $type');
    final options = soundTypeToFilename(type);
    final filename = options[random.nextInt(options.length)];
    log.fine(() => '- Chosen filename: $filename');

    final currentPlayer = sfxPlayers[currentSfxPlayer];
    currentPlayer.play(
      AssetSource('sfx/$filename'),
      volume: soundTypeToVolume(type),
    );
    currentSfxPlayer = (currentSfxPlayer + 1) % sfxPlayers.length;
  }

  void startOrResumeMusic() async {
    if (musicPlayer.source == null) {
      log.info('No music source set. '
          'Start playing the current song in playlist.');
      await playCurrentSongInPlaylist();
      return;
    }

    log.info('Resuming paused music.');
    try {
      musicPlayer.resume();
    } catch (err) {
      log.severe('Error resuming msuic', err);
      playCurrentSongInPlaylist();
    }
  }

  void stopAllSound() {
    log.info('Stopping all sound');
    musicPlayer.pause();
    for (final player in sfxPlayers) {
      player.stop();
    }
  }

  Future<void> playCurrentSongInPlaylist() async {
    log.info(() => 'Playing ${playlist.first} now.');
    try {
      await musicPlayer.play(
        AssetSource('music/${playlist.first.filename}'),
      );
    } catch (err) {
      log.severe('Could not play song ${playlist.first}', err);
    }
  }

  Future<void> preloadSfx() async {
    log.info('Preloading sound effects');
    await AudioCache.instance.loadAll(SfxType.values
        .expand(soundTypeToFilename)
        .map((path) => 'sfx/$path')
        .toList());
  }

  void dispose() {
    lifecycleNotifier?.removeListener(handleAppLifecycle);
    stopAllSound();
    musicPlayer.dispose();
    for (final player in sfxPlayers) {
      player.dispose();
    }
  }
}
