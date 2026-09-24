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
  final Set<String> guessed = {};

  final TextEditingController controller = TextEditingController();

  final TransformationController zoomController = TransformationController();

  Size mapSize = Size.zero;

  late Future<List<Region>> mapData;

  @override
  void initState() {
    super.initState();
    mapData = GeojsonService().loadRegions();
  }

  void checkAnswer(String value) {
    final answer = value.trim().toLowerCase();
    if (answer.isEmpty) return;

    setState(() {
      guessed.add(answer);
    });
    controller.clear();
  }

  void zoom(double factor) {
    final currentScale = zoomController.value.getMaxScaleOnAxis();
    final newScale = currentScale * factor;
    if (newScale < 1 || newScale > 20) return;

    final cx = mapSize.width / 2;
    final cy = mapSize.height / 2;

    final moveToOrigin = Matrix4.translationValues(-cx, -cy, 0);
    final scale = Matrix4.diagonal3Values(factor, factor, 1);
    final moveBack = Matrix4.translationValues(cx, cy, 0);

    zoomController.value = moveBack
        .multiplied(scale)
        .multiplied(moveToOrigin)
        .multiplied(zoomController.value);
  }

  void resetZoom() {
    zoomController.value = Matrix4.identity();
  }

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

  PreferredSizeWidget buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xff4f6fb0),
      foregroundColor: Colors.white,
      toolbarHeight: 60,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.public, color: Color(0xff4f6fb0), size: 28),
          ),
          const SizedBox(width: 10),
          const Text(
            'Guess Country',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

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

  Widget buildMap() {
    return FutureBuilder<List<Region>>(
      future: mapData,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            mapSize = constraints.biggest;

            return InteractiveViewer(
              transformationController: zoomController,
              minScale: 1,
              maxScale: 20,
              child: Center(
                child: AspectRatio(
                  aspectRatio: 2, 
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