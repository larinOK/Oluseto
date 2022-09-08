import 'package:flutter/material.dart';

import '../firebase_collection.dart';

class EditProfileScreen extends StatefulWidget {
  //final Function toggle;
  final FirebaseCollection firebaseCollection;
  EditProfileScreen({required this.firebaseCollection});

  @override
  State<StatefulWidget> createState() {
    return _EditProfileScreenState(firebaseCollection: firebaseCollection);
  }
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final FirebaseCollection firebaseCollection;

  _EditProfileScreenState({required this.firebaseCollection});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
