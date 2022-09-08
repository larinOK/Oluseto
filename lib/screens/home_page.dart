import 'package:flutter/material.dart';
import 'package:meme_cloud/screens/home_screen.dart';
import 'package:meme_cloud/screens/search_page.dart';
import 'package:meme_cloud/screens/upload.dart';
import 'package:meme_cloud/screens/view_tags.dart';
//import 'package:game_demo/services/theme.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import '../firebase_collection.dart';
import 'package:provider/provider.dart';
//import 'user_profile.dart';

import '/global_colours.dart';
import 'package:flutter/scheduler.dart';

class HomePage extends StatefulWidget {
  final FirebaseCollection firebaseCollection;
  const HomePage({Key? key, required this.firebaseCollection})
      : super(key: key);

  @override
  State<HomePage> createState() =>
      _HomePageState(firebaseCollection: firebaseCollection);
}

class _HomePageState extends State<HomePage> {
  PersistentTabController tabController =
      PersistentTabController(initialIndex: 1);

  final FirebaseCollection firebaseCollection;
  _HomePageState({required this.firebaseCollection});

  final Global globalColours = new Global();

  @override
  Widget build(BuildContext context) {
    //ThemeManager themeManager = Provider.of<ThemeManager>(context, listen: false);

    return PersistentTabView(context,
        backgroundColor: Colors.brown,
        //Color.fromRGBO(72, 68, 68, 1),
        screens: _buildScreens(),
        controller: tabController,
        decoration: NavBarDecoration(boxShadow: [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 10,
          ),
        ]),
        items: _navigationBarItems(),
        resizeToAvoidBottomInset: true,
        popActionScreens: PopActionScreensType.all,
        itemAnimationProperties: ItemAnimationProperties(
            duration: Duration(milliseconds: 200), curve: Curves.ease),
        screenTransitionAnimation: ScreenTransitionAnimation(
            animateTabTransition: true,
            duration: Duration(
                milliseconds:
                    100), // keep duration time LOW otherwise there is a black screen if tabs are switched quickly.
            curve: Curves.fastLinearToSlowEaseIn),
        navBarStyle: NavBarStyle.neumorphic,
        key: Key("navbar"));
  }

  List<Widget> _buildScreens() {
    return [
      HomeScreen(
        firebaseCollection: firebaseCollection,
      ),
      UploadPhoto(firebaseCollection: firebaseCollection),
      SearchPage(firebaseCollection: firebaseCollection),
      TagPage(firebaseCollection: firebaseCollection)

      //ProfilePage(firebaseCollection: firebaseCollection)
    ];
  }

  List<PersistentBottomNavBarItem> _navigationBarItems() {
    return [
      PersistentBottomNavBarItem(
          icon: Icon(Icons.photo_library),
          title: "Photos",
          activeColorPrimary: globalColours.baseColour,
          inactiveColorPrimary: Colors.grey),
      PersistentBottomNavBarItem(
          icon: Icon(Icons.camera_alt),
          title: "Upload",
          activeColorPrimary: globalColours.baseColour,
          inactiveColorPrimary: Colors.grey),
      PersistentBottomNavBarItem(
          icon: Icon(Icons.search),
          title: "Search",
          activeColorPrimary: globalColours.baseColour,
          inactiveColorPrimary: Colors.grey),
      PersistentBottomNavBarItem(
          icon: Icon(Icons.label, key: Key("profile-link")),
          title: "Tags",
          activeColorPrimary: globalColours.baseColour,
          inactiveColorPrimary: Colors.grey),
    ];
  }
}
