import 'package:flutter/material.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_collection.dart';
import 'global_colours.dart';
import 'wrapper.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  FirebaseCollection firebaseCollection = FirebaseCollection(
      firebaseAuth: FirebaseAuth.instance,
      firebaseFirestore: FirebaseFirestore.instance,
      firebaseStorage: FirebaseStorage.instance);

  @override
  Widget build(BuildContext context) {
    Global globalColours = new Global();
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [globalColours.baseColour, Colors.white])),
          child: Center(
              child: Image.asset(
            'assets/images/icon.png',
            width: width * 0.70,
          ))),
    );
  }

  void _navigateToHome() async {
    await Future.delayed(Duration(milliseconds: 1500), () {});
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: ((context) =>
                Wrapper(firebaseCollection: firebaseCollection))));
  }
}
