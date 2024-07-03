enum SfxType {
  buttonTap,
  congrats,
  erase,
  huhsh,
  switchSwish,
  wssh,
}

double soundTypeToVolume(SfxType type) {
  switch (type) {
    case SfxType.huhsh:
      return 0.4;
    case SfxType.wssh:
      return 0.2;
    case SfxType.buttonTap:
    case SfxType.congrats:
    case SfxType.erase:
    case SfxType.switchSwish:
      return 1.0;
  }
}

List<String> soundTypeToFilename(SfxType type) => switch (type) {
      SfxType.buttonTap => const [
          'k1.mp3',
          'k2.mp3',
          'p1.mp3',
          'p2.mp3',
        ],
      SfxType.congrats => const [
          'yay1.mp3',
          'wehee1.mp3',
          'oo1.mp3',
        ],
      SfxType.erase => const [
          'fwfwfwfwfw1.mp3',
          'fwfwfwfw1.mp3',
        ],
      SfxType.huhsh => const [
          'hash1.mp3',
          'hash2.mp3',
          'hash3.mp3',
        ],
      SfxType.switchSwish => const [
          'swishswish1.mp3',
        ],
      SfxType.wssh => const [
          'wssh1.mp3',
          'wssh2.mp3',
          'dsht1.mp3',
          'ws1.mp3',
          'spsh1.mp3',
          'hh1.mp3',
          'hh2.mp3',
          'kss1.mp3',
        ],
    };