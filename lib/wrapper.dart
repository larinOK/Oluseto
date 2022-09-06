import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meme_cloud/screens/authentication_screen.dart';
import 'package:meme_cloud/services/database.dart';
import 'package:meme_cloud/screens/display.dart';
import 'package:meme_cloud/firebase_collection.dart';
import 'package:meme_cloud/screens/home_page.dart';
import 'package:meme_cloud/screens/home_screen.dart';
import 'package:meme_cloud/screens/upload.dart';
import 'package:meme_cloud/models/user.dart';
import 'package:provider/provider.dart';

import 'loading.dart';

class Wrapper extends StatelessWidget {
  final FirebaseCollection firebaseCollection;

  const Wrapper({Key? key, required this.firebaseCollection}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appUser = Provider.of<AppUser?>(context);

    if (appUser == null) {
      return AuthenticationScreen(firebaseCollection: firebaseCollection);
    } else {
      return StreamBuilder<AppUserData?>(
        stream: DatabaseService(
                uid: appUser.appUserId, firebaseCollection: firebaseCollection)
            .userData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            AppUserData? appUserData = snapshot.data;

            return HomePage(firebaseCollection: firebaseCollection);
            // HomeScreen(
            //   key: key,
            //   firebaseCollection: firebaseCollection,
            // );
            // RouteOne(
            //   firebaseCollection: firebaseCollection,
            // );

            //     ImPred(
            //   firebaseCollection: firebaseCollection,
            // );
          } else {
            return Loading();
          }
        },
      );
    }
  }
}
