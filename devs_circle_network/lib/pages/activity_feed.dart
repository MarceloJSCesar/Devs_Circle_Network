import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_media/pages/home.dart';
import 'package:social_media/widgets/header.dart';
import 'package:social_media/widgets/progress.dart';
import 'package:timeago/timeago.dart' as timeago;

class ActivityFeed extends StatefulWidget {
  @override
  _ActivityFeedState createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context,
          isHomeTitle: false,
          titleText: 'Actividy Feed',
          background: Colors.white,
          removeLeading: true),
      body: Container(
        child: FutureBuilder(
          future: getActividyFeed(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return circularProgress();
            }
            return ListView(
              children: snapshot.data,
            );
          },
        ),
      ),
    );
  }

  // function to get data from users actions , will return a future
  getActividyFeed() async {
    QuerySnapshot snapshot = await actividyFeedRef
        .doc(currentUser.id)
        .collection('feedItems')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .get();
    List<ActivityFeedItem> feedItems = [];
    snapshot.docs.forEach((doc) {
      feedItems.add(ActivityFeedItem.fromDocument(doc));
    });
    return feedItems;
  }
}

// the variable where will saved tyhe widget to display image
Widget mediaPreview;

String actividyItemText;

class ActivityFeedItem extends StatelessWidget {
  final String postId;
  final String commentData;
  final String userId;
  final String type; // likes, follower, comment
  final String mediaUrl;
  final String username;
  final String userProfileImg;
  final Timestamp timestamp;

  ActivityFeedItem({
    this.commentData,
    this.postId,
    this.userId,
    this.type, // likes, follower, comment
    this.mediaUrl,
    this.username,
    this.userProfileImg,
    this.timestamp,
  });

  factory ActivityFeedItem.fromDocument(DocumentSnapshot doc) {
    return ActivityFeedItem(
      commentData: doc['commentData'],
      postId: doc['postId'],
      userId: doc['userId'],
      type: doc['type'],
      mediaUrl: doc['mediaUrl'],
      username: doc['username'],
      userProfileImg: doc['userProfileImg'],
      timestamp: doc['timestamp'],
    );
  }

  configureMediaPreview() {
    if (type == 'type' || type == 'comment') {
      mediaPreview = GestureDetector(
        onTap: () => print('media preview tapped'),
        child: Container(
          height: 50.0,
          width: 50.0,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: CachedNetworkImageProvider(mediaUrl))),
            ),
          ),
        ),
      );
    } else {
      mediaPreview = Text('');
    }

    if (type == 'like') {
      actividyItemText = 'liked your post';
    } else if (type == 'follow') {
      actividyItemText = 'is following you';
    } else if (type == 'comment') {
      actividyItemText = 'replied: $commentData';
    } else {
      actividyItemText = "ERROR type : '$type'";
    }
  }

  @override
  Widget build(BuildContext context) {
    configureMediaPreview();
    return Padding(
      padding: EdgeInsets.only(bottom: 2.0),
      child: Container(
        color: Colors.white54,
        child: ListTile(
          title: GestureDetector(
            onTap: () => print('show comment'),
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: TextStyle(fontSize: 14.0, color: Colors.black),
                children: [
                  TextSpan(
                    text: username,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: ' $actividyItemText'),
                ],
              ),
            ),
          ),
          leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(userProfileImg)),
          subtitle: Text(
            timeago.format(timestamp.toDate()),
            overflow: TextOverflow.ellipsis,
          ),
          trailing: mediaPreview,
        ),
      ),
    );
  }
}
