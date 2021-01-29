import 'package:flutter/material.dart';
import 'package:social_media/pages/home.dart';

final user = googleSignIn.currentUser;

class NewMessage extends StatefulWidget {
  @override
  _NewMessageState createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  var _enteredMessage = '';
  final _controller = TextEditingController();

  void _sendMessage() async {
    mensagesRef.doc(user.id).collection('chat').add({
      'text': _enteredMessage,
      'createdAt': timeStamp,
      'userId': currentUser.id,
      'username': currentUser.name,
      'userImg': currentUser.photoUrl
    });
    setState(() {
      _controller.text = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8),
      padding: EdgeInsets.all(3),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _controller,
              autocorrect: true,
              textCapitalization: TextCapitalization.sentences,
              enableSuggestions: true,
              decoration: InputDecoration(
                  hintText: 'send a message ...',
                  hintStyle: TextStyle(color: Colors.white),
                  ),
              onChanged: (value) {
                setState(() {
                  _enteredMessage = value;
                });
              },
              style: TextStyle(color: Colors.white),
            ),
          ),
          IconButton(
            color: _controller.text.length <= 0 ? Colors.blue : Colors.grey,
            icon: Icon(Icons.send,
                color:
                    _controller.text.length <= 0 ? Colors.grey : Colors.blue),
            onPressed: _controller.text.length > 0 ? _sendMessage : null,
          ),
        ],
      ),
    );
  }
}
