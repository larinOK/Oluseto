import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:meme_cloud/firebase_collection.dart';
import 'package:meme_cloud/login_screen.dart';
import 'package:meme_cloud/signup_screen.dart';

class AuthenticationScreen extends StatefulWidget {
  final FirebaseCollection firebaseCollection;
  const AuthenticationScreen({Key? key, required this.firebaseCollection})
      : super(key: key);

  @override
  _AuthenticationScreenState createState() =>
      _AuthenticationScreenState(firebaseCollection: firebaseCollection);
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  var authToggle = true;
  final FirebaseCollection firebaseCollection;
  _AuthenticationScreenState({required this.firebaseCollection});

  void toggleAuth() {
    setState(() {
      authToggle = !authToggle;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (authToggle) {
      return LoginScreen(
          toggle: toggleAuth, firebaseCollection: firebaseCollection);
    } else {
      return SignUpScreen(
          toggle: toggleAuth, firebaseCollection: firebaseCollection);
    }
  }
}
