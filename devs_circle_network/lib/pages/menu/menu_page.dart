import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:social_media/models/user.dart';
import 'package:social_media/pages/home.dart';
import 'package:social_media/pages/menu/pages/markdown_page.dart';
import 'package:social_media/pages/menu/pages/todolist_page.dart';

class MenuPage extends StatefulWidget {
  final UserData currentUser;
  MenuPage({this.currentUser});
  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: ListView(
          children: <Widget>[
            UserAccountsDrawerHeader(
              arrowColor: Colors.yellow,
              currentAccountPicture: ClipOval(
                child: Image(
                    image: CachedNetworkImageProvider(
                        widget.currentUser.photoUrl)),
              ),
              accountName: Text(widget.currentUser.name),
              accountEmail: Text(widget.currentUser.email),
            ),
            SizedBox(height: 30),
            _listTile(text: 'ToDo List', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ToDoPage()))),
            _listTile(text: 'MarkDown Editor', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MarkDownScreen()))),
            _listTile(text: 'Light Theme'),
            _listTile(text: 'Profile Settings '),
            _listTile(text: 'Help'),
            _listTile(text: 'About'),
            SizedBox(
              height: 30,
            ),
            RaisedButton.icon(
              icon: Icon(
                Icons.logout,
                color: Colors.white,
              ),
              label: Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async{
                await googleSignIn.signOut();
                Navigator.pop(context);
              },
              color: Colors.transparent,
            ),
            SizedBox(
              height: 30,
            ),
            Text(
              'Devs Circle',
              style: TextStyle(
                color: Colors.grey[400]
              ),
              textAlign: TextAlign.center,
            ),
             SizedBox(
              height: 4.0,
            ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: 'Version :',
                children: [
                  TextSpan(
                  text: ' 0.1.0',
                  style: TextStyle(
                    color: Colors.grey[400]
                  )
                )
                ]),
            ),
          ],
        ),
      ),
    );
  }

// function to avoid repeat list tile lots lots of time
  ListTile _listTile({String text, Function onTap}) {
    return ListTile(
      title: Text(
        text,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
      ),
      trailing: Icon(
        Icons.keyboard_arrow_right,
        color: Colors.white,
      ),
      onTap: onTap,
    );
  }
}
