import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'firebase_collection.dart';
import 'screens/results_page.dart';
import 'screens/search_page.dart';
import 'search_card.dart';
import 'services/auth_function.dart';
import 'services/database.dart';

class TagSearch extends SearchDelegate {
  List<dynamic> tagList;
  final FirebaseCollection firebaseCollection;
  late User? user;
  late AuthFunction _auth;
  late DatabaseService databaseService;
  late TextEditingController controller;
  List<String> searchTerms = [];
  List<Widget> tagCards = [];

  TagSearch(this.tagList, this.firebaseCollection) {
    _auth = AuthFunction(firebaseCollection: firebaseCollection);
    user = firebaseCollection.firebaseAuth.currentUser;
    databaseService =
        DatabaseService(uid: user!.uid, firebaseCollection: firebaseCollection);
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      Icon(Icons.abc),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: Icon(Icons.arrow_back_ios));
  }

  @override
  Widget buildResults(BuildContext context) {
    var suggestions = tagList
        .where((element) => element.toString().contains(query.toLowerCase()));

    var suggList = suggestions.toList();
    suggList.sort(
      (a, b) => a.compareTo(b),
    );

    return ListView.builder(
      itemBuilder: (context, index) {
        return ListTile(
          onTap: () {
            String term = suggList[index].toString();
            searchTerms.forEach((element) {
              if (element == term) {}
            });
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ResultsPage(
                        firebaseCollection: firebaseCollection,
                        tags: searchTerms)));
            searchTerms.add(term);

            for (var item in searchTerms) {
              tagCards.add(SearchCard(item, () {
                searchTerms.remove(item);
              }));
            }
          },
          title: Text(suggList[index]),
        );
      },
      itemCount: suggList.length,
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    var suggestions = tagList.where((element) =>
        element.toString().toLowerCase().contains(query.toLowerCase()));

    var suggList = suggestions.toList();
    suggList.sort(
      (a, b) => a.compareTo(b),
    );

    return ListView.builder(
      itemBuilder: (context, index) {
        return ListTile(
          onTap: () {
            String term = suggList[index].toString();
            searchTerms.forEach((element) {
              if (element == term) {}
            });

            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ResultsPage(
                        firebaseCollection: firebaseCollection,
                        tags: searchTerms)));
            searchTerms.add(term);
          },
          title: Text(suggList[index]),
        );
      },
      itemCount: suggList.length,
    );
  }
}
