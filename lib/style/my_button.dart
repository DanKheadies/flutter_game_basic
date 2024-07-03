import 'dart:math';

import 'package:flutter/material.dart';

class MyButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;

  const MyButton({
    super.key,
    required this.child,
    this.onPressed,
  });

  @override
  State<MyButton> createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(
    duration: const Duration(milliseconds: 300),
    vsync: this,
  );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) {
        controller.repeat();
      },
      onExit: (event) {
        controller.stop(canceled: false);
      },
      child: RotationTransition(
        turns: controller.drive(const MySineTween(0.005)),
        child: FilledButton(
          onPressed: widget.onPressed,
          child: widget.child,
        ),
      ),
    );
  }
}

class MySineTween extends Animatable<double> {
  final double maxExtent;

  const MySineTween(this.maxExtent);

  @override
  double transform(double t) {
    return sin(t * 2 * pi) * maxExtent;
  }
}
