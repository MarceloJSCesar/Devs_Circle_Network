import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:social_media/models/user.dart';
import 'package:social_media/pages/edit_profile.dart';
import 'package:social_media/pages/home.dart';
import 'package:social_media/widgets/post.dart';
import 'package:social_media/widgets/post_tile.dart';
import 'package:social_media/widgets/progress.dart';

class Profile extends StatefulWidget {
  // requesting a user id and asking if want to able navigator pop or not because if other user want to see your profile , problably they want to leave there
  final String profileId;
  Profile({this.profileId});
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  // a bool to know if user isfollowing another user or not
  bool isFollowing = false;

  // a variable to handle with currentUser data
  final String currentUserId = currentUser?.id;

  // a string to make a bool if is grid or a list
  String _posOrientation = 'grid';

  bool isLoading = false;

  // number of userPost
  int postCount = 0;

  // variables to saved numbers of followers and following
  int followersCount = 0;
  int followingCount = 0;

  // list where all the photos will be saved
  List<Post> posts = [];

  bool forwardToProfilePage = false;

  getProfilePosts() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await postsRef
        .doc(widget.profileId)
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

  @override
  void initState() {
    super.initState();
    getProfilePosts();
    getFollowers();
    getFollowing();
    checkIfFollowing();
  }

  // checking if is following
  checkIfFollowing() async {
    DocumentSnapshot doc = await followersRef
        .doc(widget.profileId)
        .collection('followers')
        .doc(currentUserId)
        .get();
    // checking if is following by seeing with that user exists or not
    setState(() {
      isFollowing = doc.exists;
    });
  }

  getFollowers() async {
    QuerySnapshot snapshot =
        await followersRef.doc(widget.profileId).collection('followers').get();
    setState(() {
      followersCount = snapshot.docs.length;
    });
  }

