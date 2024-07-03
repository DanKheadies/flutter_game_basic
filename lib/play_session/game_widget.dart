import 'package:flutter/material.dart';
import 'package:flutter_game_basic/audio/audio.dart';
import 'package:flutter_game_basic/game_internals/game_internals.dart';
import 'package:flutter_game_basic/levels/levels.dart';
import 'package:provider/provider.dart';

class GameWidget extends StatelessWidget {
  const GameWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final level = context.watch<GameLevel>();
    final levelState = context.watch<LevelState>();

    return Column(
      children: [
        Text('Drag the slider to ${level.difficulty}% or above!'),
        Slider(
          label: 'Level Progress',
          autofocus: true,
          value: levelState.progress / 100,
          onChanged: (value) => levelState.setProgress((value * 100).round()),
          onChangeEnd: (value) {
            context.read<AudioController>().playSfx(SfxType.wssh);
            levelState.evaluate();
          },
        ),
      ],
    );
  }
}
