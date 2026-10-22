import 'dart:math' as math;
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  static const totalMs = 5500; // 5.5 секунды

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: totalMs),
    )..forward();

    _c.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const BootPage(), // ← твоя страница
            transitionDuration: const Duration(milliseconds: 450),
            transitionsBuilder: (_, a, __, child) =>
                FadeTransition(opacity: a, child: child),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: _c,
        builder: (_, __) {
          return CustomPaint(
            painter: _SplashPainter(t: _c.value),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}

class _SplashPainter extends CustomPainter {
  final double t; // 0.0 → 1.0
  _SplashPainter({required this.t});

  // Прогресс загрузки (с лёгким easing)
  double get progress {
    final v = ((t - 0.06) / 0.78).clamp(0.0, 1.0);
    return 0.75 * v + 0.25 * (0.5 - 0.5 * math.cos(math.pi * v));
  }

  // Яркость эффектов (появление и затухание)
  double get gain {
    if (t < 0.06) return _smooth(t / 0.06);
    if (t > 0.88) return 1.0 - _smooth((t - 0.88) / 0.12);
    return 1.0;
  }

  double _smooth(double x) => x * x * (3 - 2 * x);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final s = w / 390; // базовый масштаб

    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);

    final p = progress;
    final g = gain;

    _drawLogo(canvas, w, h, s, p, g);
    _drawBar(canvas, w, h, s, p, g);
    _drawLabel(canvas, w, h, s);
  }

  void _drawLogo(Canvas canvas, double w, double h, double s, double p, double g) {
    const text = 'VOSITA';
    final fontSize = 58 * s;

    final style = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      letterSpacing: 4 * s,
      color: const Color(0xFF0A0C0B),
      height: 1.0,
    );

    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();

    final dx = (w - tp.width) / 2;
    final dy = h * 0.36 - tp.height / 2;

    // Мягкая тень
    final shadowTp = TextPainter(
      text: TextSpan(
        text: text,
        style: style.copyWith(color: Colors.black.withValues(alpha: 0.18)),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    shadowTp.paint(canvas, Offset(dx, dy + 3 * s));

    // Основной текст
    tp.paint(canvas, Offset(dx, dy));

    // Зелёный сканирующий луч
    if (g > 0.02) {
      final beamX = dx + p * tp.width;

      // Горизонтальный луч
      final ray = Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.transparent,
            const Color(0xFF00F05A).withValues(alpha: 0.25 * g),
            const Color(0xFF00F05A).withValues(alpha: 0.9 * g),
            const Color(0xFFE8FFF0).withValues(alpha: 0.95 * g),
            const Color(0xFF00F05A).withValues(alpha: 0.9 * g),
            const Color(0xFF00F05A).withValues(alpha: 0.25 * g),
            Colors.transparent,
          ],
          stops: const [0.0, 0.3, 0.45, 0.5, 0.55, 0.7, 1.0],
        ).createShader(Rect.fromLTWH(beamX - 70 * s, dy, 140 * s, tp.height));

      canvas.saveLayer(
        Rect.fromLTWH(dx - 10, dy - 10, tp.width + 20, tp.height + 20),
        Paint(),
      );
      canvas.drawRect(
        Rect.fromLTWH(beamX - 70 * s, dy - 8 * s, 140 * s, tp.height + 16 * s),
        ray,
      );

      // Яркая линия
      final line = Paint()
        ..color = Color.fromRGBO(0, 240, 90, 0.95 * g)
        ..strokeWidth = 2.2 * s
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5 * s);
      canvas.drawLine(
        Offset(beamX - 60 * s, dy + tp.height * 0.55),
        Offset(beamX + 60 * s, dy + tp.height * 0.55),
        line,
      );

      // Ядро
      final core = Paint()
        ..color = Color.fromRGBO(230, 255, 242, 0.95 * g)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10 * s);
      canvas.drawCircle(Offset(beamX, dy + tp.height * 0.55), 7 * s, core);

      canvas.restore();
    }
  }

  void _drawBar(Canvas canvas, double w, double h, double s, double p, double g) {
    final bw = 280.0 * s;
    final bh = 22.0 * s;
    final bx = (w - bw) / 2;
    final by = h * 0.62;

    final r = bh / 2;
    final outer = RRect.fromRectAndRadius(
      Rect.fromLTWH(bx, by, bw, bh),
      Radius.circular(r),
    );
    final pad = 2.8 * s;
    final inner = RRect.fromRectAndRadius(
      Rect.fromLTWH(bx + pad, by + pad, bw - pad * 2, bh - pad * 2),
      Radius.circular(r - pad),
    );

    // Тень
    canvas.drawRRect(
      outer.shift(Offset(0, 2.5 * s)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.07)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6 * s),
    );

    // Стекло
    canvas.drawRRect(
      outer,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE8EEEA), Color(0xFFFCFDFC), Color(0xFFD5DED8)],
        ).createShader(outer.outerRect),
    );

    canvas.drawRRect(
      inner,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFD8E0DB), Color(0xFFF4F7F5), Color(0xFFFEFFFE)],
        ).createShader(inner.outerRect),
    );

    // Заполнение
    final fw = (bw - pad * 2) * p;
    if (fw > 1) {
      final fillRect = Rect.fromLTWH(bx + pad, by + pad, fw, bh - pad * 2);
      final fill = RRect.fromRectAndRadius(fillRect, Radius.circular(r - pad));

      // Свечение
      canvas.drawRRect(
        fill,
        Paint()
          ..color = const Color(0xFF00E85A).withValues(alpha: 0.3)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10 * s),
      );

      canvas.save();
      canvas.clipRRect(inner);
      canvas.drawRRect(
        fill,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF7DFFB0),
              Color(0xFF1AF06A),
              Color(0xFF00C749),
              Color(0xFF009A3C),
            ],
            stops: [0.0, 0.28, 0.6, 1.0],
          ).createShader(fillRect),
      );

      // Блик
      canvas.drawRect(
        Rect.fromLTWH(bx + pad, by + pad, fw, (bh - pad * 2) * 0.4),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withValues(alpha: 0.5),
              Colors.white.withValues(alpha: 0.0),
            ],
          ).createShader(
            Rect.fromLTWH(bx + pad, by + pad, fw, (bh - pad * 2) * 0.4),
          ),
      );
      canvas.restore();

      // Точка на конце
      if (g > 0.05 && p < 0.98) {
        final ex = bx + pad + fw;
        final ey = by + bh / 2;
        canvas.drawCircle(
          Offset(ex, ey),
          11 * s,
          Paint()
            ..shader = RadialGradient(
              colors: [
                Color.fromRGBO(240, 255, 246, 0.9 * g),
                Color.fromRGBO(80, 255, 150, 0.4 * g),
                Colors.transparent,
              ],
            ).createShader(Rect.fromCircle(center: Offset(ex, ey), radius: 11 * s)),
        );
      }
    }

    // Процент
    final percent = '${(p * 100).round()}%';
    final tp = TextPainter(
      text: TextSpan(
        text: percent,
        style: TextStyle(
          fontSize: 12 * s,
          fontWeight: FontWeight.w600,
          color: p > 0.42 ? Colors.white : const Color(0xFF14532D),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset((w - tp.width) / 2, by + (bh - tp.height) / 2));
  }

  void _drawLabel(Canvas canvas, double w, double h, double s) {
    const text = 'VOSITA STUDIOS';
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 12 * s,
          fontWeight: FontWeight.w500,
          letterSpacing: 2.5 * s,
          color: const Color(0xFF1A1A1A),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final dx = (w - tp.width) / 2;
    final dy = h * 0.74;
    tp.paint(canvas, Offset(dx, dy));

    final lineY = dy + tp.height / 2;
    final paint = Paint()
      ..color = const Color(0xFF1A1A1A).withValues(alpha: 0.55)
      ..strokeWidth = 1.1 * s;

    canvas.drawLine(Offset(w * 0.16, lineY), Offset(dx - 12 * s, lineY), paint);
    canvas.drawLine(
      Offset(dx + tp.width + 12 * s, lineY),
      Offset(w * 0.84, lineY),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _SplashPainter old) => old.t != t;
}
