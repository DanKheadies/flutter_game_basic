import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

CustomTransitionPage<T> buildMyTransition<T>({
  required Widget child,
  required Color color,
  String? name,
  Object? arguments,
  String? restorationId,
  LocalKey? key,
}) {
  return CustomTransitionPage<T>(
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return MyReveal(
        animation: animation,
        color: color,
        child: child,
      );
    },
    key: key,
    name: name,
    arguments: arguments,
    restorationId: restorationId,
    transitionDuration: const Duration(milliseconds: 700),
  );
}

class MyReveal extends StatelessWidget {
  final Animation<double> animation;
  final Color color;
  final Widget child;

  MyReveal({
    super.key,
    required this.animation,
    required this.color,
    required this.child,
  });

  final fadeTween = TweenSequence([
    TweenSequenceItem(tween: ConstantTween(0.0), weight: 1),
    TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 1),
  ]);

  final slideTween = Tween(
    begin: const Offset(0, -1),
    end: Offset.zero,
  );

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        SlideTransition(
          position: slideTween.animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeOutCubic,
            ),
          ),
          child: Container(
            color: color,
          ),
        ),
        FadeTransition(
          opacity: fadeTween.animate(animation),
          child: child,
        ),
      ],
    );
  }
}
