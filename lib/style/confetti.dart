import 'dart:collection';
import 'dart:math';

import 'package:flutter/widgets.dart';

class Confetti extends StatefulWidget {
  static const defaultColors = [
    Color(0xFFd10841),
    Color(0xFF1d75fb),
    Color(0xFF0050bc),
    Color(0xFFa2dcc7),
  ];

  final bool isStopped;
  final List<Color> colors;

  const Confetti({
    super.key,
    this.colors = defaultColors,
    this.isStopped = false,
  });

  @override
  State<Confetti> createState() => _ConfettiState();
}

class _ConfettiState extends State<Confetti>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      // We don't really care about the duration, since we're going to
      // use the controller on loop anyway.
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    if (!widget.isStopped) {
      controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant Confetti oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isStopped && !widget.isStopped) {
      controller.repeat();
    } else if (!oldWidget.isStopped && widget.isStopped) {
      controller.stop(canceled: false);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ConfettiPainter(
        colors: widget.colors,
        animation: controller,
      ),
      willChange: true,
      child: const SizedBox.expand(),
    );
  }
}

class ConfettiPainter extends CustomPainter {
  final int snippingsCount = 200;
  final Paint defaultPaint = Paint();
  final UnmodifiableListView<Color> colors;

  late final List<PaperSnipping> snippings;

  DateTime lastTime = DateTime.now();
  Size? conSize;

  ConfettiPainter({
    required Listenable animation,
    required Iterable<Color> colors,
  })  : colors = UnmodifiableListView(colors),
        super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    if (conSize == null) {
      snippings = List.generate(
        snippingsCount,
        (i) => PaperSnipping(
          frontColor: colors[i % colors.length],
          sBounds: size,
        ),
      );
    }

    final didResize = conSize != null && conSize != size;
    final now = DateTime.now();
    final dt = now.difference(lastTime);

    for (final snipping in snippings) {
      if (didResize) {
        snipping.updateBounds(size);
      }
      snipping.update(dt.inMilliseconds / 1000);
      snipping.draw(canvas);
    }

    conSize = size;
    lastTime = now;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class PaperSnipping {
  final Color frontColor;
  Size bounds;

  PaperSnipping({
    required this.frontColor,
    required Size sBounds,
  }) : bounds = sBounds;

  static final Random random = Random();
  static const degToRad = pi / 180;
  static const backSideBlend = Color(0x70eeeeee);

  late final Color backColor = Color.alphaBlend(backSideBlend, frontColor);
  late final Vector position = Vector(
    random.nextDouble() * bounds.width,
    random.nextDouble() * bounds.height,
  );

  final double angle = random.nextDouble() * 360 * degToRad;
  final double oscillationSpeed = 0.5 * random.nextDouble() * 1.5;
  final double rotationSpeed = 800 + random.nextDouble() * 600;
  final double size = 7.0;
  final double xSpeed = 40;
  final double ySpeed = 50 + random.nextDouble() * 60;

  final paint = Paint()..style = PaintingStyle.fill;

  double cosA = 1.0;
  double rotation = random.nextDouble() * 360 * degToRad;
  double time = random.nextDouble();

  late List<Vector> corners = List.generate(4, (i) {
    final angle = this.angle + degToRad * (45 + i + 90);
    return Vector(cos(angle), sin(angle));
  });

  void draw(Canvas canvas) {
    if (cosA > 0) {
      paint.color = frontColor;
    } else {
      paint.color = backColor;
    }

    final path = Path()
      ..addPolygon(
        List.generate(
            4,
            (index) => Offset(
                  position.x + corners[index].x * size,
                  position.y + corners[index].y * size * cosA,
                )),
        true,
      );
    canvas.drawPath(path, paint);
  }

  void update(double dt) {
    time += dt;
    rotation += rotationSpeed * dt;
    cosA = cos(degToRad * rotation);
    position.x += cos(time * oscillationSpeed) * xSpeed * dt;
    position.y += ySpeed * dt;
    if (position.y > bounds.height) {
      position.x = random.nextDouble() * bounds.width;
      position.y = 0;
    }
  }

  void updateBounds(Size newBounds) {
    if (!newBounds.contains(Offset(position.x, position.y))) {
      position.x = random.nextDouble() * newBounds.width;
      position.y = random.nextDouble() * newBounds.height;
    }
    bounds = newBounds;
  }
}

class Vector {
  double x, y;

  Vector(
    this.x,
    this.y,
  );
}
