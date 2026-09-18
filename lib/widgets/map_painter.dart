import 'package:flutter/material.dart';
import '../models/region.dart';

class MapPainter extends CustomPainter {
  final List<Region> regions;
  final Set<String> guessed;

  MapPainter(this.regions, this.guessed);

  @override
  void paint(Canvas canvas, Size size) {
    const minX = -180.0, maxX = 180.0, minY = -90.0, maxY = 90.0;
    final scale = [
      size.width / (maxX - minX),
      size.height / (maxY - minY),
    ].reduce((a, b) => a < b ? a : b);

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
      final fill = Paint()
        ..color = guessed.contains(r.id) ? Colors.green : Colors.grey.shade400;
      canvas.drawPath(path, fill);
      canvas.drawPath(path, border);
    }
  }

  @override
  bool shouldRepaint(MapPainter old) => old.guessed != guessed;
}