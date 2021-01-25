import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:social_media/pages/home.dart';

final FirebaseAuth userAuth = FirebaseAuth.instance;

class UserLogin extends StatefulWidget {
  @override
  _UserLoginState createState() => _UserLoginState();
}

class _UserLoginState extends State<UserLogin> {
  @override
  Widget build(BuildContext context) {
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

  // a function to sign in with google
  void login() async {
    try {
      final GoogleSignInAccount googleSignInAccount =
          await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);

      final User authResult =
          (await userAuth.signInWithCredential(credential)).user;
      print('Auth result : $authResult');
      // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) {
      //   return null;
      // }));
    } // if user can't sign in , i'm going to notify you and will print the error to me
    catch (error) {
      print('Current error : $error');
    }
  }
}
