import 'dart:async';

import 'package:animator/animator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_media/models/user.dart';
import 'package:social_media/pages/activity_feed.dart';
import 'package:social_media/pages/comments.dart';
import 'package:social_media/pages/home.dart';
import 'package:social_media/widgets/custom_image.dart';
import 'package:social_media/widgets/progress.dart';

class Post extends StatefulWidget {
  final String postId;
  final String username;
  final String location;
  final String ownerId;
  final String mediaUrl;
  final String description;
  final dynamic likes;

  Post(
      {this.username,
      this.likes,
      this.postId,
      this.mediaUrl,
      this.ownerId,
      this.location,
      this.description});

  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      postId: doc['postId'],
      ownerId: doc['ownerId'],
      likes: doc['likes'],
      mediaUrl: doc['mediaUrl'],
      location: doc['location'],
      username: doc['username'],
      description: doc['description'],
    );
  }

  int getLikesAccount(likes) {
    // if likes equal to null return 0 like;
    if (likes == null) {
      return 0;
    }
    int count = 0;
    likes.values.forEach((val) {
      if (val == true) {
        count += 1;
      }
    });
    return count;
  }

  @override
  _PostState createState() => _PostState(
        postId: this.postId,
        ownerId: this.ownerId,
        description: this.description,
        location: this.location,
        username: this.username,
        likes: this.likes,
        mediaUrl: this.mediaUrl,
        likesCount: getLikesAccount(this.likes),
      );
}

class _PostState extends State<Post> {
  final String currentUserId = currentUser?.id;
  final String postId;
  final String username;
  final String location;
  final String ownerId;
  final String mediaUrl;
  final String description;
  int likesCount;
  Map likes;
  bool isLiked;
  bool showHeart = false;

  _PostState(
      {this.username,
      this.likes,
      this.postId,
      this.mediaUrl,
      this.ownerId,
      this.location,
      this.likesCount,
      this.description});

  @override
  Widget build(BuildContext context) {
    isLiked = (likes[currentUserId] == true);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buildPostHeader(),
        buildPostImage(),
        buildPostFooter(),
      ],
    );
  }

  buildPostHeader() {
    return FutureBuilder(
      future: userRef.doc(ownerId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        UserData user = UserData.fromDocument(snapshot.data);
        bool isPostOwner = currentUserId == ownerId;
        return ListTile(
          leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(user.photoUrl),
              backgroundColor: Colors.grey),
          title: GestureDetector(
            onTap: () => showProfile(context, profileId: user.id),
            child: Text(
              user.name,
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          subtitle: Text(
            location,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          trailing: isPostOwner
              ? IconButton(
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.white,
                  ),
                  onPressed: () => handleDeletePost(context),
                )
              : Text(''),
        );
      },
    );
  }

  handleDeletePost(BuildContext context) {
    return showDialog(
        context: context,
        builder: (_) {
          return SimpleDialog(
            title: Text('Remove this post?'),
            children: [
              SimpleDialogOption(
                child: Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  deletePost();
                },
              ),
              SimpleDialogOption(
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }

  // this function will work only isOwnerId , only on your post
  deletePost() async {
    // 1) delete post it self
    postsRef.doc(ownerId).collection('userPosts').doc(postId).get().then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // 2) delete image uploaded from the post
    storageRef.child('post_$postId.jpg').delete();
    // 3) delete all actividy feed and notifications
    QuerySnapshot actividyFeedSnapshot = await actividyFeedRef
        .doc(ownerId)
        .collection('feedItems')
        .where('postId', isEqualTo: postId)
        .get();
    actividyFeedSnapshot.docs.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // 4) delete from allusersPosts collection
    QuerySnapshot allusersPostSnapshot =
        await allusersPostsRef.doc('idAllPost1').collection('usersPosts').get();
    allusersPostSnapshot.docs.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // 5) delete all comments
    QuerySnapshot commentSnapshot =
        await commentRef.doc(postId).collection('comments').get();
    commentSnapshot.docs.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  buildPostImage() {
    return GestureDetector(
      onDoubleTap: handleLikePost,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          cachedNetworkImage(mediaUrl, context),
          showHeart
              ? Animator(
                  duration: Duration(milliseconds: 300),
                  tween: Tween(begin: 0.8, end: 0.4),
                  curve: Curves.elasticIn,
                  cycles: 0,
                  builder: (context, animator, transform) {
                    return Transform.scale(
                      scale: animator.value,
                      child:
                          Icon(Icons.favorite, size: 80.0, color: Colors.red),
                    );
                  })
              : Text('')
          // showHeart ? Icon(Icons.favorite,size: 80.0, color: Colors.red) : Text(''),
        ],
      ),
    );
  }

  // this function it's to handle with like
  handleLikePost() {
    bool _isLiked = likes[currentUserId] == true;
    if (_isLiked) {
      postsRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .update({'likes.$currentUserId': false});
      allusersPostsRef
          .doc('usersposts')
          .update({'likes.$currentUserId': false});
      setState(() {
        likesCount -= 1;
        isLiked = false;
        likes[currentUserId] = false;
      });
    } else if (!_isLiked) {
      postsRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .update({'likes.$currentUserId': true});
      allusersPostsRef.doc('usersposts').update({'likes.$currentUserId': true});
      setState(() {
        likesCount += 1;
        isLiked = true;
        likes[currentUserId] = true;
        showHeart = true;
      });
      Timer(Duration(milliseconds: 500), () {
        setState(() {
          showHeart = false;
        });
      });
    }
  }

  buildPostFooter() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              //Padding(padding: EdgeInsets.only(top: 40.0, left: 20.0)),
              GestureDetector(
                onTap: handleLikePost,
                child: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  size: 28.0,
                  color: Colors.pink,
                ),
              ),
              Padding(padding: EdgeInsets.only(right: 40.0)),
              GestureDetector(
                onTap: () => showComments(
                  context,
                  postId: postId,
                  ownerId: ownerId,
                  mediaUrl: mediaUrl,
                ),
                child: Icon(
                  Icons.chat,
                  size: 28.0,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Container(
                //margin: EdgeInsets.only(left: 20.0),
                child: Text(
                  '$likesCount likes',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                // margin: EdgeInsets.only(left: 20.0),
                child: Text(
                  '$username',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(width: 5.0),
              Text(description,
                  style: (TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold))),
            ],
          ),
        ],
      ),
    );
  }

  // this function to notice user when other user comment , this function will avoid own user getting their own comment notification
  addLikeFromActividyFeed() {
    bool isNotPostOwner = currentUserId != ownerId;
    if (isNotPostOwner) {
      actividyFeedRef.doc(ownerId).collection('feedItems').doc(postId).set({
        'type': 'like',
        'username': currentUser.name,
        'userId': currentUser.id,
        'userProfileImg': currentUser.photoUrl,
        'postId': postId,
        'timestamp': timeStamp,
        'mediaUrl': mediaUrl
      });
    }
  }

  removeLikeFromActividyFeed() {
    bool isNotPostOwner = currentUserId != ownerId;
    if (isNotPostOwner) {
      actividyFeedRef
          .doc(ownerId)
          .collection('feedItems')
          .doc(postId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
    }
  }

  // our comments function that will be forward to comment page
  showComments(context, {String postId, String ownerId, String mediaUrl}) {
    return Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Comments(
              postId: postId, postOwnerId: ownerId, postMediaUrl: mediaUrl),
        ));
  }
}
