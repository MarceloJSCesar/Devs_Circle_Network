import 'package:flutter/material.dart';
import 'package:social_media/pages/home.dart';
import 'package:social_media/widgets/header.dart';
import 'package:social_media/widgets/post.dart';
import 'package:social_media/widgets/progress.dart';

class PostScreen extends StatelessWidget {
  // reuqesting these two variables to show up image and some user data
  final String userId;
  final String postId;

  PostScreen({this.userId, this.postId});
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: postsRef.doc(userId).collection('userPosts').doc(postId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        // using the post structure from post page and using the data to show up
        Post post = Post.fromDocument(snapshot.data);
        return Center(
          child: Scaffold(
            appBar: header(context, isHomeTitle: false, titleText: post.description, removeLeading: false, background: Colors.white),
            body: ListView(
              children: <Widget>[
                Container(
                  child: post,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
