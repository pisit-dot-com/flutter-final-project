import 'package:flutter/material.dart';
import '../models/region.dart';

class MapPainter extends CustomPainter {
  final List<Region> regions;
  final Set<String> guessed;

  MapPainter(this.regions, this.guessed);

  // ขยายขอบเขตละติจูดให้ครอบคลุมขั้วโลกใต้ (แอนตาร์กติกา) เต็มผืน
  static const minX = -180.0, maxX = 180.0;
  static const minY = -85.0, maxY = 85.0; 
  static double get aspectRatio => (maxX - minX) / (maxY - minY); // 360 / 170 ≈ 2.12

  @override
  void paint(Canvas canvas, Size size) {
    // สีพื้นผิวน้ำทะเล
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xffeef3f8),
    );

    final scale = size.height / (maxY - minY);

    Offset toScreen(Offset p) =>
        Offset((p.dx - minX) * scale, (maxY - p.dy) * scale);

    final border = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white
      ..strokeWidth = 0.5;

    for (final r in regions) {
      final path = Path();
      for (final ring in r.rings) {
        path.addPolygon(ring.map(toScreen).toList(), true);
      }

      final isGuessed = guessed.contains(r.id) ||
          guessed.contains(r.id.toLowerCase());

      final fill = Paint()
        ..color = isGuessed ? Colors.green : Colors.grey.shade400;

      canvas.drawPath(path, fill);
      canvas.drawPath(path, border);
    }
  }

  @override
  bool shouldRepaint(covariant MapPainter oldDelegate) => true;
}