const Set<Song> songs = {
  Song(
    'CloudDanklas.wav',
    'Cloud Danklas',
    artist: 'Daco Taco Flame',
  ),
  Song(
    'DearestHue.wav',
    'Dearest Matthue',
    artist: 'Daco Taco Flame',
  ),
  Song(
    'Gatsu.wave',
    'Gatsu',
    artist: 'Daco Taco Flame',
  ),
};

class Song {
  final String filename;
  final String name;
  final String? artist;

  const Song(
    this.filename,
    this.name, {
    this.artist,
  });

  @override
  String toString() => 'Song<$filename>';
}
