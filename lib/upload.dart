// ignore_for_file: unused_element, prefer_const_constructors, no_logic_in_create_state

import 'dart:async';

import 'dart:io';

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:meme_cloud/auth_function.dart';
import 'package:meme_cloud/database.dart';
import 'package:meme_cloud/firebase_collection.dart';
import 'package:meme_cloud/home_screen.dart';
import 'package:meme_cloud/photo_item.dart';
import 'package:meme_cloud/search_card.dart';
import 'package:meme_cloud/storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meme_cloud/user.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ImPred extends StatefulWidget {
  @override
  final FirebaseCollection firebaseCollection;

  ImPred({required this.firebaseCollection});

  @override
  State<StatefulWidget> createState() {
    return ImPredState(firebaseCollection: firebaseCollection);
  }
}

class ImPredState extends State<ImPred> {
  Image? jam;
  bool _isLoading = true;
  bool picked = false;
  File _image = File("");
  DateTime now = DateTime.now();
  bool pickedFromGallery = false;
  String timeString = "";
  final picker = ImagePicker();
  late FirebaseCollection firebaseCollection;

  late User? user;
  late AuthFunction _auth;
  late AppUser appUser;
  //late String url;
  String keyString = "";
  List<File> files = [];
  List<String> tentativeTags = [];
  List<String> userTags = [];

  ImPredState({required this.firebaseCollection}) {
    _auth = AuthFunction(firebaseCollection: firebaseCollection);
    user = firebaseCollection.firebaseAuth.currentUser;
    appUser = _auth.appUserFromUser(user)!;
  }

