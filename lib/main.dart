import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:meme_cloud/services/auth_function.dart';
import 'package:meme_cloud/firebase_collection.dart';
import 'package:meme_cloud/firebase_options.dart';
import 'package:meme_cloud/screens/home_screen.dart';
import 'package:meme_cloud/screens/upload.dart';
import 'package:meme_cloud/models/user.dart';
import 'package:meme_cloud/wrapper.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseCollection firebaseCollection = FirebaseCollection(
      firebaseAuth: FirebaseAuth.instance,
      firebaseFirestore: FirebaseFirestore.instance,
      firebaseStorage: FirebaseStorage.instance);
  runApp(MyApp(
    firebaseCollection: firebaseCollection,
  ));
}

class MyApp extends StatelessWidget {
  final FirebaseCollection firebaseCollection;
  MyApp({Key? key, required this.firebaseCollection}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<AppUser?>.value(
        catchError: (_, __) => null,
        value: AuthFunction(firebaseCollection: firebaseCollection).player,
        initialData: null,
        child: MaterialApp(
            home: Wrapper(
          firebaseCollection: firebaseCollection,
        )));
  }
}
