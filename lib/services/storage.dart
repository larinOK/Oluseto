import 'dart:io' as io;
import 'dart:math';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:meme_cloud/firebase_collection.dart';
import 'package:meme_cloud/models/photo_item.dart';
import 'package:path_provider/path_provider.dart';

class Storage {
  final bool _isLoading = false;
  final FirebaseCollection firebaseCollection;
  late FirebaseStorage _storage;
  late User? user;

  Storage({required this.firebaseCollection}) {
    _storage = firebaseCollection.firebaseStorage;
    user = firebaseCollection.firebaseAuth.currentUser;
  }

  Future<String> uploadFileWithTag(
      io.File file, String tag, String keyString) async {
    var userID = user!.uid;
    //int size = 0;

    // ListResult result = await firebaseCollection.firebaseStorage
    //     .ref()
    //     .child("user/uploads/${userID.toString()}/${tag}/")
    //     .listAll();

    // for (var item in result.items) {
    //   size++;
    // }

    var storageRef = _storage
        .ref()
        .child("user/uploads/${userID.toString()}/${tag}/${keyString}");
    UploadTask uploadTask = storageRef.putFile(file);
    var downloadUrl = await (await uploadTask).ref.getDownloadURL();
    return downloadUrl;
  }

  Future<String> uploadFileToGeneral(io.File file, String keyString) async {
    var userID = user!.uid;
    int size = 0;

    ListResult result = await firebaseCollection.firebaseStorage
        .ref()
        .child("user/uploads/${userID.toString()}/AllUploads/")
        .listAll();

    for (var item in result.items) {
      size++;
    }

    var storageRef = _storage
        .ref()
        .child("user/uploads/${userID.toString()}/AllUploads/${keyString}");
    UploadTask uploadTask = storageRef.putFile(file);
    var downloadUrl = await (await uploadTask).ref.getDownloadURL();
    return downloadUrl;
  }

  Future<String> uploadBytes(Uint8List fileBytes) async {
    var userID = user!.uid;
    var storageRef = _storage.ref().child("user/profile/${userID.toString()}");
    UploadTask uploadTask = storageRef.putData(fileBytes);
    return await (await uploadTask).ref.getDownloadURL();
  }

  Future<String> getUserProfileImageUrl(String uid) async {
    var storageRef = (_storage.ref().child("user/profile/$uid"));
    var newUrl = (await storageRef.getDownloadURL());
    return newUrl.toString();
  }

  Future<String> downloadEmotionImageUrl(String emotion) async {
    var rng = Random();

    ListResult result =
        await firebaseCollection.firebaseStorage.ref(emotion).listAll();
    List<Reference> resultList = result.items;
    Reference test = resultList[rng.nextInt(resultList.length - 1)];
    return test.getDownloadURL();
  }

  Future<String> getImageURL(String imageName) async {
    String url = await firebaseCollection.firebaseStorage
        .ref(imageName)
        .getDownloadURL();
    return url;
  }

  deletePictureFromAll(String key) async {
    var storageRef = _storage
        .ref()
        .child("user/uploads/${user!.uid.toString()}/AllUploads/${key}");
    await storageRef.delete();
  }

  deleteFromTags(String key, List<dynamic> tags) async {
    tags.forEach((element) async {
      var storageRef = _storage.ref().child(
          "user/uploads/${user!.uid.toString()}/${element.toString()}/${key}");

      await storageRef.delete();
    });
  }

  deleteFromTag(String key, String tag) async {
    var storageRef = _storage
        .ref()
        .child("user/uploads/${user!.uid.toString()}/${tag}/${key}");

    await storageRef.delete();
  }

  addNewTag(PhotoItem item, String tag) async {
    String keyString = item.uniqueId;
    var userID = user!.uid;
    final urlImage = item.image;
    final url = Uri.parse(urlImage);
    final response = await http.get(url);
    final bytes = response.bodyBytes;

    final temp = await getTemporaryDirectory();
    final path = '${temp.path}/image.jpg';
    io.File file = io.File(path);

    var storageRef = _storage
        .ref()
        .child("user/uploads/${userID.toString()}/${tag}/${keyString}");
    UploadTask uploadTask = storageRef.putFile(file);
    // var downloadUrl = await (await uploadTask).ref.getDownloadURL();
    // return downloadUrl;
  }
}
