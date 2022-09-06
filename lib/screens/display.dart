// ignore_for_file: prefer_const_constructors, unnecessary_new

//import 'dart:html';
import 'dart:io' as io;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

class RouteOne extends StatelessWidget {
  final FirebaseCollection firebaseCollection;
  late User? user;
  late AuthFunction _auth;
  List<PhotoItem> _items = [];
  RouteOne({required this.firebaseCollection}) {
    _auth = AuthFunction(firebaseCollection: firebaseCollection);
    user = firebaseCollection.firebaseAuth.currentUser;
  }

  //        await DatabaseService(uid: user!.uid, firebaseCollection: firebaseCollection)
  //             .getUserPosts();
  //     [
  //   PhotoItem(
  //       "https://images.pexels.com/photos/1772973/pexels-photo-1772973.png?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260",
  //       ["Stephan Seeber"]),

  @override
  Widget build(BuildContext context) {
    // List<PhotoItem> _items =
    //     DatabaseService(uid: user!.uid, firebaseCollection: firebaseCollection)
    //         .getUserPosts();

    // _items =
    DatabaseService(uid: user!.uid, firebaseCollection: firebaseCollection)
        .getUserPosts()
        .then((value) => _items = value);

    loadPhotos() async {
      _items = await DatabaseService(
              uid: user!.uid, firebaseCollection: firebaseCollection)
          .getUserPosts();
    }

    //loadPhotos();

    return Scaffold(
        appBar: AppBar(
          title: Text('Screen one ☝️'),
        ),
        body: FutureBuilder(
            future: DatabaseService(
                    uid: user!.uid, firebaseCollection: firebaseCollection)
                .getUserPosts(),
            builder: ((context, snapshot) {
              if (snapshot.hasData) {
                return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                      crossAxisCount: 3,
                    ),
                    itemBuilder: (context, index) {
                      return new GestureDetector(
                        onTap: () async {
                          //List<PhotoItem> jacl = await DatabaseService(
                          //      uid: user!.uid,
                          //        firebaseCollection: firebaseCollection)
                          //    .getUserPosts();
                          //print(jacl.length);

                          //_items = jacl;

                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => RouteTwo(
                          //         firebaseCollection: firebaseCollection,
                          //         image: _items[0].image,
                          //         tags: _items[0].tags),
                          //   ),
                          // );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(_items[0].image),
                            ),
                          ),
                        ),
                      );
                    });
              } else {
                return Loading();
              }
            }))

        // GridView.builder(
        //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        //     crossAxisSpacing: 5,
        //     mainAxisSpacing: 5,
        //     crossAxisCount: 3,
        //   ),
        //   itemCount: _items.length,
        //   itemBuilder: (context, index) {
        //     return new GestureDetector(
        //       onTap: () async {
        //         print("2172022204326" "-" "vEJJzyIgZ9T3M8ukbZQtH5dtAli2");
        //         List<PhotoItem> jacl = await DatabaseService(
        //                 uid: user!.uid, firebaseCollection: firebaseCollection)
        //             .getUserPosts();
        //         print(jacl.length);

        //         _items = jacl;

        //         Navigator.push(
        //           context,
        //           MaterialPageRoute(
        //             builder: (context) =>
        //                 RouteTwo(image: _items[0].image, tags: _items[0].tags),
        //           ),
        //         );
        //       },
        //       child: Container(
        //         decoration: BoxDecoration(
        //           image: DecorationImage(
        //             fit: BoxFit.cover,
        //             image: NetworkImage(_items[index].image),
        //           ),
        //         ),
        //       ),
        //     );
        //   },
        // ),
        );
  }
}

class RouteTwo extends StatefulWidget {
  // final String image;
  // final List<dynamic> tags;
  final FirebaseCollection firebaseCollection;
  final PhotoItem item;

  RouteTwo({
    Key? key,
    required this.firebaseCollection,
    required this.item,
    // required this.image,
    // required this.tags
  }) : super(key: key);

  @override
  State<RouteTwo> createState() =>
      _RouteTwoState(firebaseCollection: firebaseCollection, item: item);
}

class _RouteTwoState extends State<RouteTwo> {
  late User? user;
  late AuthFunction _auth;
  bool edit = false;
  final PhotoItem item;
  final FirebaseCollection firebaseCollection;
  _RouteTwoState({required this.firebaseCollection, required this.item}) {
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
        await DatabaseService(
                uid: user!.uid, firebaseCollection: firebaseCollection)
            .delePhotoFromTag(item.uniqueId, tag);
        await Storage(firebaseCollection: firebaseCollection)
            .deleteFromTag(item.uniqueId, tag);
      }));
    }

    return cards;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(' '),
        backgroundColor: Colors.black,
      ),
      body: Column(
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
                              await Share.shareFiles([path], text: "Test");
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
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: buildEditCards(),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          edit = false;
                        });
                      },
                      child: Text("Done"),
                      style: ElevatedButton.styleFrom(primary: Colors.black),
                    )
                  ],
                )),
        ],
      ),
    );
  }

  Widget _makeCategoryContainer(String title) {
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
      containers.add(_makeCategoryContainer(item.toString()));
    }
    return containers;
  }
}

class SearchCard extends StatelessWidget {
  String title;
  void Function()? onPressed;

  SearchCard(this.title, this.onPressed);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: (() {}),
        child: Container(
          height: 40.0,
          padding: EdgeInsets.symmetric(vertical: 3.0, horizontal: 7.0),
          margin: EdgeInsets.symmetric(horizontal: 5.0),
          child: Row(
            children: [
              Text(title,
                  style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.black)),
              IconButton(
                  onPressed: onPressed,
                  icon: Icon(
                    Icons.cancel,
                    size: 20.0,
                  ))
            ],
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
            color: Colors.grey[200],
          ),
        ));
  }
}
