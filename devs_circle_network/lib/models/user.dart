import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

// the model user to provide the data that will be saved in users firebase collections
class UserData {
  final String id;
  final String name;
  final String email;
  final String displayName;
  final String photoUrl;
  final String bio;
  final Timestamp timeStamp;

  UserData(
      {this.id,
      this.bio,
      this.name,
      this.email,
      this.photoUrl,
      this.timeStamp,
      this.displayName});

  factory UserData.fromDocument(DocumentSnapshot doc) {
    return UserData(
        id: doc['id'],
        bio: doc['bio'],
        name: doc['name'],
        email: doc['email'],
        photoUrl: doc['photoUrl'],
        timeStamp: doc['timeStamp'],
        displayName: doc['displayName']);
  }
}

