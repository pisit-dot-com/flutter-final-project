import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/score_service.dart';

// หน้าตารางคะแนน: แสดง / แก้ไข / ลบ
class ScoresPage extends StatelessWidget {
  const ScoresPage({super.key});

  // ---------- หน้าต่างแก้ชื่อ ----------
  void showEditDialog(BuildContext context, String id, String oldName) {
    final controller = TextEditingController(text: oldName);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('แก้ไขชื่อ'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              ScoreService().updateName(id, controller.text.trim()); // U
              Navigator.pop(dialogContext);
            },
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
  }

  // ---------- ลบ ----------
  void deleteScore(BuildContext context, String id) {
    ScoreService().deleteScore(id); // D
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ลบแล้ว')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff4f6fb0),
        foregroundColor: Colors.white,
        title: const Text('ตารางคะแนน (ทายธง)'),
      ),
      body: Center(
        // จอกว้างไม่ยืดเกิน 600
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          // StreamBuilder = ฟังข้อมูลจาก Firebase ตลอดเวลา
          child: StreamBuilder<QuerySnapshot>(
            stream: ScoreService().getScores(), // R
            builder: (context, snapshot) {
              // กำลังโหลด
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data!.docs;

              // ยังไม่มีข้อมูล
              if (docs.isEmpty) {
                return const Center(child: Text('ยังไม่มีคะแนน ไปเล่นเกมทายธงก่อนนะ'));
              }

              // แสดงรายการ
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final date = (data['date'] as Timestamp).toDate();

                  return Card(
                    child: ListTile(
                      // อันดับ
                      leading: CircleAvatar(child: Text('${index + 1}')),
                      // ชื่อ
                      title: Text(
                        data['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      // คะแนน + วันที่
                      subtitle: Text(
                        '${data['score']} / 10 คะแนน  •  ${date.day}/${date.month}/${date.year}',
                      ),
                      // ปุ่มแก้ไข / ลบ
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () =>
                                showEditDialog(context, doc.id, data['name']),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => deleteScore(context, doc.id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}