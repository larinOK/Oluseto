// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:meme_cloud/models/photo_item.dart';
import 'package:meme_cloud/services/database.dart';
import 'package:meme_cloud/screens/tag_pics.dart';
import 'package:meme_cloud/models/user.dart';

import 'package:provider/provider.dart';

import '../services/auth_function.dart';
import '../firebase_collection.dart';
import '../global_colours.dart';

class TagPage extends StatefulWidget {
  final FirebaseCollection firebaseCollection;

  const TagPage({Key? key, required this.firebaseCollection}) : super(key: key);

  @override
  State<TagPage> createState() =>
      TagPageState(firebaseCollection: firebaseCollection);
}

class TagPageState extends State<TagPage> {
  final FirebaseCollection firebaseCollection;
  final TextStyle headerStyle = TextStyle(
    color: Colors.grey.shade600,
    fontWeight: FontWeight.bold,
    fontSize: 20.0,
  );
  late User? user;
  late AuthFunction _auth;
  List<Widget> tileList = [];
  late DatabaseService databaseService;
  bool wantToSearch = false;
  String searchText = "";
  TextEditingController _controller =
      TextEditingController(text: "Initial Text");
  Map<String, PhotoItem> displayData = {};

  TagPageState({required this.firebaseCollection}) {
    _auth = AuthFunction(firebaseCollection: firebaseCollection);
    user = firebaseCollection.firebaseAuth.currentUser;
    databaseService =
        DatabaseService(uid: user!.uid, firebaseCollection: firebaseCollection);
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppUser?>(context, listen: false);

    Global globalColours = new Global();

    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.orangeAccent,
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: Text("TAGS",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                    color: globalColours.navColour))),
        body: SingleChildScrollView(
            child: FutureBuilder(
                future: databaseService.getTagDisplayData(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var data = snapshot.data as Map<String, PhotoItem>;

                    return StaggeredGrid.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 0,
                      crossAxisSpacing: 0,
                      children: loadTags(data),
                    );

                    // SingleChildScrollView(
                    //     padding: const EdgeInsets.all(16.0),
                    //     child: Column(
                    //         crossAxisAlignment: CrossAxisAlignment.start,
                    //         children: <Widget>[
                    //           const SizedBox(height: 10.0),
                    //           SingleChildScrollView(
                    //             padding: const EdgeInsets.all(16.0),
                    //             child: Column(children: loadTags(data)),
                    //           ),
                    //           const SizedBox(height: 20.0)
                    //         ]));
                  } else {
                    return Text("nada");
                  }
                })));
  }

  Container _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 8.0,
      ),
      width: double.infinity,
      height: 1.0,
      color: Colors.grey.shade300,
    );
  }

  loadTags(Map<String, PhotoItem> map) {
    //.List<String> tagList = list.map((e) => e.toString()).toList();
    List<Widget> babyList = [];

    //tagList.sort((a, b) => a.compareTo(b));

    List<String> keys = map.keys.toList();
    keys.sort((a, b) => a.compareTo(b));

    for (var item in keys) {
      babyList.add(GestureDetector(
        child: Container(
          margin: EdgeInsets.all(10),
          child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              child: Stack(
                children: [
                  Image(
                    image: NetworkImage(map[item]!.image),
                    fit: BoxFit.fill,
                    width: 800,
                  ),
                  Positioned(
                    bottom: 0,
                    top: 0,
                    right: 0,
                    left: 0,
                    child: Text(
                      item.toUpperCase(),
                      style: TextStyle(
                          color: Colors.orange,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              )),
        ),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => TagPictures(
                      firebaseCollection: firebaseCollection,
                      tag: item.toString())));
        },
      )

          //   ListTile(
          //   iconColor: Colors.blueGrey,
          //   trailing: Icon(Icons.arrow_forward_ios),
          //   title: Text(item.toUpperCase()),
          //   onTap: () {
          //     Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //             builder: (context) => TagPictures(
          //                 firebaseCollection: firebaseCollection, tag: item)));
          //   },
          // )
          );
      _buildDivider();
      _buildDivider();
    }

    tileList = babyList;
    return babyList;
  }

  List<Widget> getTagTiles() {
    DatabaseService(uid: user!.uid, firebaseCollection: firebaseCollection)
        .getUserTags()
        .then((value) => {loadTags(value)});

    return tileList;
  }
}
