import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_game_basic/audio/audio.dart';
import 'package:flutter_game_basic/game_internals/game_internals.dart';
import 'package:flutter_game_basic/levels/levels.dart';
import 'package:flutter_game_basic/play_session/play_session.dart';
import 'package:flutter_game_basic/player_progress/player_progress.dart';
import 'package:flutter_game_basic/style/style.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart' hide Level;
import 'package:provider/provider.dart';

class PlaySessionScreen extends StatefulWidget {
  final GameLevel level;

  const PlaySessionScreen(this.level, {super.key});

  @override
  State<PlaySessionScreen> createState() => _PlaySessionScreenState();
}

class _PlaySessionScreenState extends State<PlaySessionScreen> {
  static final log = Logger('PlaySessionScreen');

  static const celebrationDuration = Duration(milliseconds: 2000);
  static const preCelebrationDuration = Duration(milliseconds: 500);

  bool duringCelebration = false;

  late DateTime startOfPlay;

  @override
  void initState() {
    super.initState();

    startOfPlay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();

    return MultiProvider(
      providers: [
        Provider.value(value: widget.level),
        // Create and provide the [LevelState] object that will be used
        // by widgets below this one in the widget tree.
        ChangeNotifierProvider(
          create: (context) => LevelState(
            goal: widget.level.difficulty,
            onWin: playerWon,
          ),
        ),
      ],
      child: IgnorePointer(
        // Ignore all input during the celebration animation.
        ignoring: duringCelebration,
        child: Scaffold(
          backgroundColor: palette.backgroundPlaySession,
          // The stack is how you layer widgets on top of each other.
          // Here, it is used to overlay the winning confetti animation on top
          // of the game.
          body: Stack(
            children: [
              // This is the main layout of the play session screen,
              // with a settings button on top, the actual play area
              // in the middle, and a back button at the bottom.
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkResponse(
                      onTap: () => GoRouter.of(context).push('/settings'),
                      child: Image.asset(
                        'assets/images/settings.png',
                        semanticLabel: 'Settings',
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Expanded(
                    // The actual UI of the game.
                    child: GameWidget(),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: MyButton(
                      onPressed: () => GoRouter.of(context).go('/play'),
                      child: const Text('Back'),
                    ),
                  ),
                ],
              ),
              // This is the confetti animation that is overlaid on top of the
              // game when the player wins.
              // SizedBox.expand(
              //   // child: Visibility(
              //   //   visible: duringCelebration,
              //   //   child: IgnorePointer(
              //   //     child: Confetti(
              //   //       isStopped: !duringCelebration,
              //   //     ),
              //   //   ),
              //   // ),
              //   child: Confetti(
              //     isStopped: false, // !duringCelebration,
              //   ),
              // ),
              Container(
                // color: Colors.blue,
                height: MediaQuery.of(context).size.height,
                width: double.infinity,
                // child: Confetti(
                //   // isStopped: false,
                //   isStopped: !duringCelebration,
                // ),
                child: Visibility(
                  visible: duringCelebration,
                  child: IgnorePointer(
                    child: Confetti(
                      isStopped: !duringCelebration,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> playerWon() async {
    print('level won');
    log.info('Level ${widget.level.number} won');

    final score = Score(
      widget.level.number,
      widget.level.difficulty,
      DateTime.now().difference(startOfPlay),
    );

    final playerProgress = context.read<PlayerProgress>();
    playerProgress.setLevelReached(widget.level.number);

    // Let the player see the game just after winning for a bit.
    await Future<void>.delayed(preCelebrationDuration);
    print('alpha');
    if (!mounted) return;
    print('beta');

    setState(() {
      duringCelebration = true;
    });

    final audioController = context.read<AudioController>();
    audioController.playSfx(SfxType.congrats);

    /// Give the player some time to see the celebration animation.
    await Future<void>.delayed(celebrationDuration);
    if (!mounted) return;

    GoRouter.of(context).go('/play/won', extra: {'score': score});
  }
}
