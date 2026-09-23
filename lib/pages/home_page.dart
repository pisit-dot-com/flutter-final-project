import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/services.dart' show rootBundle;
import 'package:syncfusion_flutter_maps/maps.dart';
import '../models/region.dart';
import '../services/geojson_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Set<String> guessed = {};
  final TextEditingController controller = TextEditingController();

  List<Region>? _regions;
  bool _isLoading = true;
  String _shapeKey = 'name';

  // ตัวแปรควบคุมพิกัดและรอบการจัดกึ่งกลางของแผนที่
  int _mapKey = 0;
  MapLatLng _focalLatLng = const MapLatLng(15.0, 10.0);
  double _zoomLevel = 2.5;

  @override
  void initState() {
    super.initState();
    _loadRegions();
  }

  Future<void> _loadRegions() async {
    try {
      final text = await rootBundle.loadString('assets/countries.geojson');
      final data = jsonDecode(text);
      if (data['features'] != null && data['features'].isNotEmpty) {
        final props = data['features'][0]['properties'];
        if (props['name'] != null) {
          _shapeKey = 'name';
        } else if (props['ADMIN'] != null) {
          _shapeKey = 'ADMIN';
        }
      }

      final regionsData = await GeojsonService().loadRegions();
      if (mounted) {
        setState(() {
          _regions = regionsData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  int get totalCountries {
    if (_regions == null) return 0;
    return _regions!.map((r) => r.id).toSet().length;
  }

  // คำนวณหาจุดกึ่งกลาง (Latitude, Longitude) ของประเทศจากแผ่นดินใหญ่
  MapLatLng _calculateRegionCenter(Region region) {
    if (region.rings.isEmpty) {
      return const MapLatLng(15.0, 10.0);
    }

    // เลือก Polygon ที่มีจำนวนจุดมากที่สุด (แผ่นดินผืนใหญ่) เพื่อไม่ให้หลุดไปเกาะเล็ก
    List<Offset> mainRing = region.rings.first;
    for (final ring in region.rings) {
      if (ring.length > mainRing.length) {
        mainRing = ring;
      }
    }

    double sumLat = 0.0;
    double sumLng = 0.0;
    for (final p in mainRing) {
      sumLng += p.dx; // Longitude
      sumLat += p.dy; // Latitude
    }

    return MapLatLng(sumLat / mainRing.length, sumLng / mainRing.length);
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            '🎉 ยินดีด้วย! ชนะเกมแล้ว 🎉',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.emoji_events_rounded,
                color: Colors.amber,
                size: 80,
              ),
              const SizedBox(height: 16),
              Text(
                'คุณสามารถทายชื่อประเทศได้ครบทั้งหมด\n$totalCountries ประเทศแล้ว!',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, height: 1.4),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton.icon(
              icon: const Icon(Icons.replay_rounded),
              label: const Text('เล่นใหม่อีกครั้ง'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff4f6fb0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  guessed.clear();
                  _focalLatLng = const MapLatLng(15.0, 10.0);
                  _zoomLevel = 2.5;
                  _mapKey++;
                });
              },
            ),
          ],
        );
      },
    );
  }

  void checkAnswer(String value) {
    final input = value.trim().toLowerCase();
    if (input.isEmpty || _regions == null) return;

    Region? matchedRegion;
    for (final r in _regions!) {
      if (r.id.toLowerCase() == input) {
        matchedRegion = r;
        break;
      }
      try {
        final dynamic dyn = r;
        if (dyn.name != null &&
            dyn.name.toString().trim().toLowerCase() == input) {
          matchedRegion = r;
          break;
        }
      } catch (_) {}
    }

    if (matchedRegion != null) {
      final center = _calculateRegionCenter(matchedRegion);
      setState(() {
        guessed.add(matchedRegion!.id);
        // เลื่อนและซูมเข้ามาตรงกลางประเทศที่ทายถูก
        _focalLatLng = center;
        _zoomLevel = 3.8;
        _mapKey++; // สั่งอัปเดตตำแหน่งแผนที่อย่างสมบูรณ์โดยไม่ให้ Gesture พัง
      });
    } else {
      setState(() {
        guessed.add(input);
      });
    }

    controller.clear();

    if (totalCountries > 0 && guessed.length >= totalCountries) {
      Future.delayed(const Duration(milliseconds: 300), _showWinDialog);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  MapShapeSource _buildShapeSource() {
    return MapShapeSource.asset(
      'assets/countries.geojson',
      shapeDataField: _shapeKey,
      dataCount: _regions?.length ?? 0,
      primaryValueMapper: (int index) => _regions![index].name,
      shapeColorValueMapper: (int index) {
        final region = _regions![index];
        final isGuessed = guessed.contains(region.id) ||
            guessed.contains(region.id.toLowerCase()) ||
            guessed.contains(region.name.toLowerCase());
        return isGuessed ? Colors.green : Colors.grey.shade400;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: const Color(0xff4f6fb0),
        foregroundColor: Colors.white,
        toolbarHeight: isLandscape ? 48 : 60,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 8,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton.icon(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                ),
                icon: const Icon(CupertinoIcons.line_horizontal_3, size: 16),
                label: const Text("Menu", style: TextStyle(fontSize: 13)),
              ),
              TextButton.icon(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                ),
                icon: const Icon(CupertinoIcons.shuffle, size: 16),
                label: const Text("Random", style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
        ),
        actions: [
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(CupertinoIcons.flag_fill, size: 13, color: Colors.amberAccent),
                  const SizedBox(width: 4),
                  Text(
                    'Score: ${guessed.length}/${_isLoading ? "..." : totalCountries}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            icon: const Icon(CupertinoIcons.person_add_solid, size: 15),
            label: const Text("Create Account", style: TextStyle(fontSize: 13)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // 1. แผนที่โลกจาก Syncfusion (ผูก key เพื่อให้เลื่อนตำแหน่งได้ถูกต้อง)
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Container(
                  color: const Color(0xffeef3f8),
                  width: double.infinity,
                  height: double.infinity,
                  child: SfMaps(
                    key: ValueKey('sf_map_$_mapKey'),
                    layers: [
                      MapShapeLayer(
                        source: _buildShapeSource(),
                        zoomPanBehavior: MapZoomPanBehavior(
                          enablePinching: true,
                          enablePanning: true,
                          zoomLevel: _zoomLevel,
                          minZoomLevel: 1.8,
                          maxZoomLevel: 10.0,
                          focalLatLng: _focalLatLng,
                        ),
                        strokeColor: Colors.white,
                        strokeWidth: 0.6,
                        color: Colors.grey.shade400,
                      ),
                    ],
                  ),
                ),

          // 2. ช่องพิมพ์คำตอบลอยอยู่ด้านล่าง
          Positioned(
            left: 14,
            right: 14,
            bottom: isLandscape ? 8 : 14,
            child: SafeArea(
              top: false,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              hintText: 'พิมพ์ชื่อประเทศ แล้วกด Enter',
                              prefixIcon: Icon(
                                CupertinoIcons.search,
                                size: 18,
                                color: Colors.black54,
                              ),
                            ),
                            onSubmitted: checkAnswer,
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          height: 42,
                          child: ElevatedButton(
                            onPressed: () => checkAnswer(controller.text),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff4f6fb0),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 18),
                            ),
                            child: const Text(
                              'Enter',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}