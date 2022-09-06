// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:meme_cloud/services/auth_function.dart';
import 'package:meme_cloud/firebase_collection.dart';
import 'package:meme_cloud/formInputWidget.dart';
import 'package:meme_cloud/global_colours.dart';
import 'package:meme_cloud/screens/home_screen.dart';
import 'package:meme_cloud/loading.dart';

class SignUpScreen extends StatefulWidget {
  final Function toggle;
  final FirebaseCollection firebaseCollection;

  SignUpScreen({required this.toggle, required this.firebaseCollection});

  @override
  State<StatefulWidget> createState() {
    return _SignUpScreenState(firebaseCollection: firebaseCollection);
  }
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool loading = false;
  final _formKey = GlobalKey<FormState>();
  late FirebaseCollection firebaseCollection;
  late AuthFunction _auth;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  var _passwordVisible;
  var _confirmPasswordVisible;

  @override
  void initState() {
    _passwordVisible = false;
    _confirmPasswordVisible = true;
  }

  _SignUpScreenState({required this.firebaseCollection}) {
    _auth = AuthFunction(firebaseCollection: firebaseCollection);
  }

  @override
  Widget build(BuildContext context) {
    Global globalColours = new Global();
    var nameField = FormInputWidget(_nameController, TextInputAction.next,
        TextInputType.name, "Name", false, Icons.person);

    var emailField = FormInputWidget(_emailController, TextInputAction.next,
        TextInputType.emailAddress, "Email", false, Icons.email);

    var passwordField = TextFormField(
      controller: _passwordController,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.visiblePassword,
      obscureText: !_passwordVisible,
      decoration: InputDecoration(
          prefixIcon: Icon(Icons.password),
          hintText: "Password",
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          suffix: IconButton(
            icon: Icon(
                _passwordVisible ? Icons.visibility : Icons.visibility_off),
            iconSize: 12.0,
            onPressed: () {
              setState(() {
                _passwordVisible = !_passwordVisible;
              });
            },
          )),
    );

    var confirmPasswordField = TextFormField(
      controller: _confirmPasswordController,
      textInputAction: TextInputAction.done,
      keyboardType: TextInputType.visiblePassword,
      obscureText: !_confirmPasswordVisible,
      decoration: InputDecoration(
          hintText: "Password",
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          prefixIcon: Icon(Icons.password),
          suffix: IconButton(
            icon: Icon(_confirmPasswordVisible
                ? Icons.visibility
                : Icons.visibility_off),
            iconSize: 12.0,
            onPressed: () {
              setState(() {
                _confirmPasswordVisible = !_confirmPasswordVisible;
              });
            },
          )),
    );

    var signUpButton = ElevatedButton(
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          var user = await _auth.signUp(_nameController.text,
              _emailController.text, _passwordController.text);
          if (user == null) {
            loading = false;
          }
        }
      },
      child: Text(
        "Sign Up",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    return loading
        ? Loading()
        : Scaffold(
            body: Center(
            child: SingleChildScrollView(
              child: Container(
                child: Padding(
                  padding: EdgeInsets.all(36.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                            height: 120,
                            child: Text(
                              "MEMES",
                              style: TextStyle(
                                  fontFamily: "TypoRound",
                                  fontSize: 80,
                                  color: globalColours.baseColour,
                                  fontWeight: FontWeight.w900),
                            )),
                        Text("MEMES",
                            style: TextStyle(color: Colors.red, fontSize: 16)),
                        SizedBox(height: 25),
                        nameField,
                        SizedBox(height: 25),
                        emailField,
                        SizedBox(height: 25),
                        passwordField,
                        SizedBox(height: 25),
                        confirmPasswordField,
                        SizedBox(height: 15),
                        signUpButton,
                        SizedBox(height: 15),
                        TextButton(
                            key: Key("log-in-button"),
                            child: Text("Already have an account? Log in"),
                            onPressed: (() {
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) => HomeScreen()));
                              widget.toggle();
                            })),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ));
  }
}
