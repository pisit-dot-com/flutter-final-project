import 'package:cloud_firestore/cloud_firestore.dart';

// จัดการข้อมูลคะแนนใน Firebase (CRUD)
class ScoreService {
  // ชี้ไปที่ "ตาราง" ชื่อ scores ใน Firebase
  final CollectionReference scores =
      FirebaseFirestore.instance.collection('scores');

  // C - Create: บันทึกคะแนนใหม่
  Future<void> addScore(String name, int score) {
    return scores.add({
      'name': name,
      'score': score,
      'date': Timestamp.now(),
    });
  }

  // R - Read: อ่านคะแนนทั้งหมด เรียงจากมากไปน้อย
  // (Stream = ข้อมูลเปลี่ยนเมื่อไหร่ หน้าจออัปเดตเองทันที)
  Stream<QuerySnapshot> getScores() {
    return scores.orderBy('score', descending: true).snapshots();
  }

  // U - Update: แก้ชื่อผู้เล่น
  Future<void> updateName(String id, String newName) {
    return scores.doc(id).update({'name': newName});
  }

  // D - Delete: ลบคะแนน
  Future<void> deleteScore(String id) {
    return scores.doc(id).delete();
  }
}