import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meme_cloud/firebase_collection.dart';

class AppUser {
  final String appUserId;

  AppUser({required this.appUserId});
}

class AppUserData {
  final String appUserId;
  final String appUserName;
  final FirebaseCollection firebaseCollection;
  final String email;
  String imagePath;
  //late Storage store;
  bool firstLoad;
  late List<String> customTags;

  AppUserData(
      {required this.appUserId,
      required this.appUserName,
      required this.firebaseCollection,
      required this.email,
      this.imagePath = "",
      this.firstLoad = true}) {
    //store = Storage(firebaseCollection: firebaseCollection);
    //loadDefaults();
    customTags = [];
  }

  updateTagList(String tag) {
    customTags.add(tag);
  }

  getCustomTags() {
    return customTags;
  }

  // void loadDefaults() async {
  //   if (imagePath == "") {
  //     imagePath = await firebaseCollection.firebaseStorage
  //         .ref("PofilePicture/default profile.png")
  //         .getDownloadURL();
  //   }
  // }

  // Future<String> getImageUrl() async {
  //   imagePath = await store.getAppUserProfileImageUrl(appUserId);
  //   return imagePath;
  // }

  // Future<void> uploadProfilePicture() async {
  //   await store.uploadFile(File(imagePath));
  // }
}
