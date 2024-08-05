import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addMoon() {
    return _db.collection('moons').add({
      'name': 'test name of moon',
      'price': 12,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getMoons() {
    return _db.collection('moons').snapshots();
  }
}
