import 'package:cloud_firestore/cloud_firestore.dart';

class ScoreService {
  final CollectionReference scores =
      FirebaseFirestore.instance.collection('scores');

  Future<void> addScore(String name, int score) {
    return scores.add({
      'name': name,
      'score': score,
      'date': Timestamp.now(),
    });
  }

  Stream<QuerySnapshot> getScores() {
    return scores.orderBy('score', descending: true).snapshots();
  }

  Future<void> updateName(String id, String newName) {
    return scores.doc(id).update({'name': newName});
  }

  Future<void> deleteScore(String id) {
    return scores.doc(id).delete();
  }
}