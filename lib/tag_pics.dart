// ignore_for_file: prefer_const_constructors

import 'dart:collection';
import 'dart:io' as io;
import 'package:http/http.dart' as http;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meme_cloud/auth_function.dart';
import 'package:meme_cloud/database.dart';
import 'package:meme_cloud/display.dart';
import 'package:meme_cloud/photo_item.dart';
import 'package:meme_cloud/pop_up_menu.dart';
import 'package:meme_cloud/storage.dart';
import 'package:meme_cloud/view_tags.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

import 'firebase_collection.dart';
import 'dart:math';

import 'home_screen.dart';
import 'tile.dart';

class TagPictures extends StatefulWidget {
  final FirebaseCollection firebaseCollection;
  final String tag;
  const TagPictures(
      {Key? key, required this.firebaseCollection, required this.tag})
      : super(key: key);

  @override
  State<TagPictures> createState() =>
      TagPicturesState(firebaseCollection: firebaseCollection, tag: tag);
}

class TagPicturesState extends State<TagPictures> {
  final FirebaseCollection firebaseCollection;
  late User? user;
  late AuthFunction _auth;
  final String tag;
  List<Widget> tileList = [];
  bool selectActivated = false;
  String keyString = "";
  List<io.File> files = [];
  String timeString = "";
  final picker = ImagePicker();
  bool pickedFromGallery = false;
  bool _isLoading = true;
  bool picked = false;
  io.File _image = io.File("");
  DateTime now = DateTime.now();
  bool edit = false;

  TagPicturesState({required this.firebaseCollection, required this.tag}) {
    _auth = AuthFunction(firebaseCollection: firebaseCollection);
    user = firebaseCollection.firebaseAuth.currentUser;
  }

