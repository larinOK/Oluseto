// ignore_for_file: use_key_in_widget_constructors, no_logic_in_create_state, prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:meme_cloud/custom_widgets/carousel_loading.dart';
import 'package:meme_cloud/loading.dart';
import 'package:meme_cloud/models/photo_item.dart';
import 'package:meme_cloud/screens/tag_pics.dart';

import '../firebase_collection.dart';
import '../services/auth_function.dart';
import '../services/database.dart';
import 'package:shimmer/shimmer.dart';

class TagCarouselSlider extends StatefulWidget {
  final FirebaseCollection firebaseCollection;
  List<PhotoItem> photos = [];

  TagCarouselSlider({Key? key, required this.firebaseCollection});

  @override
  State<StatefulWidget> createState() {
    return TagCarouselSliderState(firebaseCollection: firebaseCollection);
  }
}

class TagCarouselSliderState extends State<TagCarouselSlider> {
  final FirebaseCollection firebaseCollection;
  late User? user;
  late AuthFunction _auth;
  late DatabaseService databaseService;
  Map<String, PhotoItem> carouselData = {};
  List<Widget> imageSlider = [];
  List<PhotoItem> photos = [];
  int _current = 0;
  bool loaded = false;

  TagCarouselSliderState({required this.firebaseCollection}) {
    _auth = AuthFunction(firebaseCollection: firebaseCollection);
    user = firebaseCollection.firebaseAuth.currentUser;
    databaseService =
        DatabaseService(uid: user!.uid, firebaseCollection: firebaseCollection);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (true) {
      databaseService.getCarouselData().then((value) => carouselData = value);
    }

    return FutureBuilder(
      future: databaseService.getCarouselData(),
      builder: (BuildContext context,
          AsyncSnapshot<Map<String, PhotoItem>> snapshot) {
        if (snapshot.hasData) {
          loaded = true;
          imageSlider = carouselData.keys
              .map((e) => GestureDetector(
                    child: Container(
                      margin: EdgeInsets.all(10),
                      child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          child: Stack(
                            children: [
                              Image(
                                image: NetworkImage(carouselData[e]!.image),
                                fit: BoxFit.fill,
                                width: 1000,
                              ),
                              Positioned(
                                bottom: 0,
                                top: 0,
                                right: 0,
                                left: 0,
                                child: Text(
                                  e.toUpperCase(),
                                  style: TextStyle(
                                      color: Colors.white,
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
                                  tag: e.toString())));
                    },
                  ))
              .toList();

          return Container(
            child: Column(
              children: [
                CarouselSlider(
                    items: imageSlider,
                    options: CarouselOptions(
                        autoPlay: true,
                        enlargeCenterPage: true,
                        aspectRatio: 16 / 9,
                        viewportFraction: 1,
                        onPageChanged: (index, reason) {
                          setState(() {
                            _current = index;
                          });
                        })),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: carouselData.values.map((e) {
                    int index = photos.indexOf(e);
                    return Container(
                      width: 8,
                      height: 8,
                      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _current == index
                            ? Color.fromRGBO(0, 0, 0, 0.9)
                            : Color.fromRGBO(0, 0, 0, 0.4),
                      ),
                    );
                  }).toList(),
                )
              ],
            ),
          );
        } else {
          //if (!loaded) {
          return CarouselLoading();
          // } else {
          //   return Loading();
          // }
        }
      },
    );
  }
}

Widget buildImage(String carouselImage, String tag, int size) {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 12),
    color: Colors.grey,
    child: Image(image: NetworkImage(carouselImage)),
    //decoration: ,
  );
}
