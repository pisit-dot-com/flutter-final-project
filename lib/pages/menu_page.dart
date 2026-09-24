import 'package:flutter/material.dart';
import 'home_page.dart';
import 'flag_quiz_page.dart';
import 'members_page.dart';
import 'scores_page.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  void openPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffeef3f8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Icon(Icons.public, size: 80, color: Color(0xff4f6fb0)),
                const Text(
                  'Guess Country',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const Text('เลือกเกมที่อยากเล่น'),
                const SizedBox(height: 30),

                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: [
                    buildMenuCard(
                      icon: Icons.map,
                      title: 'เกมแผนที่โลก',
                      subtitle: 'พิมพ์ชื่อประเทศให้ครบทั้งโลก',
                      color: Colors.green,
                      onTap: () => openPage(context, const HomePage()),
                    ),
                    buildMenuCard(
                      icon: Icons.flag,
                      title: 'ทายธงชาติ',
                      subtitle: 'ดูธงแล้วทายชื่อประเทศ 10 ข้อ',
                      color: Colors.orange,
                      onTap: () => openPage(context, const FlagQuizPage()),
                    ),
                    buildMenuCard(
                      icon: Icons.leaderboard,
                      title: 'ตารางคะแนน',
                      subtitle: 'ดู แก้ไข ลบ คะแนน',
                      color: Colors.blue,
                      onTap: () => openPage(context, const ScoresPage()),
                    ),
                    buildMenuCard(
                      icon: Icons.group,
                      title: 'สมาชิกกลุ่ม',
                      subtitle: 'ผู้จัดทำโปรเจค',
                      color: Colors.purple,
                      onTap: () => openPage(context, const MembersPage()),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // การ์ดเมนู 1 อัน
  Widget buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 260,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: color,
                  child: Icon(icon, size: 34, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}