import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meme_cloud/firebase_collection.dart';
import 'package:meme_cloud/models/photo_item.dart';
import 'package:meme_cloud/models/user.dart';

class DatabaseService {
  final String uid;
  final FirebaseCollection firebaseCollection;
  late CollectionReference collectionOfUsers;
  late CollectionReference collectionOfUserPosts;
  late CollectionReference collectionOfUserTags;
  List<PhotoItem> photos = [];
  List<String> userTags = [];

  DatabaseService({required this.uid, required this.firebaseCollection}) {
    collectionOfUsers =
        firebaseCollection.firebaseFirestore.collection("Users");
    collectionOfUserPosts = collectionOfUsers.doc(uid).collection("posts");
    collectionOfUserTags = collectionOfUsers.doc(uid).collection("tags");
  }

  Future updateUserData(String? fullName, String email) async {
    return await collectionOfUsers.doc(uid).set({
      'name': fullName,
      //'path': imagePath,
      'email': email,
    }, SetOptions(merge: true));
  }

  uploadPostToDatabase(String key, String link, List<String> tags) async {
    collectionOfUserPosts.doc(key).set({'link': link, 'tag': tags, 'id': key});
    var snapshot = await collectionOfUserPosts.get();
    for (var snap in snapshot.docs) {
      Map<String, dynamic> data = snap.data() as Map<String, dynamic>;
      var link = data['link'];
      var tag = data['tag'];

      for (var item in tag) {
        if (!userTags.contains(item.toString())) {
          print("found same");
          userTags.add(item.toString());
        }
      }

      await updateUserTagList(userTags);
    }
  }

  Future updateFirstLoad(bool firstLoad) async {
    return await collectionOfUsers.doc(uid).set({
      'firstLoad': firstLoad,
    }, SetOptions(merge: true));
  }

  Future updateUserTagList(List<String> tags) async {
    return await collectionOfUsers
        .doc(uid)
        .set({'tags': tags}, SetOptions(merge: true));
  }

  Future updateName(
    String? fullName,
  ) async {
    return await collectionOfUsers.doc(uid).set({
      'name': fullName,
    }, SetOptions(merge: true));
  }

  AppUserData _UserDataFromSnapshot(DocumentSnapshot snapshot) {
    return AppUserData(
        appUserId: uid,
        appUserName: snapshot['name'],
        firebaseCollection: firebaseCollection,
        email: snapshot['email'],
        //imagePath: snapshot['path'],
        firstLoad: snapshot['firstLoad']);
  }

  PhotoItem _PhotoInfoFromSnapshot(DocumentSnapshot snapshot) {
    PhotoItem item =
        PhotoItem(snapshot['link'], snapshot['tag'], snapshot['id']);

    return item;
  }

  Future<Stream<PhotoItem>> getPhotoData(String key) async {
    await collectionOfUserPosts.doc(key).snapshots().forEach((element) {});
    return collectionOfUserPosts
        .doc(key)
        .snapshots()
        .map(_PhotoInfoFromSnapshot);
  }

  Stream<AppUserData> get userData {
    return collectionOfUsers.doc(uid).snapshots().map(_UserDataFromSnapshot);
  }

  Stream<QuerySnapshot> get userList {
    return collectionOfUsers.snapshots();
  }

  // Future<void> loadUserPhotos() async {
  //   await collectionOfUserPosts.snapshots().forEach((element) {
  //     element.docs.forEach((element) {
  //       photos.add(PhotoItem(element.get('link'), element.get('tag')));
  //       print(photos.length);
  //       print(element.get('tag'));
  //       print(element.data());
  //     });
  //     // for (var element in element.docs) {
  //     //   photos.add(PhotoItem(element.get('link'), element.get('tag')));
  //     //   print(photos.length);
  //     //   print(element.get('tag'));
  //     //   print(element.data());
  //     // }
  //     print("pew" + photos.length.toString());
  //   });
  // }

  Future<List<PhotoItem>> getUserPosts() async {
    //await loadUserPhotos();

    // print(await collectionOfUserPosts.snapshots().toList());

    // collectionOfUserPosts.snapshots().forEach((element) async {
    //   for (var element in element.docs) {
    //     photos.add(PhotoItem(element.get('link'), element.get('tag')));
    //     print(photos.length);
    //     print(element.get('tag'));
    //     print(element.data());
    //   }
    //   // for (var element in element.docs) {
    //   //   photos.add(PhotoItem(element.get('link'), element.get('tag')));
    //   //   print(photos.length);
    //   //   print(element.get('tag'));
    //   //   print(element.data());
    //   // }
    //   print("pew" + photos.length.toString());
    // });

    var snapshot = await collectionOfUserPosts.get();
    for (var snap in snapshot.docs) {
      Map<String, dynamic> data = snap.data() as Map<String, dynamic>;
      var link = data['link'];
      var tag = data['tag'];
      var id = data['id'];

      photos.add(new PhotoItem(link, tag, id));
    }

    return photos;
  }

  Future<dynamic> getUserTags() async {
    var snapshot = await collectionOfUsers.doc(uid).get();
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    var tags = data["tags"];

    return tags;
  }

  Future<List<PhotoItem>> getPostsWithTag(String tag) async {
    List<PhotoItem> photos = [];

    await collectionOfUserPosts
        .where("tag", arrayContains: tag)
        .get()
        .then((value) => {
              value.docs.forEach((element) {
                Map<String, dynamic> data =
                    element.data() as Map<String, dynamic>;

                photos.add(PhotoItem(data['link'], data['tag'], data['id']));
              })
            });

    //print(photos.length);
    return photos;
  }

