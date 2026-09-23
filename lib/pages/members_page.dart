import 'package:flutter/material.dart';

// หน้าแสดงข้อมูลสมาชิกกลุ่ม
class MembersPage extends StatelessWidget {
  const MembersPage({super.key});

  // ข้อมูลสมาชิก (แก้ชื่อ/รหัสตรงนี้)
  final List<Map<String, String>> members = const [
    {
      'name': 'ชื่อ นามสกุล คนที่ 1',
      'id': '6xxxxxxxxx',
      'role': 'ออกแบบหน้าจอ, ระบบแผนที่',
    },
    {
      'name': 'ชื่อ นามสกุล คนที่ 2',
      'id': '6xxxxxxxxx',
      'role': 'Database, เรียก API',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff4f6fb0),
        foregroundColor: Colors.white,
        title: const Text('สมาชิกกลุ่ม'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          // Wrap = วางการ์ดเรียงกัน ถ้าจอไม่พอจะขึ้นบรรทัดใหม่เอง
          // จอคอม: การ์ดอยู่ข้างกัน / จอมือถือ: การ์ดอยู่บนล่าง
          child: Wrap(
            spacing: 20,     // ระยะห่างแนวนอน
            runSpacing: 20,  // ระยะห่างแนวตั้ง
            alignment: WrapAlignment.center,
            children: [
              for (final m in members) buildMemberCard(m),
            ],
          ),
        ),
      ),
    );
  }

  // การ์ดของสมาชิก 1 คน
  Widget buildMemberCard(Map<String, String> member) {
    return SizedBox(
      width: 280,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // รูปโปรไฟล์ (ใช้ไอคอนแทนรูป)
              const CircleAvatar(
                radius: 45,
                backgroundColor: Color(0xff4f6fb0),
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 16),

              // ชื่อ
              Text(
                member['name']!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),

              // รหัสนิสิต
              Text(
                'รหัสนิสิต ${member['id']}',
                style: const TextStyle(color: Colors.grey),
              ),
              const Divider(height: 24),

              // หน้าที่ในโปรเจค
              Text(
                member['role']!,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}