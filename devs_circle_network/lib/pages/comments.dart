import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_media/pages/home.dart';
import 'package:social_media/widgets/header.dart';
import 'package:social_media/widgets/progress.dart';
import 'package:timeago/timeago.dart' as timeago;

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

  //our key to validate our input comment
  GlobalKey<FormState> _commentKey = GlobalKey<FormState>();
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
      body: Container(
        margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: Column(
          children: <Widget>[
            Expanded(child: buildComments()),
            Divider(),
            Container(
              margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10)),
              child: Form(
                key: _commentKey,
                child: ListTile(
                  title: TextFormField(
                    controller: _commentController,
                    validator: (val) {
                      if (val.isEmpty) {
                        return 'comment invalid';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        hintText: 'Write a comment ...',
                        border: InputBorder.none),
                  ),
                  trailing: OutlineButton(
                    onPressed: () {
                      if (_commentKey.currentState.validate()) {
                        addingComment();
                      }
                    },
                    borderSide: BorderSide.none,
                    child: Text('Post'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // to handle with comments, showing up
  buildComments() {
    return StreamBuilder(
      stream: commentRef
          .doc(postId)
          .collection('comments')
          .orderBy('timestamp', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<Comment> comments = [];
        snapshot.data.docs.forEach((doc) {
          comments.add(Comment.fromDocument(doc));
        });
        return ListView(
          children: comments,
        );
      },
    );
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
    // checking if current user id is different than user post id
    bool isNotPostOwner = postOwnerId != currentUser.id;
    if (isNotPostOwner) {
      actividyFeedRef.doc(postOwnerId).collection('feedItems').add({
        'type': 'comment',
        'commentData': _commentController.text,
        'username': currentUser.name,
        'userId': currentUser.id,
        'userProfileImg': currentUser.photoUrl,
        'postId': postId,
        'timestamp': timeStamp,
        'mediaUrl': postMediaUrl
      });
    }
    _commentController.clear();
  }
}

class Comment extends StatelessWidget {
  final String userId;
  final String comment;
  final String username;
  final Timestamp timestamp;
  final String avatarUrl;

  Comment({
    this.userId,
    this.comment,
    this.username,
    this.timestamp,
    this.avatarUrl,
  });

  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
      userId: doc['userId'],
      comment: doc['comment'],
      username: doc['username'],
      timestamp: doc['timestamp'],
      avatarUrl: doc['avatarUrl'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(comment),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(avatarUrl),
          ),
          subtitle: Text(timeago.format(timestamp.toDate())),
        ),
        Divider(),
      ],
    );
  }
}
