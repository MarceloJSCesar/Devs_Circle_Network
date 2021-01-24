import 'package:flutter/material.dart';
import 'package:social_media/pages/home.dart';
import 'package:social_media/widgets/header.dart';

class Comments extends StatefulWidget {
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;

  Comments({this.postId, this.postOwnerId, this.postMediaUrl});
  @override
  CommentsState createState() => CommentsState(
      postId: this.postId,
      postOwnerId: this.postOwnerId,
      postMediaUrl: this.postMediaUrl);
}

class CommentsState extends State<Comments> {
  // our textField to comment
  TextEditingController _commentController = TextEditingController();
  // our construtor to got use the variables without errors
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;

  CommentsState({this.postId, this.postOwnerId, this.postMediaUrl});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context,
          isHomeTitle: false,
          titleText: 'Comments',
          removeLeading: false,
          background: Colors.white),
      body: Column(
        children: <Widget>[
          Expanded(child: buildComments()),
          Divider(),
          ListTile(
            title: TextFormField(
              controller: _commentController,
              decoration: InputDecoration(hintText: 'Write a comment ...'),
            ),
            trailing: OutlineButton(
              onPressed: addingComment,
              borderSide: BorderSide.none,
              child: Text('Post'),
            ),
          ),
        ],
      ),
    );
  }

  // to handle with comments, showing up
  buildComments() {
    return Text('Comment');
  }

  // to handle with sending comments
  addingComment() {
    commentRef.doc(postId).collection('comments').add({
      'username': currentUser.name,
      'comment': _commentController.text,
      'timestamp': timeStamp,
      'avatarUrl': currentUser.photoUrl,
      'userId': currentUser.id
    });
    _commentController.clear();
  }
}

class Comment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text('Comment');
  }
}
