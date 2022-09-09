// ignore_for_file: prefer_const_constructors, unnecessary_new

//import 'dart:html';
import 'dart:io' as io;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meme_cloud/custom_widgets/auto_complete.dart';
import 'package:meme_cloud/services/auth_function.dart';
import 'package:meme_cloud/services/database.dart';
import 'package:meme_cloud/firebase_collection.dart';

import 'package:meme_cloud/loading.dart';
import 'package:meme_cloud/models/photo_item.dart';
import 'package:meme_cloud/services/storage.dart';
import 'package:meme_cloud/screens/tag_pics.dart';

import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../custom_widgets/search_card.dart';

class PhotoPage extends StatefulWidget {
  // final String image;
  // final List<dynamic> tags;
  final FirebaseCollection firebaseCollection;
  final PhotoItem item;

  PhotoPage({
    Key? key,
    required this.firebaseCollection,
    required this.item,
    // required this.image,
    // required this.tags
  }) : super(key: key);

  @override
  State<PhotoPage> createState() =>
      _PhotoPageState(firebaseCollection: firebaseCollection, item: item);
}

class _PhotoPageState extends State<PhotoPage> {
  late User? user;
  late AuthFunction _auth;
  bool edit = false;
  bool wantToAddTags = false;
  final PhotoItem item;
  final FirebaseCollection firebaseCollection;
  _PhotoPageState({required this.firebaseCollection, required this.item}) {
    _auth = AuthFunction(firebaseCollection: firebaseCollection);
    user = firebaseCollection.firebaseAuth.currentUser;
  }
  List<Widget> buildEditCards() {
    List<Widget> cards = [];
    // if (tags.length > 1) {
    //   DatabaseService(uid: user!.uid, firebaseCollection: firebaseCollection)
    //       .filterPhotos(tags)
    //       .then((value) => print(value));
    // }

    for (var tag in item.tags) {
      cards.add(SearchCard(tag.toString(), () async {
        setState(() {
          item.tags.removeWhere(
            (element) => element.toString() == tag.toString(),
          );
        });

        await DatabaseService(
                uid: user!.uid, firebaseCollection: firebaseCollection)
            .updatePhotoTagList(
                item.uniqueId, item.tags.map((e) => e.toString()).toList());
        // await Storage(firebaseCollection: firebaseCollection)
        //     .deleteFromTag(item.uniqueId, tag);
      }));
    }

    return cards;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(' OLUSETO '),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    width: double.infinity,
                    child: Image(
                      image: NetworkImage(item.image),
                    ),
                  ),
                ),
                !edit
                    ? Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.all(20.0),
                            child: Center(
                                child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: buildTagContainers(item.tags),
                              ),
                            )

                                // Text(
                                //   tags.toString(),
                                //   style: TextStyle(fontSize: 40),
                                // ),
                                ),
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.35,
                              ),
                              IconButton(
                                  onPressed: () async {
                                    final urlImage = item.image;
                                    final url = Uri.parse(urlImage);
                                    final response = await http.get(url);
                                    final bytes = response.bodyBytes;

                                    final temp = await getTemporaryDirectory();
                                    final path = '${temp.path}/image.jpg';
                                    io.File(path).writeAsBytesSync(bytes);
                                    await Share.shareFiles([path],
                                        text: "Test");
                                  },
                                  icon: Icon(Icons.share)),
                              IconButton(
                                  onPressed: () {
                                    setState(() {
                                      edit = true;
                                    });
                                  },
                                  icon: Icon(Icons.edit))
                            ],
                          )
                        ],
                      )
                    : Container(
                        child: Column(
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: buildEditCards(),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          !wantToAddTags
                              ? ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      primary: Colors.black),
                                  onPressed: () {
                                    setState(() {
                                      wantToAddTags = true;
                                    });
                                  },
                                  child: Text("Add Tag"))
                              : Container(),
                          wantToAddTags
                              ? AutocompleteTextField((p0) {
                                  setState(() {
                                    // DatabaseService(
                                    //         uid: user!.uid,
                                    //         firebaseCollection:
                                    //             firebaseCollection)
                                    //     .addTagToPhoto(item.uniqueId, p0);
                                    // Storage(
                                    //         firebaseCollection:
                                    //             firebaseCollection)
                                    //     .addNewTag(item, p0);
                                    item.tags.add(p0);
                                    buildEditCards();
                                    DatabaseService(
                                            uid: user!.uid,
                                            firebaseCollection:
                                                firebaseCollection)
                                        .updatePhotoTagList(
                                            item.uniqueId,
                                            item.tags
                                                .map((e) => e.toString())
                                                .toList());
                                  });
                                }, firebaseCollection)
                              : SizedBox(
                                  height: 20,
                                ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                edit = false;
                                wantToAddTags = false;
                              });
                            },
                            child: Text("Done"),
                            style:
                                ElevatedButton.styleFrom(primary: Colors.black),
                          )
                        ],
                      )),
              ],
            )),
      ),
    );
  }

  Widget makeTagDisplayWidget(String title) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                TagPictures(firebaseCollection: firebaseCollection, tag: title),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 7.5, horizontal: 15.0),
        margin: EdgeInsets.symmetric(horizontal: 5.0),
        child: Text(title,
            style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
                color: Colors.white)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
          color: Colors.black,
        ),
      ),
    );
  }

  List<Widget> buildTagContainers(List<dynamic> tags) {
    List<Widget> containers = [];
    for (var item in tags) {
      containers.add(makeTagDisplayWidget(item.toString()));
    }
    return containers;
  }
}
