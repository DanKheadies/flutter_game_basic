import 'package:flutter/material.dart';
import 'package:flutter_game_basic/game_internals/game_internals.dart';
import 'package:flutter_game_basic/screens/screens.dart';
import 'package:flutter_game_basic/style/style.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class WinGameScreen extends StatelessWidget {
  final Score score;

  const WinGameScreen({
    super.key,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();

    const gap = SizedBox(height: 10);

    return Scaffold(
      backgroundColor: palette.backgroundPlaySession,
      body: ResponsiveScreen(
        squarishMainArea: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            gap,
            const Center(
              child: Text(
                'You won!',
                style: TextStyle(
                  fontFamily: 'Permanent Marker',
                  fontSize: 50,
                ),
              ),
            ),
            gap,
            Center(
              child: Text(
                'Score: ${score.score}\n'
                'Time: ${score.formattedTime}',
                style: const TextStyle(
                  fontFamily: 'Permanent Marker',
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
        rectangularMenuArea: MyButton(
          onPressed: () {
            GoRouter.of(context).go('/play');
          },
          child: const Text('Continue'),
        ),
      ),
    );
  }
}