  getFollowing() async {
    QuerySnapshot snapshot =
        await followingRef.doc(widget.profileId).collection('following').get();
    setState(() {
      followingCount = snapshot.docs.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
            future: userRef.doc(widget.profileId).get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return circularProgress();
              }
              User user = User.fromDocument(snapshot.data);
              return SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(10,0,10,0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(top: 60),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            ClipOval(
                                child: Image(
                                  image: CachedNetworkImageProvider(user.photoUrl),
                                ),
                              ),
                            buildCountColumn('Posts', postCount),
                            buildCountColumn('Followers', followersCount),
                            buildCountColumn('Following', followingCount),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                      user.name,
                      style: TextStyle(fontSize: 16, ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                      user.email,
                      style: TextStyle(fontSize: 16, ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                      user.bio,
                      style: TextStyle(fontSize: 16,),
                      ),
                      buildProfileButton(),
                      SizedBox(
                        height: 20,
                      ),
                      Divider(),
                      buildTogglePostOrientation(),
                      Divider(),
                      buildProfilePosts()
                    ],
                  ),
                ),
              );
            }));
  }

  buildTogglePostOrientation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          icon: Icon(
            Icons.grid_on,
          ),
          color: _posOrientation == 'grid'
              ? Theme.of(context).primaryColor
              : Colors.grey,
          onPressed: () => setPostOrientation('grid'),
        ),
        IconButton(
          icon: Icon(
            Icons.list,
          ),
          color: _posOrientation == 'list'
              ? Theme.of(context).primaryColor
              : Colors.grey,
          onPressed: () => setPostOrientation('list'),
        ),
      ],
    );
  }

  buildProfilePosts() {
    if (isLoading) {
      return circularProgress();
    } else if (_posOrientation == 'grid' && posts.isNotEmpty) {
      List<GridTile> gridTiles = [];
      posts.forEach((post) {
        gridTiles.add(GridTile(child: PostTile(post)));
      });
      return GridView.count(
        crossAxisCount: 3,
        crossAxisSpacing: 0.5,
        mainAxisSpacing: 0.5,
        childAspectRatio: 1.0,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridTiles,
      );
    } else if (_posOrientation == 'list' && posts.isNotEmpty) {
      return Column(
        children: posts,
      );
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
    }
  }

  // a little function to set/ change the orientation value
  setPostOrientation(String posOrientation) {
    setState(() {
      this._posOrientation = posOrientation;
    });
  }

  // function that will return my profileHeader
  buildProfileHeader() {
    return FutureBuilder(
        future: userRef.doc(widget.profileId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          // User user = User.fromDocument(snapshot.data);
          return null;
        });
  }

  Column buildCountColumn(String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(
              color: Colors.black, fontSize: 22.0, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 5
        ),
        Text(
          label,
          style: TextStyle(
              color: Colors.grey[350], fontSize: 15.0, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  buildProfileButton() {
    // viewing your profile -> should see button edit profile , checking if is your profile or not
    bool isMyProfile = currentUserId == widget.profileId;
    if (isMyProfile) {
      return buildButton(text: 'Edit Profile', function: editProfile);
    } else if (!isMyProfile) {
      if (isFollowing) {
        return buildButton(text: 'Unfollow', function: handleUnfollowUser);
      } else if (!isFollowing) {
        return buildButton(text: 'Follow', function: handleFollowUser);
      }
    }
  }

  handleUnfollowUser() {
    setState(() {
      isFollowing = false;
    });
    // remove follower
    followersRef
        .doc(widget.profileId)
        .collection('followers')
        .doc(currentUserId)
        .get()
        .then((doc) {
      // deleting data only if exists
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // remove following
    followingRef
        .doc(currentUserId)
        .collection('following')
        .doc(widget.profileId)
        .get()
        .then((doc) {
      // deleting data only if exists
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // delete actividy fee dfor them
    actividyFeedRef
        .doc(widget.profileId)
        .collection('feedItems')
        .doc(currentUserId)
        .get()
        .then((doc) {
      // deleting data only if exists
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  handleFollowUser() {
    setState(() {
      isFollowing = true;
    });
    // make auth user follower of that user and update their followers colletions
    followersRef
        .doc(widget.profileId)
        .collection('followers')
        .doc(currentUserId)
        .set({});
    // put that user on your following collection (at same time updating when foollowing)
    followingRef
        .doc(currentUserId)
        .collection('following')
        .doc(widget.profileId)
        .set({});
    // add activity feed on that user to notify about new follower
    actividyFeedRef
        .doc(widget.profileId)
        .collection('feedItems')
        .doc(currentUserId)
        .set({
      'type': 'follow',
      'ownerId': widget.profileId,
      'username': currentUser.name,
      'userId': currentUserId,
      'userProfileImg': currentUser.photoUrl,
      'timestamp': timeStamp
    });
  }

  editProfile() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => EditProfile(currentUserId: currentUserId)));
  }

  Container buildButton({String text, Function function}) {
    return Container(
      padding: EdgeInsets.only(top: 2.0),
      child: FlatButton(
        onPressed: function,
        child: Container(
          alignment: Alignment.center,
          width: 250.0,
          height: 28.0,
          child: Text(
            text,
            style: TextStyle(
                fontSize: 16,
                color: isFollowing ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold),
          ),
          decoration: BoxDecoration(
              color: isFollowing ? Colors.grey[300] : Colors.blue,
              border:
                  Border.all(color: isFollowing ? Colors.black : Colors.blue),
              borderRadius: BorderRadius.circular(5.0)),
        ),
      ),
    );
  }
}

// Padding(
//             padding: EdgeInsets.all(16.0),
//             child: Column(
//               children: <Widget>[
//                 Row(
//                   children: <Widget>[
//                     CircleAvatar(
//                       radius: 40.0,
//                       backgroundColor: Colors.grey,
//                       backgroundImage:
//                           CachedNetworkImageProvider(user.photoUrl),
//                     ),
//                     Expanded(
//                       flex: 1,
//                       child: Column(
//                         children: <Widget>[
//                           Row(
//                             mainAxisSize: MainAxisSize.max,
//                             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                             children: <Widget>[
//                               buildCountColumn('Posts', postCount),
//                               buildCountColumn('Followers', followersCount),
//                               buildCountColumn('Following', followingCount),
//                             ],
//                           ),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                             children: <Widget>[
//                               buildProfileButton()
//                               //buildButton(),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 Container(
//                   alignment: Alignment.centerLeft,
//                   padding: EdgeInsets.only(top: 12.0),
//                   child: Text(
//                     user.name,
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//                 ),
//                 Container(
//                   alignment: Alignment.centerLeft,
//                   padding: EdgeInsets.only(top: 4.0),
//                   child: Text(
//                     user.displayName,
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                 ),
//                 Container(
//                   alignment: Alignment.centerLeft,
//                   padding: EdgeInsets.only(top: 10.0),
//                   child: Text(
//                     user.bio,
//                     style: TextStyle(color: Colors.grey[700]),
//                   ),
//                 ),
//               ],
//             ),
//           );

// ListView(
//             children: <Widget>[
//               buildProfileHeader(),
//               Divider(),
//               buildTogglePostOrientation(),
//               Divider(
//                 height: 0.0,
//               ),
//               buildProfilePosts(),
//             ],
//           ),
