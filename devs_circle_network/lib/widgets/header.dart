import 'package:flutter/material.dart';

AppBar header(
  context,
    {
    // doing some ternary condition if isHomeTitle to can use at different pages
    bool isHomeTitle = false,
    removeLeading = false,
    Color background,
    String titleText}) {
  return AppBar(
    automaticallyImplyLeading: removeLeading ? false : true,
    backgroundColor: background,
    elevation: 0,
    centerTitle: true,
    title: Text(
      isHomeTitle ? 'Devs Circle' : titleText,
      style: TextStyle(
        color: Colors.black,
        fontSize: isHomeTitle ? 35.0 : 25.0,
        fontFamily: 'Signatra',
      ),
    ),
    leading: removeLeading
        ? Text('')
        : IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
  );
}
