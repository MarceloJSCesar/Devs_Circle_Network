import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:social_media/pages/edit_profile.dart';
import 'package:social_media/pages/home.dart';
import 'package:social_media/widgets/post.dart';
import 'package:social_media/widgets/post_tile.dart';
import 'package:social_media/widgets/progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media/models/user.dart';
import 'package:social_media/widgets/header.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Profile extends StatefulWidget {
  // requesting a user id
  final String profileId;
  Profile({this.profileId});
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  // a variable to handle with currentUser data
  final String currentUserId = currentUser?.id;

  // a string to make a bool if is grid or a list
  String _posOrientation = 'grid';

  bool isLoading = false;
  // number of userPost
  int postCount = 0;
  // list where all the photos will be saved
  List<Post> posts = [];

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // this header function it's a side part i created , inside widgets folder
        appBar: header(
          context,
            isHomeTitle: false,
            removeLeading: true,
            titleText: 'Profile',
            background: Colors.white),
        body: ListView(
          children: <Widget>[
            buildProfileHeader(),
            Divider(),
            buildTogglePostOrientation(),
            Divider(
              height: 0.0,
            ),
            buildProfilePosts(),
          ],
        ));
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
        crossAxisSpacing: 1.5,
        mainAxisSpacing: 1.5,
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
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,fontSize: 20)
            ),
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
          User user = User.fromDocument(snapshot.data);
          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 40.0,
                      backgroundColor: Colors.grey,
                      backgroundImage:
                          CachedNetworkImageProvider(user.photoUrl),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              buildCountColumn('Posts', postCount),
                              buildCountColumn('Followers', 0),
                              buildCountColumn('Following', 0),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              buildButton(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 12.0),
                  child: Text(
                    user.name,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 4.0),
                  child: Text(
                    user.displayName,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 10.0),
                  child: Text(
                    user.bio,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
          );
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
        Text(
          label,
          style: TextStyle(
              color: Colors.grey, fontSize: 15.0, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  buildProfileButton() {
    // viewing your profile -> should see button edit profile , checking if is your profile or not
    bool isMyProfile = currentUserId == widget.profileId;
    if (isMyProfile) {
      return editProfile();
    }
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
        onPressed: buildProfileButton,
        child: Container(
          alignment: Alignment.center,
          width: 240.0,
          height: 28.0,
          child: Text(
            'Edit Profile',
            style: TextStyle(
                fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
          ),
          decoration: BoxDecoration(
              color: Colors.grey[300],
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(5.0)),
        ),
      ),
    );
  }
}