  Future<List<PhotoItem>> getPostsForEachTag(List<String> tags) async {
    List<PhotoItem> photos = [];
    for (var tag in tags) {
      await collectionOfUserPosts
          .where("tag", arrayContains: tag)
          .get()
          .then((value) => {
                value.docs.forEach((element) {
                  Map<String, dynamic> data =
                      element.data() as Map<String, dynamic>;

                  photos.add(PhotoItem(data['link'], data['tag'], data['id']));
                })
              });

      //print(photos.length);

    }
    return photos;
  }

  Future<List<PhotoItem>> filterPhotos(List<String> wantedTags) async {
    List<PhotoItem> photos = [];

    await collectionOfUserPosts
        .where("tag", arrayContains: wantedTags[0])
        .get()
        .then((value) => {
              value.docs.forEach((element) {
                Map<String, dynamic> data =
                    element.data() as Map<String, dynamic>;

                photos.add(PhotoItem(data['link'], data['tag'], data['id']));
              })
            });

    wantedTags.remove(wantedTags[0]);
    // for (var photo in photos) {
    //   for (var tag in wantedTags) {
    //     if (!photo.tags.contains(tag)) {}
    //   }

    //photos.every((element) => false)

    photos.retainWhere((photo) {
      return wantedTags.every((tag) => photo.tags.contains(tag));
    });
    print("oboy2" + photos.length.toString());

    return photos;
  }

  Future<List<PhotoItem>> filterPhotos2(List<String> wantedTags) async {
    List<PhotoItem> photos = [];

    await collectionOfUserPosts.get().then((value) => {
          value.docs.forEach((element) {
            Map<String, dynamic> data = element.data() as Map<String, dynamic>;

            photos.add(PhotoItem(data['link'], data['tag'], data['id']));
          })
        });

    //wantedTags.remove(wantedTags[0]);
    // for (var photo in photos) {
    //   for (var tag in wantedTags) {
    //     if (!photo.tags.contains(tag)) {}
    //   }

    //photos.every((element) => false)

    photos.retainWhere((photo) {
      return wantedTags.every((tag) => photo.tags.contains(tag));
    });

    return photos;
  }

  deletePhoto(String key) {
    collectionOfUserPosts.doc(key).delete();
  }

  delePhotoFromTag(String key, String tag) async {
    PhotoItem photo =
        _PhotoInfoFromSnapshot(await collectionOfUserPosts.doc(key).get());

    List<dynamic> newTagList = photo.tags;
    newTagList.removeWhere((element) => element == tag);

    collectionOfUserPosts.doc(key).update({"tag": newTagList});
  }

  addTagToPhoto(String key, String tag) async {
    PhotoItem photo =
        _PhotoInfoFromSnapshot(await collectionOfUserPosts.doc(key).get());

    List<dynamic> newTagList = photo.tags;
    newTagList.add(tag);

    collectionOfUserPosts.doc(key).update({"tag": newTagList});
  }

  Future<List<String>> getMostPopularTags() async {
    PhotoItem item;
    Map<String, int> map = {};
    List<dynamic> usertags = await getUserTags() as List<dynamic>;

    for (var tag in usertags) {
      List<PhotoItem> photos = [];
      await collectionOfUserPosts
          .where("tag", arrayContains: tag.toString())
          .get()
          .then((value) => {
                value.docs.forEach((element) {
                  Map<String, dynamic> data =
                      element.data() as Map<String, dynamic>;
                  item = PhotoItem(data['link'], data['tag'], data['id']);
                  photos.add(item);
                }),
                map[tag.toString()] = photos.length
              });

      //print(photos.length);

    }
    List<String> keys = map.keys.toList();
    keys.sort((a, b) => map[a]!.compareTo(map[b]!.toInt()));
    print(keys.reversed);

    return keys.reversed.toList().getRange(0, 6).toList();
  }

  Future<Map<String, PhotoItem>> getRandomPhotoForTags(
      List<String> tags) async {
    Map<String, PhotoItem> map = {};

    for (var tag in tags) {
      List<PhotoItem> photos = [];
      int intValue;
      await collectionOfUserPosts
          .where("tag", arrayContains: tag)
          .get()
          .then((value) => {
                value.docs.forEach((element) {
                  Map<String, dynamic> data =
                      element.data() as Map<String, dynamic>;

                  photos.add(PhotoItem(data['link'], data['tag'], data['id']));
                }),
                intValue = Random().nextInt(photos.length),
                map[tag] = photos[intValue]
              });

      //print(photos.length);

    }
    return map;
  }

  Future<Map<String, PhotoItem>> getRandomPhotoForDynamicTags(
      List<dynamic> tags) async {
    Map<String, PhotoItem> map = {};

    for (var tag in tags) {
      List<PhotoItem> photos = [];
      int intValue;
      await collectionOfUserPosts
          .where("tag", arrayContains: tag.toString())
          .get()
          .then((value) => {
                value.docs.forEach((element) {
                  Map<String, dynamic> data =
                      element.data() as Map<String, dynamic>;

                  photos.add(PhotoItem(data['link'], data['tag'], data['id']));
                }),
                intValue = Random().nextInt(photos.length),
                map[tag.toString()] = photos[intValue]
              });

      //print(photos.length);

    }
    return map;
  }

  Future<Map<String, PhotoItem>> getCarouselData() async {
    return getRandomPhotoForTags(await getMostPopularTags());
  }

  Future<Map<String, PhotoItem>> getTagDisplayData() async {
    var list = await getUserTags() as List<dynamic>;
    return getRandomPhotoForDynamicTags(list);
  }
}
