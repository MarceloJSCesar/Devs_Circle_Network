import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:social_media/pages/slide_page.dart';
import 'package:social_media/pages/home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Social Media Exercise',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        primaryColor: Colors.black,
        accentColor: Colors.teal),
        home: googleSignIn.currentUser != null ? Home() : Home()
    );
  }
}
