import 'package:flutter/material.dart';

AppBar header(
  context,
    {
    // doing some ternary condition if isHomeTitle to can use at different pages
    bool isHomeTitle = false,
    removeLeading = false,
    Color background,
    Color color,
    String titleText}) {
  return AppBar(
    automaticallyImplyLeading: removeLeading ? false : true,
    backgroundColor: background,
    elevation: 0,
    centerTitle: true,
    title: Text(
      isHomeTitle ? 'Devs Circle' : titleText,
      style: TextStyle(
        color: color,
        fontSize: isHomeTitle ? 35.0 : 25.0,
        fontFamily: 'Signatra',
      ),
      // text will desapier when transbord (rolar para baixo, ta da pa intendi, haha)
      overflow: TextOverflow.ellipsis,
    ),
    leading: removeLeading
        ? Text('')
        : IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
  );
}
