import 'package:cloud_firestore/cloud_firestore.dart';

class DBFireStore {
  DBFireStore._();
  static final DBFireStore _instance = DBFireStore._();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static FirebaseFirestore get() {
    return DBFireStore._instance._firestore;
  }
}
