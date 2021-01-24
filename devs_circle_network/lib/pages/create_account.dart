import 'dart:async';

import 'package:flutter/material.dart';
import 'package:social_media/widgets/header.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  // a global key to our form widget and to get use validator
  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  // a string name where will be saved the username
  String username;

  // a scaffold key to can show things when finish to execute some actions
  final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();

  // a function that will save the username and provide homepage to use it to create a new user document in users collection
  submit() {
    final form = _key.currentState;
    // this function will save the tha data if form is validated
    if (form.validate()) {
      form.save();
      SnackBar snackBar = SnackBar(
        content: Text('Well done $username'),
      );
      _scaffoldkey.currentState.showSnackBar(snackBar);
      Timer(Duration(seconds: 2), () {
        Navigator.pop(context, username);
      });
    }
  }

  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
      key: _scaffoldkey,
      appBar: header(context,isHomeTitle: false, removeLeading: true ,titleText: 'Set up your profile', background: Colors.white),
      backgroundColor: Colors.white,
      body: Container(
        margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Create a username',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 40,
                ),
                Container(
                  child: Form(
                    key: _key,
                    autovalidateMode: AutovalidateMode.always,
                    child: TextFormField(
                      validator: (val) {
                        if (val.trim().length < 3) {
                          return 'Username too short';
                        } else if (val.trim().length > 12) {
                          return 'Username too long';
                        } else {
                          return null;
                        }
                      },
                      onSaved: (data) => username = data,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Nickname',
                          labelStyle:
                              TextStyle(color: Colors.black, fontSize: 18),
                          hintText: 'Must be at least 3 charecteres'),
                    ),
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                GestureDetector(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    width: 120,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[300]),
                    child: Center(
                      child: Text(
                        'Save',
                        style: TextStyle(color: Colors.black, fontSize: 17),
                      ),
                    ),
                  ),
                  onTap: submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
