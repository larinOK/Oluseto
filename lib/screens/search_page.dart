// ignore_for_file: prefer_const_constructors

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:meme_cloud/services/database.dart';
import 'package:meme_cloud/screens/tag_pics.dart';
import 'package:meme_cloud/models/user.dart';

import 'package:animated_search_bar/animated_search_bar.dart';

import 'package:provider/provider.dart';

import '../services/auth_function.dart';
import 'display.dart';
import '../firebase_collection.dart';
import '../global_colours.dart';
import 'package:show_up_animation/show_up_animation.dart';

import '../models/photo_item.dart';
import '../tile.dart';

class SearchPage extends StatefulWidget {
  final FirebaseCollection firebaseCollection;

  const SearchPage({Key? key, required this.firebaseCollection})
      : super(key: key);

  @override
  State<SearchPage> createState() =>
      SearchPageState(firebaseCollection: firebaseCollection);
}

class SearchPageState extends State<SearchPage> {
  final FirebaseCollection firebaseCollection;
  late User? user;
  late AuthFunction _auth;
  late DatabaseService databaseService;
  late TextEditingController controller;
  List<String> searchTerms = [];
  List<dynamic> tagList = [];
  bool searched = false;

  SearchPageState({required this.firebaseCollection}) {
    _auth = AuthFunction(firebaseCollection: firebaseCollection);
    user = firebaseCollection.firebaseAuth.currentUser;
    databaseService =
        DatabaseService(uid: user!.uid, firebaseCollection: firebaseCollection);
    controller = TextEditingController();
  }
  @override
  Widget build(BuildContext context) {
    // databaseService.getUserTags().then((value) {
    //   //print(value);
    //   tagList = value;
    // });

    // var tagSearch = TagSearch(tagList, firebaseCollection);
    //print(tagList.length);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
        ),
        body: Column(children: [
          //IconButton(onPressed: () {}, icon: Icon(CupertinoIcons.search)),
          SizedBox(height: MediaQuery.of(context).size.height * 0.35),
          Center(
              child: ElevatedButton(
            style: ElevatedButton.styleFrom(primary: Colors.black),
            child: Text("SEARCH"),
            onPressed: () async {
              tagList = await databaseService.getUserTags();

              showSearch(
                  context: context,
                  delegate: TagSearch(tagList, firebaseCollection));
              setState(() {
                searched = true;
              });
            },
          )),
        ]));
  }
}

class TagSearch extends SearchDelegate {
  List<dynamic> tagList;
  final FirebaseCollection firebaseCollection;
  late User? user;
  late AuthFunction _auth;
  late DatabaseService databaseService;
  late TextEditingController controller;
  List<String> searchTerms = [];
  List<Widget> tagCards = [];

  TagSearch(this.tagList, this.firebaseCollection) {
    _auth = AuthFunction(firebaseCollection: firebaseCollection);
    user = firebaseCollection.firebaseAuth.currentUser;
    databaseService =
        DatabaseService(uid: user!.uid, firebaseCollection: firebaseCollection);
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      Icon(Icons.abc),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: Icon(Icons.arrow_back_ios));
  }

  @override
  Widget buildResults(BuildContext context) {
    var suggestions = tagList
        .where((element) => element.toString().contains(query.toLowerCase()));

    var suggList = suggestions.toList();
    suggList.sort(
      (a, b) => a.compareTo(b),
    );

    return ListView.builder(
      itemBuilder: (context, index) {
        return ListTile(
          onTap: () {
            String term = suggList[index].toString();
            searchTerms.forEach((element) {
              if (element == term) {}
            });
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ResultsPage(
                        firebaseCollection: firebaseCollection,
                        tags: searchTerms)));
            searchTerms.add(term);

            for (var item in searchTerms) {
              tagCards.add(SearchCard(item, () {
                searchTerms.remove(item);
              }));
            }
          },
          title: Text(suggList[index]),
        );
      },
      itemCount: suggList.length,
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    var suggestions = tagList.where((element) =>
        element.toString().toLowerCase().contains(query.toLowerCase()));

    var suggList = suggestions.toList();
    suggList.sort(
      (a, b) => a.compareTo(b),
    );

    return ListView.builder(
      itemBuilder: (context, index) {
        return ListTile(
          onTap: () {
            String term = suggList[index].toString();
            searchTerms.forEach((element) {
              if (element == term) {}
            });

            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ResultsPage(
                        firebaseCollection: firebaseCollection,
                        tags: searchTerms)));
            searchTerms.add(term);
          },
          title: Text(suggList[index]),
        );
      },
      itemCount: suggList.length,
    );
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

