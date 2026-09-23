import 'package:flutter/material.dart';
import '../models/region.dart';
import '../services/geojson_service.dart';
import '../widgets/map_painter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // เก็บชื่อประเทศที่ทายถูกแล้ว
  final Set<String> guessed = {};

  // ตัวควบคุมช่องพิมพ์คำตอบ
  final TextEditingController controller = TextEditingController();

  // ตัวควบคุมการซูม (ข้างในเก็บค่าเป็น Matrix4)
  final TransformationController zoomController = TransformationController();

  // ขนาดของพื้นที่แผนที่ (ใช้หาจุดกลางตอนซูม)
  Size mapSize = Size.zero;

  // ข้อมูลแผนที่ (โหลดครั้งเดียวตอนเปิดหน้า)
  late Future<List<Region>> mapData;

  @override
  void initState() {
    super.initState();
    mapData = GeojsonService().loadRegions();
  }

  // ---------- ตรวจคำตอบ ----------
  void checkAnswer(String value) {
    final answer = value.trim().toLowerCase();
    if (answer.isEmpty) return;

    setState(() {
      guessed.add(answer);
    });
    controller.clear();
  }

  // ---------- ซูมโดยใช้ Matrix ----------
  // factor มากกว่า 1 = ซูมเข้า, น้อยกว่า 1 = ซูมออก
  void zoom(double factor) {
    // เช็คว่าซูมแล้วไม่เกินขอบเขต (1 ถึง 20 เท่า)
    final currentScale = zoomController.value.getMaxScaleOnAxis();
    final newScale = currentScale * factor;
    if (newScale < 1 || newScale > 20) return;

    // หาจุดกลางของแผนที่
    final cx = mapSize.width / 2;
    final cy = mapSize.height / 2;

    // ขั้น 1: เลื่อนจุดกลางไปที่ (0,0)
    final moveToOrigin = Matrix4.translationValues(-cx, -cy, 0);
    // ขั้น 2: ขยาย/ย่อ
    final scale = Matrix4.diagonal3Values(factor, factor, 1);
    // ขั้น 3: เลื่อนกลับที่เดิม
    final moveBack = Matrix4.translationValues(cx, cy, 0);

    // รวมทั้งหมด: moveBack × scale × moveToOrigin × เมทริกซ์เดิม
    // (คูณจากขวาไปซ้าย = ทำขั้น 1 ก่อน แล้ว 2 แล้ว 3)
    zoomController.value = moveBack
        .multiplied(scale)
        .multiplied(moveToOrigin)
        .multiplied(zoomController.value);
  }

  // กลับเป็นขนาดปกติ (Identity Matrix = ไม่ซูม ไม่เลื่อน)
  void resetZoom() {
    zoomController.value = Matrix4.identity();
  }

  // ---------- หน้าจอหลัก ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: Column(
        children: [
          buildAnswerBox(),
          Text('ทายถูกแล้ว ${guessed.length} ประเทศ'),
          Expanded(child: buildMap()),
        ],
      ),
      floatingActionButton: buildZoomButtons(),
    );
  }

  // ---------- แถบด้านบน: โลโก้ + ชื่อแอป ----------
  PreferredSizeWidget buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xff4f6fb0),
      foregroundColor: Colors.white,
      toolbarHeight: 60,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // โลโก้
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.public, color: Color(0xff4f6fb0), size: 28),
          ),
          const SizedBox(width: 10),
          // ชื่อแอป
          const Text(
            'Guess Country',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ---------- ช่องพิมพ์คำตอบ ----------
  Widget buildAnswerBox() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: controller,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'พิมพ์ชื่อประเทศ แล้วกด Enter',
        ),
        onSubmitted: checkAnswer,
      ),
    );
  }

  // ---------- แผนที่ ----------
  Widget buildMap() {
    return FutureBuilder<List<Region>>(
      future: mapData,
      builder: (context, snapshot) {
        // ยังโหลดไม่เสร็จ แสดงวงกลมหมุน
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        // LayoutBuilder บอกขนาดพื้นที่ที่แผนที่ได้รับ
        return LayoutBuilder(
          builder: (context, constraints) {
            mapSize = constraints.biggest;

            // InteractiveViewer ทำให้ถ่างนิ้ว/หมุนลูกกลิ้งเมาส์เพื่อซูมได้
            return InteractiveViewer(
              transformationController: zoomController,
              minScale: 1,
              maxScale: 20,
              child: Center(
                child: AspectRatio(
                  aspectRatio: 2, // แผนที่โลกกว้าง 2 เท่าของความสูง
                  // RepaintBoundary = วาดแผนที่ครั้งเดียวแล้วเก็บเป็นภาพไว้
                  // ตอนซูม/ลาก แค่ขยาย/เลื่อนภาพเดิม ไม่ต้องวาดใหม่
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: MapPainter(snapshot.data!, guessed),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ---------- ปุ่มซูม มุมขวาล่าง ----------
  Widget buildZoomButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton.small(
          heroTag: 'zoomIn',
          onPressed: () => zoom(1.5), // ซูมเข้า 1.5 เท่า
          child: const Icon(Icons.add),
        ),
        const SizedBox(height: 8),
        FloatingActionButton.small(
          heroTag: 'zoomOut',
          onPressed: () => zoom(1 / 1.5), // ซูมออก
          child: const Icon(Icons.remove),
        ),
        const SizedBox(height: 8),
        FloatingActionButton.small(
          heroTag: 'reset',
          onPressed: resetZoom,
          child: const Icon(Icons.zoom_out_map),
        ),
      ],
    );
  }
}