import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseCollection {
  final FirebaseStorage firebaseStorage;
  final FirebaseFirestore firebaseFirestore;
  final FirebaseAuth firebaseAuth;

  FirebaseCollection(
      {required this.firebaseStorage,
      required this.firebaseFirestore,
      required this.firebaseAuth});
}
