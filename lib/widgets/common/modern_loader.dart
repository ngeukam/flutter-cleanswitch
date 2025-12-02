import 'package:flutter/material.dart';
import 'dart:math' as math;

class ModernLoader extends StatefulWidget {
  final String? text;
  const ModernLoader({super.key, this.text});

  @override
  State<ModernLoader> createState() => _ModernLoaderState();
}

class _ModernLoaderState extends State<ModernLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))
        ..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (_, child) {
              return Transform.rotate(
                angle: _controller.value * 2 * math.pi,
                child: CustomPaint(
                  size: const Size(60, 60),
                  painter: _CircularPainter(colorScheme.primary),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            widget.text ?? "Loading...",
            style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircularPainter extends CustomPainter {
  final Color color;
  _CircularPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 6.0;
    final rect = Offset.zero & size;

    final gradient = SweepGradient(
      colors: [color.withOpacity(0.1), color, color.withOpacity(0.1)],
      stops: const [0.1, 0.5, 0.9],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height),
      math.pi / 2,
      3 * math.pi / 2,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
