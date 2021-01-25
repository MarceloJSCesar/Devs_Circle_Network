import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:social_media/widgets/header.dart';
import 'package:social_media/widgets/post_tile.dart';
import 'package:social_media/widgets/progress.dart';
import 'package:social_media/widgets/post.dart';
import 'package:social_media/pages/home.dart';
import 'package:social_media/pages/search.dart';
import 'package:social_media/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Timeline extends StatefulWidget {
  final currentUser;
  Timeline({this.currentUser});
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  bool isLoading = false;
  // number of userPost
  int postCount = 0;
  // list where all the photos will be saved
  List<Post> posts = [];
  @override
  void initState() {
    getProfilePosts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: header(context,
            isHomeTitle: true, removeLeading: true, background: Colors.white),
        body: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                   Container(
                     margin: const EdgeInsets.fromLTRB(20,0,10,10),
                     child: CircleAvatar(
                          backgroundColor: Colors.red,
                          backgroundImage: CachedNetworkImageProvider(currentUser.photoUrl),
                        ),
                   ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(currentUser.name),
                        Text(currentUser.bio, style: TextStyle(
                          color: Colors.grey[700]
                        ),),
                      ],
                    ),
                    ]
                ),
                buildProfilePosts(),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
        ),
        );
  }

  getProfilePosts() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await postsRef
        .doc(widget.currentUser?.id)
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        .get();
    setState(() {
      isLoading = false;
      postCount = snapshot.docs.length;
      posts = snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
      print(posts.length);
    });
  }

  buildProfilePosts() {
    if (isLoading) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SvgPicture.asset(
              'assets/images/no_content.svg',
              height: 260.0,
            ),
            SizedBox(
              height: 20,
            ),
            Text('No Post Yet',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20)),
          ],
        ),
      );
    } else {
      List<GridTile> gridTiles = [];
      posts.forEach((post) {
        gridTiles.add(GridTile(child: PostTile(post)));
      });
      return GridView.count(
        crossAxisCount: 1,
        crossAxisSpacing: 1.5,
        mainAxisSpacing: 1.5,
        childAspectRatio: 1.0,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridTiles,
      );
    }
  }
}
