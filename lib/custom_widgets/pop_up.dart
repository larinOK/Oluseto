// ignore_for_file: prefer_const_constructors, unnecessary_new, no_logic_in_create_state

//import 'dart:html';
import 'dart:io' as io;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meme_cloud/services/auth_function.dart';
import 'package:meme_cloud/services/database.dart';
import 'package:meme_cloud/firebase_collection.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'package:meme_cloud/loading.dart';
import 'package:meme_cloud/models/photo_item.dart';
import 'package:meme_cloud/services/storage.dart';
import 'package:meme_cloud/screens/tag_pics.dart';

import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../custom_widgets/search_card.dart';

class PopUpBody extends StatefulWidget {
  // final String image;
  // final List<dynamic> tags;
  final FirebaseCollection firebaseCollection;
  final PhotoItem item;
  final ScrollController controller;

  PopUpBody(
      {Key? key,
      required this.firebaseCollection,
      required this.item,
      required this.controller
      // required this.image,
      // required this.tags
      })
      : super(key: key);

  @override
  State<PopUpBody> createState() => _PopUpBodyState(
      firebaseCollection: firebaseCollection,
      item: item,
      controller: controller);
}

class _PopUpBodyState extends State<PopUpBody> {
  late User? user;
  late AuthFunction _auth;
  bool edit = false;
  final PhotoItem item;
  final FirebaseCollection firebaseCollection;
  final ScrollController controller;
  _PopUpBodyState(
      {required this.firebaseCollection,
      required this.item,
      required this.controller}) {
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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(10),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 20 / 20,
            child: Container(
              height: 30,
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
                      margin: const EdgeInsets.all(10.0),
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
                        // IconButton(
                        //     onPressed: () async {
                        //       final urlImage = item.image;
                        //       final url = Uri.parse(urlImage);
                        //       final response = await http.get(url);
                        //       final bytes = response.bodyBytes;

                        //       final temp = await getTemporaryDirectory();
                        //       final path = '${temp.path}/image.jpg';
                        //       io.File(path).writeAsBytesSync(bytes);
                        //       await Share.shareFiles([path], text: "Test");
                        //     },
                        //     icon: Icon(Icons.share)),
                        // IconButton(
                        //     onPressed: () {
                        //       setState(() {
                        //         edit = true;
                        //       });
                        //     },
                        //     icon: Icon(Icons.edit))
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

  Widget buildSheet() => Scaffold(
        // appBar: AppBar(
        //   title: Text(' OLUSETO '),
        //   backgroundColor: Colors.orange,
        // ),
        body: Padding(
            padding: EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AspectRatio(
                  aspectRatio: 20 / 20,
                  child: Container(
                    height: 30,
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
                            margin: const EdgeInsets.all(10.0),
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
                            style:
                                ElevatedButton.styleFrom(primary: Colors.black),
                          )
                        ],
                      )),
              ],
            )),
      );
}

// return DraggableScrollableSheet(
//       initialChildSize: 0.9,
//       builder: (_, controller) => Scaffold(
//         // appBar: AppBar(
//         //   title: Text(' OLUSETO '),
//         //   backgroundColor: Colors.orange,
//         // ),
//         body: Padding(
//             padding: EdgeInsets.all(10.0),
//             child: Container(
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.vertical(
//                   top: Radius.circular(10),
//                 ),
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   AspectRatio(
//                     aspectRatio: 20 / 20,
//                     child: Container(
//                       height: 30,
//                       width: double.infinity,
//                       child: Image(
//                         image: NetworkImage(item.image),
//                       ),
//                     ),
//                   ),
//                   !edit
//                       ? Column(
//                           children: [
//                             Container(
//                               margin: const EdgeInsets.all(10.0),
//                               child: Center(
//                                   child: SingleChildScrollView(
//                                 scrollDirection: Axis.horizontal,
//                                 child: Row(
//                                   children: buildTagContainers(item.tags),
//                                 ),
//                               )

//                                   // Text(
//                                   //   tags.toString(),
//                                   //   style: TextStyle(fontSize: 40),
//                                   // ),
//                                   ),
//                             ),
//                             Row(
//                               children: [
//                                 SizedBox(
//                                   width:
//                                       MediaQuery.of(context).size.width * 0.35,
//                                 ),
//                                 IconButton(
//                                     onPressed: () async {
//                                       final urlImage = item.image;
//                                       final url = Uri.parse(urlImage);
//                                       final response = await http.get(url);
//                                       final bytes = response.bodyBytes;

//                                       final temp =
//                                           await getTemporaryDirectory();
//                                       final path = '${temp.path}/image.jpg';
//                                       io.File(path).writeAsBytesSync(bytes);
//                                       await Share.shareFiles([path],
//                                           text: "Test");
//                                     },
//                                     icon: Icon(Icons.share)),
//                                 IconButton(
//                                     onPressed: () {
//                                       setState(() {
//                                         edit = true;
//                                       });
//                                     },
//                                     icon: Icon(Icons.edit))
//                               ],
//                             )
//                           ],
//                         )
//                       : Container(
//                           child: Column(
//                           children: [
//                             SizedBox(
//                               height: 20,
//                             ),
//                             SingleChildScrollView(
//                               scrollDirection: Axis.horizontal,
//                               child: Row(
//                                 children: buildEditCards(),
//                               ),
//                             ),
//                             SizedBox(
//                               height: 20,
//                             ),
//                             ElevatedButton(
//                               onPressed: () {
//                                 setState(() {
//                                   edit = false;
//                                 });
//                               },
//                               child: Text("Done"),
//                               style: ElevatedButton.styleFrom(
//                                   primary: Colors.black),
//                             )
//                           ],
//                         )),
//                 ],
//               ),
//             )),
//       ),
//     );

