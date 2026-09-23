import 'package:flutter/material.dart';
import '../models/region.dart';

// วาดแผนที่โลกจากข้อมูลพิกัดของแต่ละประเทศ
class MapPainter extends CustomPainter {
  final List<Region> regions; // ข้อมูลทุกประเทศ
  final Set<String> guessed;  // ประเทศที่ทายถูกแล้ว

  MapPainter(this.regions, this.guessed);

  @override
  void paint(Canvas canvas, Size size) {
    // พิกัดโลก: ลองจิจูด -180 ถึง 180, ละติจูด -90 ถึง 90
    const minX = -180.0, maxX = 180.0, minY = -90.0, maxY = 90.0;

    // หาอัตราส่วนขยาย ให้แผนที่พอดีกับพื้นที่วาด
    final scaleX = size.width / (maxX - minX);
    final scaleY = size.height / (maxY - minY);
    final scale = scaleX < scaleY ? scaleX : scaleY;

    // แปลงพิกัดโลก (ลองจิจูด, ละติจูด) เป็นตำแหน่งบนจอ
    // ละติจูดต้องกลับด้าน เพราะบนจอแกน y ชี้ลง
    Offset toScreen(Offset p) =>
        Offset((p.dx - minX) * scale, (maxY - p.dy) * scale);

    // สีเส้นขอบประเทศ
    final border = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white
      ..strokeWidth = 0.3;

    // วาดทีละประเทศ
    for (final r in regions) {
      final path = Path();
      for (final ring in r.rings) {
        path.addPolygon(ring.map(toScreen).toList(), true);
      }

      // ทายถูกแล้ว = สีเขียว, ยังไม่ถูก = สีเทา
      final fill = Paint()
        ..color = guessed.contains(r.id) ? Colors.green : Colors.grey.shade400;

      canvas.drawPath(path, fill);
      canvas.drawPath(path, border);
    }
  }

  // วาดใหม่ทุกครั้งที่หน้าจออัปเดต (เช่น ตอนทายถูก)
  @override
  bool shouldRepaint(MapPainter old) => true;
}