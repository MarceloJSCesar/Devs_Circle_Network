import 'package:flutter/material.dart';
import 'package:social_media/widgets/header.dart';
import 'package:social_media/widgets/progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// the ref to our collection user in firebase
final userRef = FirebaseFirestore.instance.collection('users');

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(context) {
    return Scaffold(
      // this header function it's a side part i created , inside widgets folder
      appBar: header(context,isHomeTitle: true, background: Colors.white, removeLeading: true),
      body: StreamBuilder(
        stream: userRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          final doc = snapshot.data.docs;
          return ListView.builder(
            itemCount: doc.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(doc[index]['userName'] ?? 'no user yet'),
              );
            },
          );
        },
      ),
    );
  }
}
