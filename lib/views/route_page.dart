import 'package:flutter/material.dart';

class RoutePage extends StatefulWidget {
  const RoutePage({super.key});

  @override
  State<RoutePage> createState() => _RoutePageState();
}

class _RoutePageState extends State<RoutePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: CustomPaint(
            painter: DrawRoute(
              points: [
                [21.8221462, 96.3442843],
                [21.8222, 96.3437305],
                [21.8222961, 96.3432766],
                [21.8221757, 96.343177],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DrawRoute extends CustomPainter {
  final List<List<double>> points;
  DrawRoute({required this.points});
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill
      ..strokeWidth = 5;
    for (int i = 0; i < points.length - 1; i++) {
      final divider = 100000000;
      final x1 =
          double.parse(points[i][0].toString().padRight(18, "0").substring(8)) /
          divider;
      final y1 =
          double.parse(points[i][1].toString().padRight(18, "0").substring(8)) /
          divider;
      final x2 =
          double.parse(
            points[i + 1][0].toString().padRight(18, "0").substring(8),
          ) /
          divider;
      final y2 =
          double.parse(
            points[i + 1][1].toString().padRight(18, "0").substring(8),
          ) /
          divider;
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
