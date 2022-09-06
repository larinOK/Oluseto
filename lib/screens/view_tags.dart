import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
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
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: Text("TAGS",
                key: Key("settings-display"),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                    color: globalColours.baseColour))),
        body: FutureBuilder(
            future: databaseService.getUserTags(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var data = snapshot.data as List<dynamic>;

                return SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const SizedBox(height: 10.0),
                          Card(
                              elevation: 0.5,
                              margin: const EdgeInsets.symmetric(
                                vertical: 4.0,
                                horizontal: 0,
                              ),
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(children: loadTags(data)),
                              )),
                          const SizedBox(height: 20.0)
                        ]));
              } else {
                return Text("nada");
              }
            }));
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

  loadTags(List list) {
    List<String> tagList = list.map((e) => e.toString()).toList();
    List<Widget> babyList = [];

    tagList.sort((a, b) => a.compareTo(b));

    for (var item in tagList) {
      babyList.add(ListTile(
        iconColor: Colors.blueGrey,
        trailing: Icon(Icons.arrow_forward_ios),
        title: Text(item.toUpperCase()),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => TagPictures(
                      firebaseCollection: firebaseCollection, tag: item)));
        },
      ));
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
