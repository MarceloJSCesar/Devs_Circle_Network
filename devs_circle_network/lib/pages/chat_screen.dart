import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:social_media/widgets/chat/messages.dart';
import 'package:social_media/widgets/chat/new_message.dart';


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
          'Devs Chat',
          style: TextStyle(color: Colors.white, fontSize: 25, fontFamily: 'Signatra'),
        ),),
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
