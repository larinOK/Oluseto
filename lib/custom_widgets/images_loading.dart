// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shimmer/shimmer.dart';

class ImagesLoading extends StatelessWidget {
  const ImagesLoading();

  @override
  Widget build(BuildContext context) {
    return StaggeredGrid.count(
        crossAxisCount: 2,
        mainAxisSpacing: 5,
        crossAxisSpacing: 5,
        children: buildShimmers());
  }

  List<Widget> buildShimmers() {
    List<Widget> shimmers = [];

    for (var i = 0; i < 20; i++) {
      shimmers.add(SizedBox(
        width: 200.0,
        height: 100.0,
        child: Shimmer.fromColors(
          baseColor: Colors.grey,
          highlightColor: Colors.white,
          child: Container(
            margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
            decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.all(Radius.circular(10))),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              child: AspectRatio(
                aspectRatio: 10 / 10,
                child: Container(
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ),
      ));
    }

    return shimmers;
  }
}
