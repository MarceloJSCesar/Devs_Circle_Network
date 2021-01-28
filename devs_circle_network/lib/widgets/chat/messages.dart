import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media/pages/home.dart';

import 'message_bubble.dart';
import 'new_message.dart';

class Messages extends StatefulWidget {
  @override
  _MessagesState createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: userResponde(),
      builder: (ctx, futureSnapshot) {
        if (futureSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        return StreamBuilder(
            stream: mensagesRef.doc(user.id)
                .collection('chat')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (ctx, chatSnapshot) {
              if (chatSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (chatSnapshot.hasError) {
                return Center(
                  child: Text('error founded',style: TextStyle(
                    color: Colors.white,
                    fontSize: 18
                  ),),
                );
              }
              final chatDocs = chatSnapshot.data.docs;
              return ListView.builder(
                reverse: true,
                itemCount: chatDocs.length,
                itemBuilder: (ctx, index) {
                  return MessageBubble(
                    chatDocs[index]['text'],
                    chatDocs[index]['userId'] == user.id,
                    chatDocs[index]['username'],
                    chatDocs[index]['userImg'],
                    key: ValueKey(chatDocs[index].id),
                  );
                },
              );
            });
      },
    );
  }

  Future userResponde() async {
    return FirebaseAuth.instance.currentUser;
  }
}
