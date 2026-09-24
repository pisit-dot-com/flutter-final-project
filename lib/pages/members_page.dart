import 'package:flutter/material.dart';

class MembersPage extends StatelessWidget {
  const MembersPage({super.key});

  final List<Map<String, String>> members = const [
    {
      'name': 'นายพิศิษฐ์ หาสุข',
      'id': '6721652463',
      'role': 'ออกแบบหน้าจอ, ระบบแผนที่',
      'image': 'assets/images/skibidi.jpg',
    },
    {
      'name': 'นายสิรภพ ศรีชัย',
      'id': '6721652722',
      'role': 'Database, เรียก API',
      'image': 'assets/images/tung_tung.jpg',
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xffa8c8ff),
              Color(0xffeef3f8),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: [
                for (final m in members) buildMemberCard(m),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
              CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage(member['image']!),
              ),
              const SizedBox(height: 16),

              Text(
                member['name']!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),

              Text(
                'รหัสนิสิต ${member['id']}',
                style: const TextStyle(color: Colors.grey),
              ),
              const Divider(height: 24),

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