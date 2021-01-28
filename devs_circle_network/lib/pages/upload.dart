import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:social_media/models/user.dart';
import 'package:social_media/pages/home.dart';
import 'package:social_media/widgets/progress.dart';
import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';

class Upload extends StatefulWidget {
  // varible to get user from home page
  final UserData currentUser;

  Upload({this.currentUser});
  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload>
    with AutomaticKeepAliveClientMixin<Upload> {
  // controllers to our textFields
  TextEditingController captionController = TextEditingController();
  TextEditingController locationController = TextEditingController();

  // variable to storage our image form camera
  File file;

  // a bool to check if the photo is uploading or not
  bool isUploading = false;

  // create a unique id to our post by using the Uuid package
  String postId = Uuid().v4();

  // funcion to compress actually to minimize the size of our photo
  compressImage() async {
    final getDir = await getTemporaryDirectory();
    final path = getDir.path;
    Im.Image imImage = Im.decodeImage(file.readAsBytesSync());
    final compressImageFile = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imImage, quality: 85));
    setState(() {
      file = compressImageFile;
    });
  }

  // will return a function to help handleUploadPhoto upload image , as you see will return a string that's why i created a future type of string
  Future<String> uploadImage(imageFile) async {
    UploadTask uploadTask =
        storageRef.child('post_$postId.jpg').putFile(imageFile);
    TaskSnapshot storageSnap = await uploadTask.whenComplete(() {});
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  // funciton to put our post on firebasestore
  createPostInFirestore({String mediaUrl, String caption, String location}) {
    postsRef
        .doc(widget.currentUser.id)
        .collection('userPosts')
        .doc(postId)
        .set({
      'postId': postId,
      'ownerId': widget.currentUser.id,
      'username': widget.currentUser.name,
      'mediaUrl': mediaUrl,
      'location': location,
      'description': caption,
      'timestamp': timeStamp,
      'likes': {}
    });
    allusersPostsRef.doc('idAllPost1').collection('usersPosts').doc('idAllPost2').set({
      'postId': postId,
      'ownerId': widget.currentUser.id,
      'username': widget.currentUser.name,
      'mediaUrl': mediaUrl,
      'location': location,
      'description': caption,
      'timestamp': timeStamp,
      'likes': {}
    });
  }

  // function to handle with uplaod photo
  handleUploadPhoto() async {
    setState(() {
      isUploading = true;
    });
    await compressImage();
    String mediaUrl = await uploadImage(file);

    // i'm going to pick this mediaUrl and put at firestore collection
    createPostInFirestore(
        mediaUrl: mediaUrl,
        caption: captionController.text,
        location: locationController.text);
    captionController.clear();
    locationController.clear();
    setState(() {
      print(file.path);
      file = null;
      isUploading = false;
      postId = Uuid().v4();
    });
  }

  // functions handle to take a photo and to choose from galerry
  handleTakePhoto() async {
    Navigator.pop(context);
    File fileCamera = await ImagePicker.pickImage(
        source: ImageSource.camera, maxHeight: 575, maxWidth: 960);
    setState(() {
      this.file = fileCamera;
    });
  }

  handleChoosePhotoFromGallery() async {
    Navigator.pop(context);
    File fileGallery = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxHeight: 575, maxWidth: 960);
    setState(() {
      this.file = fileGallery;
    });
  }

  // function to select image from camera or gallery
  selectImage(context) {
    return showDialog(
        context: context,
        builder: (_) {
          return SimpleDialog(
            title: Text('Create a post'),
            children: <Widget>[
              SimpleDialogOption(
                child: Text('Image form camera'),
                onPressed: handleTakePhoto,
              ),
              SimpleDialogOption(
                child: Text('Image form gallery'),
                onPressed: handleChoosePhotoFromGallery,
              ),
              SimpleDialogOption(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  // to save our upload user results
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return file == null ? uploadSplashScreen() : buildPostUpload();
  }

// funcion to let image and return to uploadSplashScreen
  clearImage() {
    setState(() {
      file = null;
    });
  }

// a function to return our body of photoUpload
  buildPostUpload() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Upload Image',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.clear,
            color: Colors.black,
          ),
          onPressed: clearImage,
        ),
        actions: [
          FlatButton(
            child: Text(
              'Post',
              style: TextStyle(
                  color: Colors.blue,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            onPressed: isUploading ? null : () => handleUploadPhoto(),
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          isUploading ? linearProgress() : Text(''),
          Container(
            height: 260.0,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.cover, image: FileImage(file))),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage:
                    CachedNetworkImageProvider(widget.currentUser.photoUrl),
              ),
              title: Container(
                padding: EdgeInsets.only(left: 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey[300]),
                width: 250.0,
                child: TextField(
                  controller: captionController,
                  decoration: InputDecoration(
                      hintText: 'write a caption ...',
                      border: InputBorder.none),
                ),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.pin_drop, color: Colors.blue, size: 30.0),
            title: Container(
              padding: EdgeInsets.only(left: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey[300]),
              width: 250.0,
              child: TextField(
                controller: locationController,
                decoration: InputDecoration(
                    hintText: 'Where the photo was taken ?',
                    border: InputBorder.none),
              ),
            ),
          ),
          Container(
            width: 200.0,
            height: 100.0,
            alignment: Alignment.center,
            child: RaisedButton.icon(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              icon: Icon(Icons.my_location),
              onPressed: getUserLocation,
              label: Text(
                'Use my current location',
                style: TextStyle(color: Colors.white),
              ),
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

// function to get current user location and use this location to put inside location input
  getUserLocation() async {
    // final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

    // Position position = await geolocator
    //     .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    // List<Placemark> placemarks = await Geolocator().placemarkFromCoordinates(position.latitude, position.longitude);
    // Placemark placemark = placemarks[0];
    // String formattedAdress = '${placemark.locality}, ${placemark.country}';
    // print(placemarks);
    //locationController.text = formattedAdress;
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placemark = placemarks[0];
    String formattedAdress = '${placemark.locality}, ${placemark.country}';
    print(placemarks);
    locationController.text = formattedAdress;
  }

// building uploadScreen
  Container uploadSplashScreen() {
    return Container(
      color: Colors.black,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset(
            'assets/images/nicubunu_Game_baddie_Sunglasser.svg',
            height: 260.0,
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: EdgeInsets.only(top: 20),
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0.8)),
              child: Text(
                'Post Photo',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                selectImage(context);
              },
              color: Colors.deepPurple,
            ),
          )
        ],
      ),
    );
  }
}
