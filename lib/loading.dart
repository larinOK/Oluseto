import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:meme_cloud/global_colours.dart';

class Loading extends StatelessWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Global globalColours = new Global();
    return Container(
      color: Colors.white,
      child: Center(
        child: SpinKitThreeBounce(
          color: globalColours.baseColour,
          size: 50.0,
        ),
      ),
    );
  }
}
