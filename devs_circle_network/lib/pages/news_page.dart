import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:social_media/pages/news_viewer.dart';
import 'package:social_media/widgets/header.dart';
import 'package:social_media/widgets/progress.dart';
import 'package:transparent_image/transparent_image.dart';


// our api variable where is the url ( json format )
final api =
    'https://newsapi.org/v2/everything?q=technology&apiKey=c67f55f7f5554a70a6048cd61c90d3a6';

class NewsPage extends StatefulWidget {
  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(
        context,
        isHomeTitle: false,
        titleText: 'Tech News',
        background: Colors.black,
        color: Colors.white,
        removeLeading: true
      ),
      backgroundColor: Colors.black,
      body: FutureBuilder(
        future: _getApi(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Column();
            default:
              if (snapshot.hasError || snapshot.connectionState == ConnectionState.waiting) {
                return circularProgress();
              } else {
                return Container(
                  margin: EdgeInsets.only(top: 20),
                  child: _news(context, snapshot),
                );
              }
          }
        },
      ),
    );
  }

//function to show all the data that our future builder are receiving , we go through snapshot to get all the data
  Widget _news(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(10, 10, 20, 0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        crossAxisSpacing: 5.0,
        mainAxisSpacing: 5.0,
      ),
      itemCount: snapshot.data['articles'].length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ViewerNews(snapshot.data['articles'][index])),
            );
          },
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                shape: BoxShape.rectangle,
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(
                        snapshot.data['articles'][index]['urlToImage']))),
            padding: EdgeInsets.fromLTRB(0, 0, 10, 10),
              child: FadeInImage.memoryNetwork(
                placeholder: kTransparentImage,
                image: snapshot.data['articles'][index]['urlToImage'],
                fit: BoxFit.none,
              ),
          ),
        );
      },
    );
  }

// will make a request to our api and giving us the all data
  Future<Map> _getApi() async {
    http.Response response = await http.get(api);
    return json.decode(response.body);
  }
}
