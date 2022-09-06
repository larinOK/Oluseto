import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../firebase_collection.dart';
import '../services/auth_function.dart';
import '../services/database.dart';

class AutocompleteTextField extends StatelessWidget {
  List<String> options = [];
  List<String> newTags = [];
  void Function(String)? onSelected;
  String newTag = '';
  late FirebaseCollection firebaseCollection;
  late User? user;
  late AuthFunction _auth;

  AutocompleteTextField(this.onSelected, this.firebaseCollection) {
    _auth = AuthFunction(firebaseCollection: firebaseCollection);
    user = firebaseCollection.firebaseAuth.currentUser;
  }
  @override
  void initState() {
    // TODO: implement initState

    fetchAutoCompleteData();
  }

  Future fetchAutoCompleteData() async {
    List<dynamic> tags = [];

    tags = await DatabaseService(
            uid: user!.uid, firebaseCollection: firebaseCollection)
        .getUserTags() as List<dynamic>;

    tags.forEach((element) {
      options.add(element.toString());
    });
    options.sort((a, b) => a.compareTo(b));
    print(options);
  }

  // static const List<String> _kOptions = <String>[
  //   'aardvark',
  //   'bobcat',
  //   'chameleon',
  // ];

  @override
  Widget build(BuildContext context) {
    initState();

    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        options.removeWhere((element) => element == newTag);
        newTag = textEditingValue.text.toString();
        options.add(textEditingValue.text.toString());
        if (textEditingValue.text == '') {
          return options;
        } else {
          print(options.length);
          //options.add(textEditingValue.text.toString());
          return options.where((String option) {
            return option.contains(textEditingValue.text.toLowerCase());
          });
        }
      },
      // optionsViewBuilder: (context, onSelected, options) {
      //   List<Widget> texts = [];
      //   options.forEach((element) {
      //     texts.add(Text(element));
      //   });

      //   return SingleChildScrollView(
      //     child: Column(
      //       children: texts,
      //     ),
      //     scrollDirection: Axis.vertical,
      //   );

      //   // ListTile(
      //   //   // title: Text(option.toString()),
      //   //   title: Text("data"),
      //   //   subtitle: Text("This is subtitle"),
      //   //   onTap: () {
      //   //     onSelected(option.toString());
      //   //   },
      //   // );
      //   //;
      // },
      fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
        return TextField(
          focusNode: focusNode,
          autofocus: true,
          controller: controller,
          textInputAction: TextInputAction.continueAction,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
              hintText: "Add Tags",
              contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              suffixIcon: IconButton(
                  onPressed: () {
                    controller.clear();
                  },
                  icon: Icon(Icons.clear))),
        );
      },
      onSelected: onSelected,
    );
  }
}
