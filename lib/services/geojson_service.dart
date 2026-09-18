import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/region.dart';

class GeojsonService {
  Future<List<Region>> loadRegions() async {
    final text = await rootBundle.loadString('assets/countries.geojson');
    final data = jsonDecode(text);
    final regions = <Region>[];

    for (final f in data['features']) {
      final geom = f['geometry'];
      final polygons = geom['type'] == 'Polygon'
          ? [geom['coordinates']]
          : geom['coordinates'];

      final rings = <List<Offset>>[];
      for (final polygon in polygons) {
        final outer = polygon[0];
        rings.add([
          for (final p in outer) Offset(p[0].toDouble(), p[1].toDouble()),
        ]);
      }

      final props = f['properties'];
      final name = (props['name'] ?? props['ADMIN'] ?? 'unknown').toString();
      regions.add(Region(id: name.toLowerCase(), name: name, rings: rings));
    }
    return regions;
  }
}