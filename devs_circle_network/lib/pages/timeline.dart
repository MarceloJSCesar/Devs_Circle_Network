import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:social_media/pages/chat_screen.dart';
import 'package:social_media/pages/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Timeline extends StatefulWidget {
  final currentUser;
  Timeline({this.currentUser});
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          'Devs Circle',
        style: TextStyle(fontSize: 17),
        ),
       actions: [
         IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => ChatScreen()
            )),
            icon: Icon(Icons.sms_outlined, color: Colors.white,),
          )
       ],
      ),
      backgroundColor: Colors.black,
      body: FutureBuilder(
        future: getPhotosItems(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: Text(
              'No posts yet',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ));
          }
          return Container();
        },
      ),
    );
  }
}

// function to get data from users actions , will return a future
getPhotosItems() async {
  QuerySnapshot snapshot = await actividyFeedRef
      .doc('idAllPost1')
      .collection('userPosts')
      .orderBy('timestamp', descending: true)
      .limit(50)
      .get();
  List<PhotosItems> photosItems = [];
  snapshot.docs.forEach((doc) {
    photosItems.add(PhotosItems.fromDocument(doc));
    print('photosItem: ${photosItems.length}, Snapshot: ${doc.data()}');
  });
  return photosItems;
}

class PhotosItems extends StatelessWidget {
  final String postId;
  final String userId;
  final String description;
  final String mediaUrl;
  final String username;
  final String userProfileImg;
  final Timestamp timestamp;
  final Map likes;

  PhotosItems({
    this.likes,
    this.postId,
    this.userId,
    this.description, // likes, follower, comment
    this.mediaUrl,
    this.username,
    this.userProfileImg,
    this.timestamp,
  });

  factory PhotosItems.fromDocument(DocumentSnapshot doc) {
    return PhotosItems(
      likes: doc['likes'],
      postId: doc['postId'],
      userId: doc['userId'],
      description: doc['type'],
      mediaUrl: doc['description'],
      username: doc['username'],
      userProfileImg: doc['userProfileImg'],
      timestamp: doc['timestamp'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(
        username,
        style: TextStyle(color: Colors.red),
      ),
    );
  }
}
