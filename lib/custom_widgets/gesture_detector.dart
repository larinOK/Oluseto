import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:meme_cloud/models/photo_item.dart';

import '../firebase_collection.dart';
import '../screens/display.dart';
import 'image_card.dart';

class GestureDetectorWidget extends StatelessWidget {
  final FirebaseCollection firebaseCollection;
  final PhotoItem item;

  GestureDetectorWidget({required this.firebaseCollection, required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          // showModalBottomSheet(
          //     enableDrag: true,
          //     backgroundColor: Colors.transparent,
          //     isScrollControlled: true,
          //     isDismissible: true,
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.vertical(
          //         top: Radius.circular(10),
          //       ),
          //     ),
          //     context: context,
          //     builder: (context) => PhotoPage(
          //           firebaseCollection: firebaseCollection,
          //           item: item,
          //         ));
          // showCupertinoModalPopup(
          //     context: context,
          //     builder: (context) => PhotoPage(
          //           firebaseCollection: firebaseCollection,
          //           item: item,
          //           widgetA: widget,
          //         ));
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PhotoPage(
                        firebaseCollection: firebaseCollection,
                        item: item,
                        //widgetA: widget,
                      )));
        },
        child: StaggeredGridTile.count(
            crossAxisCellCount: 3, //min + random.nextInt(max - min),
            mainAxisCellCount: 3, //min + random.nextInt(max - min),
            child: ImageCard(item: item)
            // Tile(
            //   index: babyList.length,
            //   photo: item,
            // ),
            ));
  }
}
