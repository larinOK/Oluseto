import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:meme_cloud/services/database.dart';
import 'package:meme_cloud/firebase_collection.dart';
import 'package:meme_cloud/models/user.dart';

class AuthFunction {
  final FirebaseCollection firebaseCollection;
  final String successMessage = "Success";

  AuthFunction({required this.firebaseCollection});

  Future<String> getCurrentUid() async {
    return (firebaseCollection.firebaseAuth.currentUser!.uid);
  }

  Stream<AppUser?> get player {
    return firebaseCollection.firebaseAuth
        .authStateChanges()
        .map((User? user) => appUserFromUser(user!));
  }

  AppUser? appUserFromUser(User? user) {
    return user != null ? AppUser(appUserId: user.uid) : null;
  }

  Future signUp(
      String nameInput, String emailInput, String passwordInput) async {
    try {
      UserCredential credentials = await firebaseCollection.firebaseAuth
          .createUserWithEmailAndPassword(
              email: emailInput, password: passwordInput);
      User? user = credentials.user;

      await DatabaseService(
              uid: user!.uid, firebaseCollection: firebaseCollection)
          .updateUserData(
        nameInput,
        // (await firebaseCollection.firebaseStorage
        //     .ref("PofilePicture/default profile.png")
        //     .getDownloadURL()),
        emailInput,
      );

      await DatabaseService(
              uid: user.uid, firebaseCollection: firebaseCollection)
          .updateFirstLoad(true);
      return appUserFromUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<String> login(String emailInput, String passwordInput) async {
    try {
      UserCredential credential = await firebaseCollection.firebaseAuth
          .signInWithEmailAndPassword(
              email: emailInput, password: passwordInput);

      AppUser? currentUser = appUserFromUser(credential.user);

      return successMessage;
    } catch (e) {
      print(e.toString());
      return e.toString();
    }
  }

  Future signOut() async {
    try {
      return await firebaseCollection.firebaseAuth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