  @override
  void initState() {
    // timeString = now.day.toString() +
    //     now.month.toString() +
    //     now.year.toString() +
    //     now.hour.toString() +
    //     now.minute.toString() +
    //     now.second.toString();
    // keyString = timeString + "-" + user!.uid;

    //url = "";
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  pickImage() async {
    var image = await picker.pickImage(source: ImageSource.camera);
    //picker.pickVideo(source: ImageSource.gallery);
    if (image == null) return null;

    setState(() {
      _isLoading = false;
      picked = true;

      _image = File(image.path);
    });
  }

  pickGalleryImage() async {
    files.clear();
    //XFile? image = await picker.pickImage(source: ImageSource.gallery);
    List<XFile>? images = await picker.pickMultiImage();

    //if (image == null) return null;

    if (images!.isNotEmpty) {
      setState(() {
        _isLoading = false;
        picked = true;
        //_image = File(image!.path);

        images.forEach((element) {
          files.add(File(element.path));
        });
        pickedFromGallery = true;

        //files = images!.map((e) => File(e.path)).toList();
      });
    } else {
      _isLoading = true;
      picked = false;
    }
  }

  List<Widget> buildEditCards() {
    List<Widget> cards = [];
    // if (tags.length > 1) {
    //   DatabaseService(uid: user!.uid, firebaseCollection: firebaseCollection)
    //       .filterPhotos(tags)
    //       .then((value) => print(value));
    //

    for (var tag in tentativeTags) {
      cards.add(SearchCard(tag.toString(), () async {
        print(tentativeTags);
        setState(() {
          tentativeTags.removeWhere((element) => element == tag.toString());
        });
      }));
    }

    return cards;
  }

  Widget buildImage(File carouselImage, int index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12),
      color: Colors.grey,
      child: Image(image: FileImage(carouselImage)),
    );
  }

  List<String> collectTags(String str) {
    // if (str.trim().isEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //       content: Text("Your password has been changed"),
    //       duration: Duration(milliseconds: 750)));
    //   print("why");
    // } else {}
    var tags = str.split(',');

    // for (var item in tags) {
    //   if (item.trim().isEmpty) {
    //     tags.remove(item);
    //   }
    // }

    tags.removeWhere((element) => element.trim().isEmpty);
    setState(() {
      tentativeTags = tags;
    });

    return tags;
  }

  doUploads(
      TextEditingController _addTagContoller, List<File> uploadFiles) async {
    String url;
    var listOfTags = tentativeTags;
    //collectTags(_addTagContoller.text);
    if (listOfTags.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Tags Cannot Be Empty. Please Try Again"),
          duration: Duration(milliseconds: 750)));
    } else {
      for (int i = 0; i < uploadFiles.length; i++) {
        // uploadFiles.forEach((uploadFile) async {
        var photo = PhotoItem(
            uploadFiles[i].path, listOfTags, keyString + "-" + i.toString());
        Storage storage = Storage(firebaseCollection: firebaseCollection);
        listOfTags.forEach((element) async {
          var thing = (await storage.uploadFileWithTag(
              uploadFiles[i],
              element.trim().toLowerCase().trim(),
              keyString + "-" + i.toString()));

          // url = await (await storage.uploadFileToGeneral(
          //   _image,
          // ));
          // print(url);
        });
        // DatabaseService(
        //         uid: user!.uid,
        //         firebaseCollection: firebaseCollection)
        //     .updateUserTagList(listOfTags
        //         .map((e) => e.toLowerCase().trim())
        //         .toList());
        setState(() {
          now = DateTime.now();
          timeString = now.day.toString() +
              now.month.toString() +
              now.year.toString() +
              now.hour.toString() +
              now.minute.toString() +
              now.second.toString();
          keyString = timeString + "-" + user!.uid;
        });
        DatabaseService(uid: user!.uid, firebaseCollection: firebaseCollection)
            .uploadPostToDatabase(
                keyString + "-" + i.toString(),
                (await storage.uploadFileToGeneral(
                    uploadFiles[i], keyString + "-" + i.toString())),
                listOfTags.map((e) => e.toLowerCase().trim()).toList());
      }
      //Navigator.pop(context);

      // Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //         builder: (context) =>
      //             HomeScreen(firebaseCollection: firebaseCollection)));
    }
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController _addTagContoller = TextEditingController();

    //userTags.clear();
    // DatabaseService(uid: user!.uid, firebaseCollection: firebaseCollection)
    //     .getUserTags()
    //     .then((value) {
    //   value as List<dynamic>;
    //   for (var tag in value) {
    //     print(tag);

    //     userTags.add(tag.toString());
    //   }
    // });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("Upload"),
        leading: picked
            ? IconButton(
                onPressed: (() {
                  setState(() {
                    picked = false;
                    _isLoading = true;
                    pickedFromGallery = false;
                  });
                }),
                icon: Icon(Icons.arrow_back))
            : Icon(Icons.upload),
      ),
      //backgroundColor: Colors.blueAccent,
      body: Center(
        child: Container(
          // decoration: BoxDecoration(
          //   image: DecorationImage(
          //       image: AssetImage("assets/images/backImage5.jpeg"),
          //       fit: BoxFit.cover),
          // ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 40.0,
              ),
              Center(
                child: Text(
                  'Upload Image',
                  style: TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
              SizedBox(height: 20.0),
              Center(
                child: _isLoading
                    ? Container(
                        width: 200,
                        height: 200,
                        foregroundDecoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border(
                                // top: BorderSide(
                                //     color: Colors.lightBlue, width: 3),
                                // left: BorderSide(
                                //     color: Colors.lightBlue, width: 3),
                                // right: BorderSide(
                                //     color: Colors.lightBlue, width: 3),
                                // bottom: BorderSide(
                                //     color: Colors.lightBlue, width: 3)
                                )),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                image: AssetImage(
                                    "assets/images/default-image.jpeg"),
                                fit: BoxFit.cover)))
                    : pickedFromGallery
                        ? Column(children: [
                            CarouselSlider.builder(
                                itemCount: files.length,
                                itemBuilder: (context, index, realIndex) {
                                  final carouselImage = files[index];
                                  return buildImage(carouselImage, index);
                                },
                                options: CarouselOptions(
                                    height: 100, enableInfiniteScroll: false)),
                          ])
                        : Container(
                            child: Column(
                              children: [
                                Container(
                                    width: 200,
                                    height: 200,
                                    foregroundDecoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        border: Border(
                                            // top: BorderSide(
                                            //     color: Colors.lightBlue,
                                            //     width: 3),
                                            // left: BorderSide(
                                            //     color: Colors.lightBlue,
                                            //     width: 3),
                                            // right: BorderSide(
                                            //     color: Colors.lightBlue,
                                            //     width: 3),
                                            // bottom: BorderSide(
                                            //     color: Colors.lightBlue,
                                            //     width: 3)
                                            )),
                                    decoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        image: DecorationImage(
                                            image: FileImage(_image),
                                            fit: BoxFit.cover))),
                                SizedBox(
                                  height: 20.0,
                                ),
                                Container()
                              ],
                            ),
                          ),
              ),
              SizedBox(
                height: 20.0,
              ),
              Center(
                child: picked
                    ? Container(
                        child: Column(children: [
                        // TextField(
                        //   autofocus: true,
                        //   controller: _addTagContoller,
                        //   textInputAction: TextInputAction.done,
                        //   keyboardType: TextInputType.text,
                        //   decoration: InputDecoration(
                        //       hintText: "Add Tags",
                        //       contentPadding:
                        //           const EdgeInsets.fromLTRB(20, 15, 20, 15),
                        //       border: OutlineInputBorder(
                        //           borderRadius: BorderRadius.circular(10))),
                        // ),
                        AutocompleteBasicExample((p0) {
                          print(p0);
                          setState(() {
                            tentativeTags.add(p0);
                          });
                        }, firebaseCollection),
                        SizedBox(
                          height: 20.0,
                        ),
                        SingleChildScrollView(
                          child: Row(
                            children: buildEditCards(),
                          ),
                          scrollDirection: Axis.horizontal,
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            await doUploads(_addTagContoller, files);
                            setState(() {
                              _isLoading = true;
                              picked = false;
                              pickedFromGallery = false;
                            });

                            // timeString = now.day.toString() +
                            //     now.month.toString() +
                            //     now.year.toString() +
                            //     now.hour.toString() +
                            //     now.minute.toString() +
                            //     now.second.toString();
                            // keyString = timeString + "-" + user!.uid;
                            // String url;
                            // var listOfTags = collectTags(_addTagContoller.text);
                            // if (listOfTags.isEmpty) {
                            //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            //       content: Text(
                            //           "Tags Cannot Be Empty. Please Try Again"),
                            //       duration: Duration(milliseconds: 750)));
                            // } else {
                            //   var photo =
                            //       PhotoItem(_image.path, listOfTags, keyString);
                            //   Storage storage = Storage(
                            //       firebaseCollection: firebaseCollection);
                            //   listOfTags.forEach((element) async {
                            //     var thing = (await storage.uploadFileWithTag(
                            //         _image,
                            //         element.trim().toLowerCase().trim(),
                            //         keyString));

                            //     // url = await (await storage.uploadFileToGeneral(
                            //     //   _image,
                            //     // ));
                            //     // print(url);
                            //   });
                            //   // DatabaseService(
                            //   //         uid: user!.uid,
                            //   //         firebaseCollection: firebaseCollection)
                            //   //     .updateUserTagList(listOfTags
                            //   //         .map((e) => e.toLowerCase().trim())
                            //   //         .toList());
                            //   setState(() {
                            //     now = DateTime.now();
                            //   });
                            //   DatabaseService(
                            //           uid: user!.uid,
                            //           firebaseCollection: firebaseCollection)
                            //       .uploadPostToDatabase(
                            //           keyString,
                            //           (await storage.uploadFileToGeneral(
                            //               _image, keyString)),
                            //           listOfTags
                            //               .map((e) => e.toLowerCase().trim())
                            //               .toList());

                            //   Navigator.push(
                            //       context,
                            //       MaterialPageRoute(
                            //           builder: (context) => HomeScreen(
                            //               firebaseCollection:
                            //                   firebaseCollection)));
                          },
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.black),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 15.0),
                            child: Text(
                              'Confirm and Upload',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17.50,
                              ),
                            ),
                          ),
                        ),
                      ]))
                    : Container(
                        width: MediaQuery.of(context).size.width * 0.6,
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                pickImage();
                              },
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.black),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 15.0),
                                child: Text(
                                  'Take a picture',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17.5,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.01,
                            ),
                            ElevatedButton(
                              onPressed: () {
                                pickGalleryImage();
                              },
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.black),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0, vertical: 15.0),
                                child: Text(
                                  'Select from gallery',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17.50,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.01,
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.08,
                              width: MediaQuery.of(context).size.height * 0.2,
                              child: picked
                                  ? ElevatedButton(
                                      onPressed: () {},
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Colors.lightBlue),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12.0, vertical: 15.0),
                                        child: Text(
                                          'Add Tags',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 17.50,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container(),
                            )
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AutocompleteBasicExample extends StatelessWidget {
  List<String> options = [];
  List<String> newTags = [];
  void Function(String)? onSelected;
  String newTag = '';
  late FirebaseCollection firebaseCollection;
  late User? user;
  late AuthFunction _auth;

  AutocompleteBasicExample(this.onSelected, this.firebaseCollection) {
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

// class AutoCompleteTextField extends StatefulWidget {
//   final FirebaseCollection firebaseCollection;
//   AutoCompleteTextField({required this.firebaseCollection});
//   @override
//   AutoCompleteTextFieldState createState() {
//     {
//       return AutoCompleteTextFieldState(firebaseCollection: firebaseCollection);
//     }
//   }
// }

// class AutoCompleteTextFieldState extends State<AutoCompleteTextField> {
//   final FirebaseCollection firebaseCollection;
//   bool isLoading = false;

//   late List<String> autoCompleteData;

//   late TextEditingController controller;
//   List<String> options = [];
//   void Function(String)? onSelected;

//   AutoCompleteTextFieldState({required this.firebaseCollection});

//   Future fetchAutoCompleteData() async {
//     setState(() {
//       isLoading = true;
//     });

//     final String stringData = await rootBundle.loadString("assets/data.json");

//     final List<dynamic> json = jsonDecode(stringData);

//     final List<String> jsonStringData = json.cast<String>();

//     setState(() {
//       isLoading = false;
//       autoCompleteData = jsonStringData;
//     });
//   }

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     fetchAutoCompleteData();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Auto complete"),
//       ),
//       body: isLoading
//           ? Center(
//               child: CircularProgressIndicator(),
//             )
//           : Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 children: [
//                   Autocomplete(
//                     optionsBuilder: (TextEditingValue textEditingValue) {
//                       if (textEditingValue.text.isEmpty) {
//                         return const Iterable<String>.empty();
//                       } else {
//                         return autoCompleteData.where((word) => word
//                             .toLowerCase()
//                             .contains(textEditingValue.text.toLowerCase()));
//                       }
//                     },
//                     optionsViewBuilder:
//                         (context, Function(String) onSelected, options) {
//                       return Material(
//                         elevation: 4,
//                         child: ListView.separated(
//                           padding: EdgeInsets.zero,
//                           itemBuilder: (context, index) {
//                             final option = options.elementAt(index);

//                             return ListTile(
//                               // title: Text(option.toString()),
//                               title: SubstringHighlight(
//                                 text: option.toString(),
//                                 term: controller.text,
//                                 textStyleHighlight:
//                                     TextStyle(fontWeight: FontWeight.w700),
//                               ),
//                               subtitle: Text("This is subtitle"),
//                               onTap: () {
//                                 onSelected(option.toString());
//                               },
//                             );
//                           },
//                           separatorBuilder: (context, index) => Divider(),
//                           itemCount: options.length,
//                         ),
//                       );
//                     },
//                     onSelected: (selectedString) {
//                       print(selectedString);
//                     },
//                     fieldViewBuilder:
//                         (context, controller, focusNode, onEditingComplete) {
//                       this.controller = controller;

//                       return TextField(
//                         controller: controller,
//                         focusNode: focusNode,
//                         onEditingComplete: onEditingComplete,
//                         decoration: InputDecoration(
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                             borderSide: BorderSide(color: Colors.grey[300]!),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                             borderSide: BorderSide(color: Colors.grey[300]!),
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                             borderSide: BorderSide(color: Colors.grey[300]!),
//                           ),
//                           hintText: "Search Something",
//                           prefixIcon: Icon(Icons.search),
//                         ),
//                       );
//                     },
//                   )
//                 ],
//               ),
//             ),
//     );
//   }
// }
