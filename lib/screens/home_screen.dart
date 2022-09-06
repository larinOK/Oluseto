// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:meme_cloud/services/auth_function.dart';
import 'package:meme_cloud/services/database.dart';
import 'package:meme_cloud/screens/display.dart';
import 'package:meme_cloud/models/photo_item.dart';
import 'package:meme_cloud/screens/upload.dart';

import '../firebase_collection.dart';
import 'dart:math';

import '../tag_search.dart';
import 'search_page.dart';
import '../tile.dart';

class HomeScreen extends StatefulWidget {
  final FirebaseCollection firebaseCollection;
  const HomeScreen({Key? key, required this.firebaseCollection})
      : super(key: key);

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState(firebaseCollection: firebaseCollection);
}

class _HomeScreenState extends State<HomeScreen> {
  int _activeCategory = 1;
  final FirebaseCollection firebaseCollection;
  late User? user;
  late AuthFunction _auth;
  List<Widget> tileList = [];

  _HomeScreenState({required this.firebaseCollection}) {
    _auth = AuthFunction(firebaseCollection: firebaseCollection);
    user = firebaseCollection.firebaseAuth.currentUser;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<PhotoItem> _items = [
      // PhotoItem(
      //     "https://images.pexels.com/photos/1772973/pexels-photo-1772973.png?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260",
      //     ["Stephan Seeber"]),
      // PhotoItem(
      //     "https://images.pexels.com/photos/1758531/pexels-photo-1758531.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260",
      //     ["Liam Gant"]),
    ];

    loadTiles(List<PhotoItem> photos) {
      var random = Random();
      int min = 2;
      int max = 5;
      int result1 = min + random.nextInt(max - min);
      int result2 = min + random.nextInt(max - min);
      // print(result1);
      // print(result2);
      List<Widget> babyList = [];
      for (var item in photos) {
        babyList.add(GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PhotoPage(
                            firebaseCollection: firebaseCollection,
                            item: item,
                          )));
            },
            child: StaggeredGridTile.count(
              crossAxisCellCount: min + random.nextInt(max - min),
              mainAxisCellCount: min + random.nextInt(max - min),
              child: Tile(
                index: babyList.length,
                photo: item,
              ),
            )));
      }

      tileList = babyList;
      return babyList;
    }

    List<Widget> getPhotos() {
      DatabaseService(uid: user!.uid, firebaseCollection: firebaseCollection)
          .getUserPosts()
          .then((value) {
        loadTiles(value);
      });

      return tileList;
    }

    // setState(() {
    //   DatabaseService(uid: user!.uid, firebaseCollection: firebaseCollection)
    //       .getUserPosts()
    //       .then((value) {
    //     print(value[0].tags.toString() + "Oboy");
    //     loadTiles(value);
    //   });
    // });

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          actions: [
            Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.search, color: Colors.grey),
                      onPressed: () async {
                        var tagList = [];
                        tagList = await DatabaseService(
                                uid: user!.uid,
                                firebaseCollection: firebaseCollection)
                            .getUserTags();

                        showSearch(
                            context: context,
                            delegate: TagSearch(tagList, firebaseCollection));
                        setState(() {
                          //searched = true;
                        });
                      },
                    ),
                    const SizedBox(width: 20.0),
                    Icon(Icons.notifications_none, color: Colors.grey),
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
                  Text('All Photos',
                      style: TextStyle(
                          fontSize: 23.0,
                          fontWeight: FontWeight.w700,
                          color: Colors.black)),
                  const SizedBox(height: 10.0),
                  Text('All your uploads.',
                      style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600])),
                  // const SizedBox(height: 30.0),
                  // SingleChildScrollView(
                  //   scrollDirection: Axis.horizontal,
                  //   child: Row(
                  //     children: [
                  //       _makeCategoryContainer('For you', 1),
                  //       _makeCategoryContainer('Popular', 2),
                  //       _makeCategoryContainer('title3', 3),
                  //       _makeCategoryContainer('For you', 4),
                  //       _makeCategoryContainer('Popular', 5),
                  //       _makeCategoryContainer('title3', 6),
                  //     ],
                  //   ),
                  // ),
                  // const SizedBox(height: 50.0),

                  FutureBuilder(
                      future: DatabaseService(
                              uid: user!.uid,
                              firebaseCollection: firebaseCollection)
                          .getUserPosts(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Column(
                            children: [
                              Center(
                                child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => UploadPhoto(
                                                  firebaseCollection:
                                                      firebaseCollection)));
                                    },
                                    child: Text("Add Pictures")),
                              )
                            ],
                          );
                        } else if (snapshot.data == []) {
                          return Column(
                            children: [
                              Center(
                                child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => UploadPhoto(
                                                  firebaseCollection:
                                                      firebaseCollection)));
                                    },
                                    child: Text("Add Pictures")),
                              )
                            ],
                          );
                        } else {
                          var data = snapshot.data as List<PhotoItem>;
                          if (data == []) {
                            return Column(
                              children: [
                                Center(
                                  child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => UploadPhoto(
                                                    firebaseCollection:
                                                        firebaseCollection)));
                                      },
                                      child: Text("Add Pictures")),
                                )
                              ],
                            );
                          } else {
                            return StaggeredGrid.count(
                              crossAxisCount: 4,
                              mainAxisSpacing: 4,
                              crossAxisSpacing: 4,
                              children: loadTiles(data),
                            );
                          }
                        }
                      })

                  // Container(
                  //   height: 400,
                  //   child: SingleChildScrollView(
                  //     child: StaggeredGrid.count(
                  //       crossAxisCount: 4,
                  //       mainAxisSpacing: 4,
                  //       crossAxisSpacing: 4,
                  //       children: getPhotos(),

                  //       // const [
                  //       //   StaggeredGridTile.count(
                  //       //     crossAxisCellCount: 2,
                  //       //     mainAxisCellCount: 2,
                  //       //     child: Tile(index: 0),
                  //       //   ),
                  //       //   StaggeredGridTile.count(
                  //       //     crossAxisCellCount: 2,
                  //       //     mainAxisCellCount: 1,
                  //       //     child: Tile(index: 1),
                  //       //   ),
                  //       //   StaggeredGridTile.count(
                  //       //     crossAxisCellCount: 1,
                  //       //     mainAxisCellCount: 1,
                  //       //     child: Tile(index: 2),
                  //       //   ),
                  //       //   StaggeredGridTile.count(
                  //       //     crossAxisCellCount: 1,
                  //       //     mainAxisCellCount: 1,
                  //       //     child: Tile(index: 3),
                  //       //   ),
                  //       //   StaggeredGridTile.count(
                  //       //     crossAxisCellCount: 4,
                  //       //     mainAxisCellCount: 2,
                  //       //     child: Tile(index: 4),
                  //       //   ),
                  //       // ],

                  //       // StaggeredGrid.count(
                  //       //   crossAxisCount: 4,
                  //       //   mainAxisSpacing: 4,
                  //       //   crossAxisSpacing: 4,
                  //       //   children: getPhotos(),
                  //       //     const [
                  //       //   StaggeredGridTile.count(
                  //       //     crossAxisCellCount: 2,
                  //       //     mainAxisCellCount: 2,
                  //       //     child: Text("5"),
                  //       //   ),
                  //       //   StaggeredGridTile.count(
                  //       //     crossAxisCellCount: 2,
                  //       //     mainAxisCellCount: 1,
                  //       //     child: Text("5"),
                  //       //   ),
                  //       //   StaggeredGridTile.count(
                  //       //     crossAxisCellCount: 1,
                  //       //     mainAxisCellCount: 1,
                  //       //     child: Text("5"),
                  //       //   ),
                  //       //   StaggeredGridTile.count(
                  //       //     crossAxisCellCount: 1,
                  //       //     mainAxisCellCount: 1,
                  //       //     child: Text("5"),
                  //       //   ),
                  //       //   StaggeredGridTile.count(
                  //       //     crossAxisCellCount: 4,
                  //       //     mainAxisCellCount: 2,
                  //       //     child: Text("5"),
                  //       //   ),
                  //       //   StaggeredGridTile.count(
                  //       //     crossAxisCellCount: 2,
                  //       //     mainAxisCellCount: 2,
                  //       //     child: Text("5"),
                  //       //   ),
                  //       //   StaggeredGridTile.count(
                  //       //     crossAxisCellCount: 2,
                  //       //     mainAxisCellCount: 2,
                  //       //     child: Text("5"),
                  //       //   ),
                  //       // ],
                  //     ),
                  //   ),
                  // )
                ])),
          ),
        ));
  }
}
