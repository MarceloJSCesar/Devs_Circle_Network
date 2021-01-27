import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:social_media/widgets/chat/messages.dart';
import 'package:social_media/widgets/chat/new_message.dart';

import 'home.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();
    final fm = FirebaseMessaging.instance;
    fm.requestPermission().then((fmData) {
      print('fmAlert: ${fmData.alert}');
      print('fmlockScreen: ${fmData.lockScreen}');
      print('fmNotificationCenter: ${fmData.notificationCenter}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text(
          'FlutterChat',
          style: TextStyle(color: Colors.white, fontSize: 17),
        ),
        actions: <Widget>[
          DropdownButton(
            underline: Container(),
            icon: Icon(
              Icons.more_vert,
              color: Colors.white,
            ),
            items: [
              DropdownMenuItem(
                child: Container(
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.exit_to_app,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text('Background'),
                    ],
                  ),
                ),
                value: 'Background',
              ),
            ],
            onTap: (){

            },
          )]
      ),
      backgroundColor: Colors.black,
      body: Container(
          child: Column(
        children: [
          Expanded(child: Messages()),
          NewMessage(),
        ],
      )),
    );
  }
}
