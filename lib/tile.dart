import 'package:flutter/material.dart';

import 'photo_item.dart';

class Tile extends StatelessWidget {
  const Tile({
    Key? key,
    required this.index,
    required this.photo,
    this.extent,
    this.backgroundColor,
    this.bottomSpace,
  }) : super(key: key);

  final int index;
  final double? extent;
  final double? bottomSpace;
  final Color? backgroundColor;
  final PhotoItem photo;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        color: Color(0xFFEAEAEA),
      ),
      height: extent,
      child: Center(
          child: Image(
        image: NetworkImage(photo.image),
      )
          // Image(
          //   image: NetworkImage(photo.image),
          // ),
          // CircleAvatar(
          //     minRadius: 20,
          //     maxRadius: 20,
          //     backgroundColor: Colors.white,
          //     foregroundColor: Colors.black,
          //     child: Image(
          //       image: NetworkImage(photo.image),
          //     )
          //     //Text('$index', style: const TextStyle(fontSize: 20)),
          //     ),
          ),
    );

    if (bottomSpace == null) {
      return child;
    }

    return Column(
      children: [
        Expanded(child: child),
        Container(
          height: bottomSpace,
          color: Colors.green,
        )
      ],
    );
  }
}
