import 'package:cloud_firestore/cloud_firestore.dart';

class ScoreDocument {
  final String nickname;
  final int score;

  ScoreDocument({
    required this.nickname,
    required this.score,
});
}

class Record {
  Record();
  
  final db = FirebaseFirestore.instance;
  
  void updateRecord(String uid, nickname, int currentScore) async {
    final doc = <String, dynamic>{
      'score': currentScore,
      'nickname': nickname,
    };
    await db.collection('record').doc(uid).set(doc);
  }

  Stream scoreOnSnapShot() {
    var roomRef = db
        .collection('record')
        .orderBy('score', descending: true);

    return roomRef.snapshots();
  }
}