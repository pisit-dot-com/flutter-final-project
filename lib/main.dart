import 'package:flutter/material.dart';
import 'pages/menu_page.dart';

void main() {
  runApp(
    const MaterialApp(
      title: 'Guess Country',
      debugShowCheckedModeBanner: false,
      home: MenuPage(), // เปิดแอปมาเจอหน้าเมนูก่อน
    ),
  );
}