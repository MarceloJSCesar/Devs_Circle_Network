import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:social_media/models/user.dart';
import 'package:social_media/pages/activity_feed.dart';
import 'package:social_media/pages/create_account.dart';
import 'package:social_media/pages/news_page.dart';
import 'package:social_media/pages/profile.dart';
import 'package:social_media/pages/search.dart';
import 'package:social_media/pages/timeline.dart';
import 'package:social_media/pages/upload.dart';
import 'package:social_media/widgets/user_login.dart';

// a google sign in variable to can sign with google
final GoogleSignIn googleSignIn = GoogleSignIn();

// creating this user to can provider userData to another pages
User currentUser;

// a storage ref
final Reference storageRef = FirebaseStorage.instance.ref();

// the ref to our collection user in firebase and able to use out of this page
final userRef = FirebaseFirestore.instance.collection('users');
final postsRef = FirebaseFirestore.instance.collection('usersPosts');
final commentRef = FirebaseFirestore.instance.collection('comments');
final actividyFeedRef = FirebaseFirestore.instance.collection('feed');
final followersRef = FirebaseFirestore.instance.collection('followers');
final followingRef = FirebaseFirestore.instance.collection('following');
final timelineRef = FirebaseFirestore.instance.collection('timeline');
final allusersPostsRef = FirebaseFirestore.instance.collection('allusersPosts');
final mensagesRef = FirebaseFirestore.instance.collection('mensages');

// a date time called timeStamp that will be helpful to organize our user data
final Timestamp timeStamp = Timestamp.now();

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // controller to our PageController inside PageView
  PageController pageController;

  // a bool to see if is auth or not
  bool _isAuth = false;

  // setting the index of our page , where gonna start first
  int pageIndex = 0;

  // a function to logout
  void logout() async {
    await googleSignIn.signOut().then((data) {
      print('Logout correctly');
    });
  }

  // a function to logout , without auth yet
  void login() async {
    await googleSignIn
        .signIn()
        .then((data) => print('login with google: sucess'));
  }

  @override
  void initState() {
    super.initState();
    // inizializate our PageController to then can dispose it
    pageController = PageController();
    // detecting data user when user open the app
    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account);
    }).onError((err) {
      print('the current error: $err');
    });
    // reAuthenticator when user open the app
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handleSignIn(account);
    }).catchError((err) {
      print('the current error: $err');
    });
  }

  // return a function to avoid repeating twice
  handleSignIn(GoogleSignInAccount account) async {
    if (account != null) {
      await createUser();
      setState(() {
        _isAuth = true;
      });
    } else {
      setState(() {
        _isAuth = false;
      });
    }
  }

  // my createUser function to create user in firebase
  createUser() async {
    // well, we'll need some steps :

    // 1) check if user exists in our firebase collection (according to their id)
    final GoogleSignInAccount user = googleSignIn.currentUser;
    DocumentSnapshot doc = await userRef.doc(user.id).get();

    // 2) if user doesn't exist and then take them to the create account page
    if (!doc.exists) {
      final username = await Navigator.push(
          context, MaterialPageRoute(builder: (_) => CreateAccount()));

      // 3) get username from create account, and then use it to make new user document in users collection
      userRef.doc(user.id).set({
        'id': user.id,
        'name': username,
        'email': user.email,
        'bio': 'Biografy',
        'photoUrl': user.photoUrl,
        'displayName': user.displayName,
        'timeStamp': timeStamp
      });
      doc = await userRef.doc(user.id).get();
    }
    currentUser = User.fromDocument(doc);
    print(currentUser);
    print(currentUser.name);
  }

  // our onPageChanged function to got use it
  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  // this function is going to be responsable to change the page in our PageView
  onTap(int pageIndex) {
    pageController.animateToPage(pageIndex,
        duration: Duration(milliseconds: 200), curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    // this method it's when we don't need the controller and I'm going to dispose it
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isAuth ? _buildAuthScreen(context) : _buildUnAuthScreen(context);
  }

  Scaffold _buildUnAuthScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Theme.of(context).accentColor,
                Theme.of(context).primaryColor
              ]),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 250,
              ),
              Text(
                'Devs Circle',
                style: TextStyle(
                    color: Colors.white, fontSize: 40, fontFamily: 'Signatra'),
              ),
              Divider(),
              GestureDetector(
                  child: Container(
                    height: 50,
                    width: 200,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(
                            'assets/images/google_signin_button.png',
                          ),
                          fit: BoxFit.cover),
                    ),
                  ),
                  onTap: login),
              SizedBox(
                height: 300,
              ),
              Container(
                alignment: Alignment.center,
                child: Text(
                  'Developed by Marcelo Cesar',
                  style: TextStyle(
                      color: Colors.white, fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // a function that return a widget to return our body
  Scaffold _buildAuthScreen(BuildContext context) {
    return Scaffold(
      body: PageView(
        children: <Widget>[
          // RaisedButton(
          //   onPressed: () {
          //     googleSignIn.signOut();
          //   },
          //   child: Text('logout'),
          // ),
          Timeline(currentUser: currentUser),
          NewsPage(),
          Search(),
          Upload(
            currentUser: currentUser,
          ),
          ActivityFeed(),
          // providing user id to profile page , ?-> it's to check if is no null , will avoid us lots of erros
          Profile(profileId: currentUser?.id),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex,
        onTap: onTap,
        backgroundColor: Colors.black,
        activeColor: Colors.white,
        items: [
          // the bottom naviagation is following the pageIndex as well
          BottomNavigationBarItem(icon: Icon(Icons.home)),
          BottomNavigationBarItem(icon: Icon(Icons.whatshot)),
          BottomNavigationBarItem(icon: Icon(Icons.search)),
          BottomNavigationBarItem(
              icon: Icon(
            Icons.photo_camera,
          )),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_active)),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle)),
        ],
      ),
    );
  }
}
