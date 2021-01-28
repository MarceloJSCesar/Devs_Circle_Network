import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:social_media/widgets/header.dart';

class ViewerNews extends StatelessWidget {
  final dynamic data;
  ViewerNews(this.data);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: header(context,
            isHomeTitle: false,
            titleText: 'Viewer Page',
            background: Colors.black,
            color: Colors.white,
            removeLeading: false),
        backgroundColor: Colors.black,
        body: Container(
            margin: const EdgeInsets.fromLTRB(10, 50, 10, 0),
            child: _newsData(context)));
  }

// function to show all the data that our future builder are receiving , we go through snapshot to get all the data
  Column _newsData(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Image(
          image: CachedNetworkImageProvider(data['urlToImage']),
        ),
        SizedBox(
          height: 30,
        ),
        RichText(
          text: TextSpan(
              text: 'Author:   ',
              style: TextStyle(color: Colors.white, fontSize: 17),
              children: [
                TextSpan(
                  text: data['author'],
                  style: TextStyle(color: Colors.grey[300], fontSize: 15),
                )
              ]),
        ),
        SizedBox(
          height: 20,
        ),
        RichText(
          text: TextSpan(
              text: 'Title:   ',
              style: TextStyle(color: Colors.white, fontSize: 17),
              children: [
                TextSpan(
                  text: data['title'],
                  style: TextStyle(color: Colors.grey[300], fontSize: 15),
                )
              ]),
        ),
        SizedBox(height: 20,),
        RichText(
          text: TextSpan(
              text: 'Description:   ',
              style: TextStyle(color: Colors.white, fontSize: 17),
              children: [
                TextSpan(
                  text: data['description'],
                  style: TextStyle(color: Colors.grey[300], fontSize: 15),
                )
              ], 
            ),
        ),
      ],
    );
  }
}
