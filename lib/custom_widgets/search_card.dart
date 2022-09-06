import 'package:flutter/material.dart';

class SearchCard extends StatelessWidget {
  String title;
  void Function()? onPressed;

  SearchCard(this.title, this.onPressed);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: (() {}),
        child: Container(
          height: 40.0,
          padding: EdgeInsets.symmetric(vertical: 3.0, horizontal: 7.0),
          margin: EdgeInsets.symmetric(horizontal: 5.0),
          child: Row(
            children: [
              Text(title,
                  style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.black)),
              IconButton(
                  onPressed: onPressed,
                  icon: Icon(
                    Icons.cancel,
                    size: 20.0,
                  ))
            ],
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
            color: Colors.grey[200],
          ),
        ));
  }
}
