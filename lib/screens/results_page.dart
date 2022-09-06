import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:meme_cloud/services/auth_function.dart';

import '../firebase_collection.dart';
import '../models/photo_item.dart';
import '../custom_widgets/search_card.dart';
import '../services/database.dart';
import '../custom_widgets/tile.dart';
import 'display.dart';

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
                    builder: (context) => PhotoPage(
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
