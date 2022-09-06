// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meme_cloud/services/auth_function.dart';
import 'package:meme_cloud/firebase_collection.dart';
import 'package:meme_cloud/custom_widgets/formInputWidget.dart';
import 'package:meme_cloud/global_colours.dart';
import 'package:meme_cloud/loading.dart';

class LoginScreen extends StatefulWidget {
  final Function toggle;
  final FirebaseCollection firebaseCollection;
  LoginScreen({required this.toggle, required this.firebaseCollection});

  @override
  State<StatefulWidget> createState() {
    return _LoginScreenState(firebaseCollection: firebaseCollection);
  }
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late AuthFunction _auth;
  final FirebaseCollection firebaseCollection;
  bool loading = false;

  var error = "";

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  _LoginScreenState({required this.firebaseCollection}) {
    _auth = AuthFunction(firebaseCollection: firebaseCollection);
  }

  @override
  Widget build(BuildContext context) {
    Global globalColours = new Global();
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    var emailField = FormInputWidget(
      _emailController,
      TextInputAction.next,
      TextInputType.emailAddress,
      "Email",
      false,
      Icons.email,
      key: Key("email-field"),
    );

    var passwordField = FormInputWidget(
      _passwordController,
      TextInputAction.next,
      TextInputType.text,
      "Password",
      true,
      Icons.password,
      //(value) => PasswordFieldValidator.validate(value),
      key: Key("password-field"),
    );

    var loginButton = ElevatedButton(
      key: Key("login-button"),
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          setState(() {
            loading = true;
          });
          var player = await _auth.login(
              _emailController.text, _passwordController.text);
          if (player == null) {
            setState(() {
              error = "Invalid login credentials, please try again";
              loading = false;
            });
          }
        }
      },
      child: Text(
        "Login",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
          fixedSize: Size(MediaQuery.of(context).size.width, 50)),
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
                            height: 100,
                            child: Text(
                              "MOTUS",
                              style: TextStyle(
                                  fontFamily: "TypoRound",
                                  fontSize: 80,
                                  color: globalColours.baseColour,
                                  fontWeight: FontWeight.w900),
                            )),
                        Text(error,
                            style: TextStyle(color: Colors.red, fontSize: 16),
                            key: Key("invalid-email")),
                        SizedBox(height: 25),
                        emailField,
                        SizedBox(height: 25),
                        passwordField,
                        SizedBox(height: 25),
                        loginButton,
                        SizedBox(height: 15),
                        TextButton(
                            child: Text("Don't have an account? Sign up"),
                            onPressed: (() {
                              widget.toggle();
                            }),
                            key: Key("sign-up-link")),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ));
  }
}
