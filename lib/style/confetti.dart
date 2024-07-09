import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
  Widget build(BuildContext context) {
    print('print confetti');
    return CustomPaint(
      // TODO: painter Sky works, but not ConfettiPainter? why..
      // painter: Sky(),
      painter: ConfettiPainter(
        colors: widget.colors,
        animation: controller,
      ),
      // painter: LinePainter(
      //   progress: controller.value,
      // ),
      // painter: PathPainter(),
      willChange: true,
      // child: Container(
      //   // color: Colors.black,
      //   width: double.infinity,
      //   height: MediaQuery.of(context).size.height,
      // ),
      child: const SizedBox.expand(),
    );
    // return CustomPaint(
    //   painter: ConfettiPainter(
    //     colors: widget.colors,
    //     animation: controller,
    //   ),
    //   willChange: true,
    //   child: const SizedBox.expand(),
    // );
    // return Container(
    //   color: Colors.red,
    //   width: double.infinity,
    //   height: MediaQuery.of(context).size.height,
    // );
  }

  @override
  void initState() {
    super.initState();
    print('init confetti');
    controller = AnimationController(
      // We don't really care about the duration, since we're going to
      // use the controller on loop anyway.
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    if (!widget.isStopped) {
      print('repeat the confetti');
      controller.repeat();
      // controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant Confetti oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('update confetti');
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
}

class ConfettiPainter extends CustomPainter {
  // final int snippingsCount = 200;
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
    // print('paint confetti');
    // Note: ran a LOT (as it should, it's repainting the animation)
    if (conSize == null) {
      // print('con is null, so generate');
      snippings = List.generate(
        snippingsCount,
        (i) => PaperSnipping(
          frontColor: colors[i % colors.length],
          // frontColor: Colors.red,
          sizeBounds: size,
        ),
      );
      // print('(${snippings[5].position.x}, ${snippings[5].position.y})');
      // print('(${snippings[95].position.x}, ${snippings[95].position.y})');
      // print('conSize: $conSize');
      // print('size: $size');
    }

    // Note: this all runs multiple times, i.e. updates via the ani like it should
    // print('conSize: $conSize');
    // print('size: $size');
    final didResize = conSize != null && conSize != size;
    // print('didResize: $didResize');
    final now = DateTime.now();
    final dt = now.difference(lastTime);

    for (final snipping in snippings) {
      if (didResize) {
        // Note: should run is the screen changes orientation or something
        // if (true) {
        // print('\"did\" resize');
        snipping.updateBounds(size);
      }
      // print('update snipping');
      snipping.update(dt.inMilliseconds / 1000);

      // print('draw snipping');
      snipping.draw(canvas);
    }

    conSize = size;
    lastTime = now;

    // LinePainter().paint(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // print('repaint confetti');
    // Note: doesn't run?
    return true;
  }
}

class PaperSnipping {
  final Color frontColor;
  final Size sizeBounds;
  Size bounds;

  PaperSnipping({
    required this.frontColor,
    required this.sizeBounds,
  }) : bounds = sizeBounds;

  static final Random random = Random();
  static const degToRad = pi / 180;
  static const backSideBlend = Color(0x70eeeeee);

  late final Color backColor = Color.alphaBlend(backSideBlend, frontColor);
  late final Vector position = Vector(
    random.nextDouble() * bounds.width - 25,
    random.nextDouble() * bounds.height,
  );

  final double angle = random.nextDouble() * 360 * degToRad;
  final double oscillationSpeed = 0.5 * random.nextDouble() * 1.5;
  final double rotationSpeed = 800 + random.nextDouble() * 600;
  final double size = 1.0; // OG modifier
  final double xSpeed = 40;
  final double ySpeed = 50 + random.nextDouble() * 60;
  final int sSize = 5; // Added to offsets to give it size; 3-10 is ideal

  final paint = Paint()..style = PaintingStyle.fill;

  double cosA = 1.0;
  double rotation = random.nextDouble() * 360 * degToRad;
  double time = random.nextDouble();

  // List<Vector> corners2 = [
  //   Vector(
  //     cos((random.nextDouble() * 90 * degToRad) + degToRad * (45 + 0 + 90)),
  //     sin((random.nextDouble() * 90 * degToRad) + degToRad * (45 + 0 + 90)),
  //   ),
  //   Vector(
  //     cos((random.nextDouble() * 90 * degToRad) + degToRad * (45 + 1 + 90)),
  //     sin((random.nextDouble() * 90 * degToRad) + degToRad * (45 + 1 + 90)),
  //   ),
  //   Vector(
  //     cos((random.nextDouble() * 90 * degToRad) + degToRad * (45 + 2 + 90)),
  //     sin((random.nextDouble() * 90 * degToRad) + degToRad * (45 + 2 + 90)),
  //   ),
  //   Vector(
  //     cos((random.nextDouble() * 90 * degToRad) + degToRad * (45 + 3 + 90)),
  //     sin((random.nextDouble() * 90 * degToRad) + degToRad * (45 + 3 + 90)),
  //   ),
  // ];
  // late List<Vector> corners2 = [
  //   Vector(
  //     cos(angle + degToRad * (45 + 0 + 90)),
  //     sin(angle + degToRad * (45 + 0 + 90)),
  //   ),
  //   Vector(
  //     cos(angle + degToRad * (45 + 1 + 90)),
  //     sin(angle + degToRad * (45 + 1 + 90)),
  //   ),
  //   Vector(
  //     cos(angle + degToRad * (45 + 2 + 90)),
  //     sin(angle + degToRad * (45 + 2 + 90)),
  //   ),
  //   Vector(
  //     cos(angle + degToRad * (45 + 3 + 90)),
  //     sin(angle + degToRad * (45 + 3 + 90)),
  //   ),
  // ];

  late List<Vector> corners2 = List.generate(
    4,
    (i) {
      final vecAngle = angle + degToRad * (45 + i + 90) * rotation;
      return Vector(
        cos(vecAngle),
        sin(vecAngle),
      );
    },
  );

  void draw(Canvas canvas) {
    if (cosA > 0) {
      paint.color = frontColor;
    } else {
      paint.color = backColor;
    }

    // final path = Path()
    //   ..addPolygon(
    //     List.generate(
    //         4,
    //         (index) => Offset(
    //               position.x + corners[index].x * size,
    //               position.y + corners[index].y * size * cosA,
    //             )),
    //     true,
    //   );
    // List<Offset> offsets = List.generate(
    //   4,
    //   (i) => Offset(
    //     position.x + i == 0 || i == 3 ? 0 : 10 + corners[i].x * 1,
    //     position.y + i == 0 || i == 1 ? 0 : 10 + corners[i].y * 1 * 1,
    //   ),
    // );
    // print(offsets);
    Path path = Path();
    // path.addPolygon(
    //   [
    //     // Offset.zero,
    //     Offset(
    //       position.x + corners[0].x * size,
    //       position.y + corners[0].y * size * cosA,
    //     ),
    //     Offset(bounds.width / 4, bounds.height / 4),
    //     Offset(bounds.width / 2, bounds.height),
    //   ],
    //   true,
    // );

    // Update: THIS WORKS
    // path.addPolygon(
    //   [
    //     // Offset.zero,
    //     Offset(
    //       position.x,
    //       position.y,
    //     ),
    //     Offset(
    //       position.x + 10,
    //       position.y,
    //     ),
    //     Offset(
    //       position.x + 10,
    //       position.y + 10,
    //     ),
    //     Offset(
    //       position.x,
    //       position.y + 10,
    //     ),
    //   ],
    //   true,
    // );
    // path.addPolygon(
    //   [
    //     Offset(
    //       position.x + corners2[0].x * size,
    //       position.y + corners2[0].y * size * cosA,
    //     ),
    //     Offset(
    //       position.x + corners2[1].x * size + 0,
    //       position.y + corners2[1].y * size * cosA,
    //     ),
    //     Offset(
    //       position.x + corners2[2].x * size + 0,
    //       position.y + 0 + corners2[2].y * size * cosA,
    //     ),
    //     Offset(
    //       position.x + corners2[3].x * size,
    //       position.y + 0 + corners2[3].y * size * cosA,
    //     ),
    //   ],
    //   true,
    // );
    path.addPolygon(
      [
        Offset(
          position.x + corners2[0].x * size,
          position.y + corners2[0].y * size * cosA,
        ),
        Offset(
          position.x + (corners2[1].x + sSize) * size,
          position.y + corners2[1].y * size * cosA,
        ),
        Offset(
          position.x + (corners2[2].x + sSize) * size,
          position.y + (corners2[2].y + sSize) * size * cosA,
        ),
        Offset(
          position.x + corners2[3].x * size,
          position.y + (corners2[3].y + sSize) * size * cosA,
        ),
      ],
      true,
    );
    // path.addPolygon(
    //   offsets,
    //   true,
    // );
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
    // Update: we don't update the size of the device / orientation, so never runs
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