class ResultsPage extends StatefulWidget {
  final FirebaseCollection firebaseCollection;
  List<String> tags;

  ResultsPage({Key? key, required this.firebaseCollection, required this.tags})
      : super(key: key);

  @override
  State<ResultsPage> createState() =>
      ResultsPageState(firebaseCollection, tags);
}

class ResultsPageState extends State<ResultsPage> {
  List<String> tags;
  late User? user;
  late AuthFunction _auth;
  final FirebaseCollection firebaseCollection;

  ResultsPageState(this.firebaseCollection, this.tags) {
    _auth = AuthFunction(firebaseCollection: firebaseCollection);
    user = firebaseCollection.firebaseAuth.currentUser;
  }

  List<Widget> buildCards() {
    List<Widget> cards = [];
    // if (tags.length > 1) {
    //   DatabaseService(uid: user!.uid, firebaseCollection: firebaseCollection)
    //       .filterPhotos(tags)
    //       .then((value) => print(value));
    // }

    for (var item in tags) {
      cards.add(SearchCard(item, () {
        setState(() {
          tags.remove(item);
        });
      }));
    }

    return cards;
  }

  loadTiles(List<PhotoItem> photos) {
    //var random = Random();
    int min = 2;
    int max = 5;
    //int result1 = min + random.nextInt(max - min);
    //int result2 = min + random.nextInt(max - min);

    List<Widget> babyList = [];
    for (var item in photos) {
      babyList.add(GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => RouteTwo(
                          firebaseCollection: firebaseCollection,
                          item: item,
                        )));
          },
          child: StaggeredGridTile.count(
            crossAxisCellCount: 4,
            mainAxisCellCount: 4,
            child: Tile(
              index: babyList.length,
              photo: item,
            ),
          )));
    }

    //tileList = babyList;
    return babyList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("RESULTS"),
        backgroundColor: Colors.black,
        actions: [
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.search, color: Colors.grey),
                    onPressed: () async {
                      Navigator.pop(context);
                      // var tagList = [];
                      // tagList = await DatabaseService(
                      //         uid: user!.uid,
                      //         firebaseCollection: firebaseCollection)
                      //     .getUserTags();

                      // showSearch(
                      //     context: context,
                      //     delegate: TagSearch(tagList, firebaseCollection));
                      // setState(() {
                      //   //searched = true;
                      // });
                    },
                  ),
                  const SizedBox(width: 20.0),
                  //Icon(Icons.notifications_none, color: Colors.grey),
                ],
              )),
        ],
      ),
      body: Container(
        child: SingleChildScrollView(
            child: Column(
          children: [
            SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: buildCards(),
              ),
            ),
            SizedBox(
              height: 20,
              width: 30,
            ),
            FutureBuilder(
                future: DatabaseService(
                        uid: user!.uid, firebaseCollection: firebaseCollection)
                    .filterPhotos2(tags),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var data = snapshot.data as List<PhotoItem>;
                    return SingleChildScrollView(
                        child: StaggeredGrid.count(
                      crossAxisCount: 4,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                      children: loadTiles(data),
                    ));
                  } else {
                    return Container();
                  }
                })
          ],
        )),
      ),
    );
  }
}