  List<Widget> loadPhotos(List<PhotoItem> list) {
    List<Widget> babyList = [];

    list.forEach((element) {
      babyList.add(GestureDetector(
        // onTap: () {
        //   Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //           builder: (context) =>
        //               RouteTwo(image: element.image, tags: element.tags)));
        // },
        onTap: edit
            ? () {
                doMultiSelection(element);
              }
            : () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RouteTwo(
                              firebaseCollection: firebaseCollection,
                              item: element,
                            )));
              },
        child: StaggeredGridTile.count(
            crossAxisCellCount: 5,
            mainAxisCellCount: 5,
            child: Stack(children: [
              Tile(
                index: babyList.length + 1,
                photo: element,
                backgroundColor: Colors.black.withOpacity(selectedImages
                        .any((photo) => photo.uniqueId == element.uniqueId)
                    ? 1
                    : 0),
              ),
              Visibility(
                visible: selectedImages.any((photo) => photo.equals(element)),
                child: Align(
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              )
            ])),
      ));
      tileList = babyList;
    });
    return tileList;
  }

  List<Widget> getPhotos(String tag) {
    List<Widget> babyList = [];

    DatabaseService(uid: user!.uid, firebaseCollection: firebaseCollection)
        .getPostsWithTag(tag)
        .then((value) => value.forEach((element) {
              babyList.add(GestureDetector(
                onLongPress: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RouteTwo(
                                firebaseCollection: firebaseCollection,
                                item: element,
                              )));
                },
                onTap: () {
                  doMultiSelection(element);
                },
                child: StaggeredGridTile.count(
                  crossAxisCellCount: 5,
                  mainAxisCellCount: 5,
                  child: Stack(children: [
                    Tile(
                      index: babyList.length + 1,
                      photo: element,
                      backgroundColor: Colors.black.withOpacity(
                          selectedImages.contains(element) ? 1 : 0),
                    ),
                    Visibility(
                      visible: selectedImages.contains(element),
                      child: Align(
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    )
                  ]),
                ),
              ));
              tileList = babyList;
            }));

    return tileList;
  }

  List<PhotoItem> selectedImages = [];

  HashSet selected = HashSet();

  pickImage() async {
    var image = await picker.pickImage(source: ImageSource.camera);
    //picker.pickVideo(source: ImageSource.gallery);
    if (image == null) return null;

    setState(() {
      picked = true;
      _isLoading = false;

      _image = io.File(image.path);
    });
  }

  pickGalleryImage() async {
    files.clear();
    //XFile? image = await picker.pickImage(source: ImageSource.gallery);
    List<XFile>? images = await picker.pickMultiImage();

    //if (image == null) return null;

    setState(() {
      picked = true;
      _isLoading = false;
      //_image = File(image!.path);

      images!.forEach((element) {
        files.add(io.File(element.path));
      });
      pickedFromGallery = true;

      //files = images!.map((e) => File(e.path)).toList();
    });
  }

  Widget buildImage(io.File carouselImage, int index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12),
      color: Colors.grey,
      child: Image(image: FileImage(carouselImage)),
    );
  }

  List<String> collectTags(String str) {
    // if (str.trim().isEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //       content: Text("Your password has been changed"),
    //       duration: Duration(milliseconds: 750)));
    //   print("why");
    // } else {}
    var tags = str.split(',');

    // for (var item in tags) {
    //   if (item.trim().isEmpty) {
    //     tags.remove(item);
    //   }
    // }

    tags.removeWhere((element) => element.trim().isEmpty);

    return tags;
  }

  doUploads(
      TextEditingController _addTagContoller, List<io.File> uploadFiles) async {
    timeString = now.day.toString() +
        now.month.toString() +
        now.year.toString() +
        now.hour.toString() +
        now.minute.toString() +
        now.second.toString();
    keyString = timeString + "-" + user!.uid;
    String url;
    var listOfTags = collectTags(_addTagContoller.text);
    if (listOfTags.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Tags Cannot Be Empty. Please Try Again"),
          duration: Duration(milliseconds: 750)));
    } else {
      for (int i = 0; i < uploadFiles.length; i++) {
        // uploadFiles.forEach((uploadFile) async {
        var photo = PhotoItem(
            uploadFiles[i].path, listOfTags, keyString + "-" + i.toString());
        Storage storage = Storage(firebaseCollection: firebaseCollection);
        listOfTags.forEach((element) async {
          var thing = (await storage.uploadFileWithTag(
              uploadFiles[i],
              element.trim().toLowerCase().trim(),
              keyString + "-" + i.toString()));

          setState(() {
            now = DateTime.now();
          });
          DatabaseService(
                  uid: user!.uid, firebaseCollection: firebaseCollection)
              .uploadPostToDatabase(
                  keyString + "-" + i.toString(),
                  (await storage.uploadFileToGeneral(
                      uploadFiles[i], keyString + "-" + i.toString())),
                  listOfTags.map((e) => e.toLowerCase().trim()).toList());
        }
            //Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen(firebaseCollection: firebaseCollection)));

            // Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //         builder: (context) =>
            //             HomeScreen(firebaseCollection: firebaseCollection)));
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    //selectedImages.clear();
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: Row(
                children: selectActivated
                    ? [
                        PopUpMenu(
                          menuList: [
                            PopupMenuItem(
                              child: ListTile(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          title: Text("Please Confirm"),
                                          content: Text(
                                              "Please Confirm That You Would Like To Delete The Picture(s) From the Tag Album"),
                                          actions: [
                                            ElevatedButton(
                                                onPressed: () async {
                                                  for (PhotoItem photo
                                                      in selectedImages) {
                                                    // Navigator.push(
                                                    //     context,
                                                    //     MaterialPageRoute(
                                                    //         builder: (context) =>
                                                    //             TagPage(
                                                    //                 firebaseCollection:
                                                    //                     firebaseCollection)));
                                                    DatabaseService(
                                                            uid: user!.uid,
                                                            firebaseCollection:
                                                                firebaseCollection)
                                                        .delePhotoFromTag(
                                                            photo.uniqueId,
                                                            tag);
                                                    // Storage(
                                                    //         firebaseCollection:
                                                    //             firebaseCollection)
                                                    //     .deletePictureFromAll(
                                                    //         photo.uniqueId);
                                                    Storage(
                                                            firebaseCollection:
                                                                firebaseCollection)
                                                        .deleteFromTag(
                                                            photo.uniqueId,
                                                            tag);

                                                    Navigator.pop(context);
                                                  }
                                                },
                                                child: Text("Delete")),
                                            ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text("Cancel"))
                                          ],
                                        );
                                      });
                                },
                                leading: Icon(CupertinoIcons.delete),
                                // IconButton(icon: Icon(
                                //     //CupertinoIcons.person,
                                //     CupertinoIcons.delete), onPressed: () {}),
                                title: Text("Delete from tag album"),
                              ),
                            ),
                            PopupMenuItem(
                              child: ListTile(
                                leading: Icon(
                                    //CupertinoIcons.person,
                                    CupertinoIcons.delete_left),
                                title: Text("Delete from all uploads"),
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          title: Text("Please Confirm"),
                                          content: Text(
                                              "Please Confirm That You Would Like To Delete The Picture(s) From All Uploads"),
                                          actions: [
                                            ElevatedButton(
                                                onPressed: () async {
                                                  for (PhotoItem photo
                                                      in selectedImages) {
                                                    // Navigator.push(
                                                    //     context,
                                                    //     MaterialPageRoute(
                                                    //         builder: (context) =>
                                                    //             TagPage(
                                                    //                 firebaseCollection:
                                                    //                     firebaseCollection)));
                                                    // DatabaseService(
                                                    //         uid: user!.uid,
                                                    //         firebaseCollection:
                                                    //             firebaseCollection)
                                                    //     .deletePhoto(
                                                    //         photo.uniqueId);
                                                    // Storage(
                                                    //         firebaseCollection:
                                                    //             firebaseCollection)
                                                    //     .deletePictureFromAll(
                                                    //         photo.uniqueId);
                                                    // Storage(
                                                    //         firebaseCollection:
                                                    //             firebaseCollection)
                                                    //     .deleteFromTags(
                                                    //         photo.uniqueId,
                                                    //         photo.tags);

                                                  }
                                                },
                                                child: Text("Delete")),
                                            ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text("Cancel"))
                                          ],
                                        );
                                      });
                                },
                              ),
                            ),
                            PopupMenuItem(
                              child: ListTile(
                                leading: Icon(
                                  CupertinoIcons.share,
                                ),
                                title: Text("Share"),
                                onTap: () async {
                                  List<String> paths = [];
                                  for (var image in selectedImages) {
                                    final urlImage = image.image;
                                    final url = Uri.parse(urlImage);
                                    final response = await http.get(url);
                                    final bytes = response.bodyBytes;
                                    final temp = await getTemporaryDirectory();
                                    final path = '${temp.path}/image.jpg';
                                    io.File(path).writeAsBytesSync(bytes);
                                    paths.add(path);
                                  }

                                  await Share.shareFiles(paths, text: "Test");
                                },
                              ),
                            ),
                          ],
                          icon: Icon(Icons.menu),
                        ),
                        // IconButton(
                        //   icon: Icon(Icons.menu),
                        //   onPressed:
                        //() async {
                        //     // for (PhotoItem photo in selectedImages) {
                        //     //   Navigator.push(
                        //     //       context,
                        //     //       MaterialPageRoute(
                        //     //           builder: (context) => TagPage(
                        //     //               firebaseCollection:
                        //     //                   firebaseCollection)));
                        //     //   DatabaseService(
                        //     //           uid: user!.uid,
                        //     //           firebaseCollection: firebaseCollection)
                        //     //       .deletePhoto(photo.uniqueId);
                        //     //   Storage(firebaseCollection: firebaseCollection)
                        //     //       .deletePictureFromAll(photo.uniqueId);
                        //     //   Storage(firebaseCollection: firebaseCollection)
                        //     //       .deleteFromTags(photo.uniqueId, photo.tags);
                        //     // }
                        //   },
                        // ),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {},
                        ),
                        const SizedBox(width: 10.0),
                        IconButton(
                          icon: Icon(Icons.settings),
                          color: edit ? Colors.black : Colors.white,
                          onPressed: () {
                            setState(() {
                              if (edit) {
                                selectedImages.clear();
                              }
                              edit = !edit;
                              selectActivated = false;
                            });
                          },
                        )
                      ]
                    : [
                        const SizedBox(width: 10.0),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: Icon(Icons.settings),
                          color: edit ? Colors.black : Colors.white,
                          onPressed: () {
                            setState(() {
                              if (edit) {
                                selectedImages.clear();
                              }
                              edit = !edit;
                              selectActivated = false;
                            });
                          },
                        )
                      ],
              )),
        ],
      ),
      body: SafeArea(
        child: Padding(
            padding: EdgeInsets.all(30.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ignore: prefer_const_constructors
                  Text(tag.toUpperCase(),
                      style: TextStyle(
                          fontSize: 23.0,
                          fontWeight: FontWeight.w700,
                          color: Colors.black)),
                  const SizedBox(height: 10.0),

                  const SizedBox(height: 30.0),
                  FutureBuilder(
                      future: DatabaseService(
                              firebaseCollection: firebaseCollection,
                              uid: user!.uid)
                          .getPostsWithTag(tag),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          var data = snapshot.data as List<PhotoItem>;
                          return StaggeredGrid.count(
                            crossAxisCount: 4,
                            mainAxisSpacing: 4,
                            crossAxisSpacing: 4,
                            children: loadPhotos(data),
                          );
                        } else {
                          return Container();
                        }
                      }),
                ],
              ),
            )),
      ),
    );
  }

  void doMultiSelection(PhotoItem photo) {
    setState(() {
      // selectedImages
      //     .removeWhere((element) => element.uniqueId == photo.uniqueId);
      if (selectedImages.any((element) => photo.equals(element))) {
        //print(id == selectedImages.elementAt(0));
        selectedImages.removeWhere((element) => photo.equals(element));
        //selectedImages.remove(photo);

      } else {
        selectedImages.add(photo);
      }
      if (selectedImages.isNotEmpty) {
        selectActivated = true;
      } else {
        selectActivated = false;
      }
    });
    //build(context);
  }

  Widget _makeCategoryContainer(String title, int id) {
    return GestureDetector(
      onTap: () {
        setState(() {
          //this._activeCategory = id;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 7.5, horizontal: 15.0),
        margin: EdgeInsets.symmetric(horizontal: 5.0),
        child: Text(title,
            style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
                color: Colors.black)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
          color: Colors.grey[200],
        ),
      ),
    );
  }
}
