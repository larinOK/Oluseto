// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meme_cloud/firebase_collection.dart';
import 'package:meme_cloud/models/user.dart';
import 'package:meme_cloud/services/database.dart';

import '../services/auth_function.dart';

class SettingsPage extends StatefulWidget {
  final FirebaseCollection firebaseCollection;
  late User? user;
  late AuthFunction _auth;

  SettingsPage({required this.firebaseCollection}) {
    _auth = AuthFunction(firebaseCollection: firebaseCollection);
    user = firebaseCollection.firebaseAuth.currentUser;
  }

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool editClicked = false;

  final TextStyle headerStyle = TextStyle(
    color: Colors.grey.shade600,
    fontWeight: FontWeight.bold,
    fontSize: 20.0,
  );

  @override
  Widget build(BuildContext context) {
    //final user = Provider.of<User?>(context, listen: false);

    return StreamBuilder<AppUserData?>(
        stream: DatabaseService(
                uid: widget.user!.uid,
                firebaseCollection: widget.firebaseCollection)
            .userData,
        builder: (context, snapshot) {
          return Scaffold(
              appBar: AppBar(
                  backgroundColor: Colors.orangeAccent,
                  automaticallyImplyLeading: false,
                  centerTitle: true,
                  title: Text("SETTINGS",
                      key: Key("settings-display"),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                          color: Colors.white))),
              body: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "ACCOUNT",
                          style: headerStyle,
                          key: Key("account-display"),
                        ),
                        const SizedBox(height: 10.0),
                        Card(
                          elevation: 0.5,
                          margin: const EdgeInsets.symmetric(
                            vertical: 4.0,
                            horizontal: 0,
                          ),
                          child: Column(
                            children: <Widget>[
                              ListTile(
                                leading: Icon(
                                  Icons.person,
                                  size: 30,
                                ),
                                trailing: editClicked
                                    ? Icon(Icons.arrow_drop_down)
                                    : Icon(Icons.arrow_right),
                                dense: false,
                                title: Text("Edit your profile"),
                                onTap: () {
                                  setState(() {
                                    editClicked = !editClicked;
                                  });
                                  print(editClicked);
                                  // Navigator.push(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //         builder: (context) =>
                                  //             EditProfileScreen(
                                  //                 firebaseCollection:
                                  //                     firebaseCollection)));
                                },
                                key: Key("edit-profile"),
                              ),
                              editClicked
                                  ? Column(
                                      children: [
                                        ListTile(
                                          leading: Icon(
                                            Icons.password,
                                            size: 30,
                                          ),
                                          dense: false,
                                          title: Text("Change password"),
                                          onTap: () {
                                            // Navigator.push(
                                            //     context,
                                            //     MaterialPageRoute(
                                            //         builder: (context) =>
                                            //             EditProfileScreen(
                                            //                 firebaseCollection:
                                            //                     firebaseCollection)));
                                          },
                                          key: Key("edit-profile"),
                                        ),
                                      ],
                                    )
                                  : _buildDivider(),
                              _buildDivider(),
                              // ListTile(
                              //   leading: Icon(Icons.password),
                              //   title: Text("Change your password"),
                              //   onTap: () {
                              //     Navigator.push(
                              //         context,
                              //         MaterialPageRoute(
                              //             builder: (context) => ChangePassword(
                              //                 firebaseCollection:
                              //                     firebaseCollection)));
                              //   },
                              //   key: Key("change-password"),
                              // ),
                              _buildDivider(),
                              // ListTile(
                              //   leading: Icon(Icons.brightness_6),
                              //   title: themeManager.themeMode ==
                              //           themeManager.darkTheme
                              //       ? Text("Light mode")
                              //       : Text("Dark mode"),
                              //   onTap: () {
                              //     themeManager.toggleTheme();
                              //   },
                              //   key: Key("dark-mode"),
                              // ),
                              _buildDivider(),
                              ListTile(
                                leading: Icon(Icons.help),
                                title: Text("Help"),
                                dense: false,
                                onTap: () {
                                  DatabaseService(
                                          firebaseCollection:
                                              widget.firebaseCollection,
                                          uid: widget.user!.uid)
                                      .updateFirstLoad(true);
                                },
                              ),
                              _buildDivider(),
                              _buildDivider(),
                              _buildDivider(),
                              ListTile(
                                leading: Icon(Icons.exit_to_app_outlined),
                                title: Text("Sign Out"),
                                dense: false,
                                onTap: () {
                                  widget._auth.signOut();
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20.0)
                      ])));
        });
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
}
