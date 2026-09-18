import 'package:flutter/material.dart';

class Region {
  final String id;
  final String name;
  final List<List<Offset>> rings;

  Region({required this.id, required this.name, required this.rings});
}