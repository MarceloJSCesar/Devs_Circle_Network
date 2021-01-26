import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:social_media/models/user.dart';
import 'package:social_media/pages/home.dart';
import 'package:social_media/widgets/progress.dart';

class EditProfile extends StatefulWidget {
  final String currentUserId;
  EditProfile({this.currentUserId});
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  // bool to check if is loading and a currentuser from User modal
  bool isLoading = false;
  User user;

  // controllers to our two textField
  TextEditingController nameController = TextEditingController();
  TextEditingController bioController = TextEditingController();

  // adding some validation
  bool nameVal = true;
  bool bioVal = true;

  // scaffold key to show user when get update their profile
  final _scaffoldkey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    getUser();
  }

  // a function to get userData
  getUser() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await userRef.doc(widget.currentUserId).get();
    user = User.fromDocument(doc);
    nameController.text = user.name;
    bioController.text = user.bio;
    setState(() {
      isLoading = false;
    });
  }

  // function to validate our two inputs
  updateProfileData() {
    setState(() {
      nameController.text.trim().length < 3 ||
              nameController.text.trim().isEmpty
          ? nameVal = false
          : nameVal = true;
      bioController.text.trim().length > 100 ||
              bioController.text.trim().isEmpty
          ? bioVal = false
          : bioVal = true;
    });
    if (nameVal && bioVal) {
      userRef
          .doc(widget.currentUserId)
          .update({'name': nameController.text, 'bio': bioController.text});
    }
    SnackBar snackBar = SnackBar(content: Text('Profile Updated'));
    _scaffoldkey.currentState.showSnackBar(snackBar);
  }

  // a function to logout and forward user to homePage
  logout() async {
    await googleSignIn.signOut();
    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (_) => Home()
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldkey,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white, fontSize: 17),
        ),
        actions: [
          IconButton(
              icon: Icon(
                Icons.done,
                size: 30.0,
                color: Colors.greenAccent,
              ),
              onPressed: () => Navigator.pop(context)),
        ],
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor:  Colors.black,
      body: isLoading
          ? circularProgress()
          : ListView(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
                      child: CircleAvatar(
                        radius: 50.0,
                        backgroundImage:
                            CachedNetworkImageProvider(user.photoUrl),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: <Widget>[
                          buildProfileDisplayName(),
                          buildProfileBio()
                        ],
                      ),
                    ),
                    RaisedButton(
                      child: Text('Update Profile'),
                      onPressed: updateProfileData,
                      color: Colors.grey[300],
                    ),
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: FlatButton.icon(
                        icon: Icon(
                          Icons.logout,
                          color: Colors.red,
                        ),
                        label: Text(
                          'Logout',
                          style: TextStyle(color: Colors.red),
                        ),
                        onPressed: logout,
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Column buildProfileDisplayName() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text(
            'Nick  Name',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          maxLength: 20,
          controller: nameController,
           style: TextStyle(
            color: Colors.white,
          ),
          decoration: InputDecoration(
              hintText: 'Update Display Name',
              hintStyle: TextStyle(
                color:  Colors.white,
              ),
              errorText: nameVal ? null : 'Invalid name'),
        ),
      ],
    );
  }

  Column buildProfileBio() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text(
            'Bio',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          maxLength: 100,
          style: TextStyle(
            color: Colors.white,
          ),
          controller: bioController,
          decoration: InputDecoration(
              hintText: 'Update Bio', 
              hintStyle: TextStyle(
                color:  Colors.white,
              ),
              errorText: bioVal ? null : 'Invalid bio'),
        ),
      ],
    );
  }
}
