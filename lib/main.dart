import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/menu_page.dart';

// main เป็น async เพราะต้องรอเชื่อม Firebase ให้เสร็จก่อนเปิดแอป
void main() async {
  // ให้ Flutter พร้อมก่อน แล้วค่อยเชื่อม Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // เชื่อมกับ Firebase (ค่าตั้งค่าอยู่ในไฟล์ firebase_options.dart)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const MaterialApp(
      title: 'Guess Country',
      debugShowCheckedModeBanner: false,
      home: MenuPage(),
    ),
  );
}