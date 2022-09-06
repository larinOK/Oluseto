// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:meme_cloud/tag_search.dart';

import '../services/auth_function.dart';

import '../firebase_collection.dart';
import '../services/database.dart';

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
