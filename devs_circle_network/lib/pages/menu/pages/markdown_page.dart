import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MarkDownScreen extends StatefulWidget {
  @override
  _MarkDownScreenState createState() => _MarkDownScreenState();
}

class _MarkDownScreenState extends State<MarkDownScreen>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  TextEditingController _editingController;

  // variable where be saved our markdown text
  String text = '';

  @override
  void initState() {
    super.initState();
    // will an object that manage our tabbar and tabView if were our case
    _tabController = TabController(length: 2, vsync: this);
    _editingController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text(
          'MarkDown Editor',
          style: TextStyle(
              color: Colors.white, fontSize: 25, fontFamily: 'Signatra'),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: Text('Editing'),
            ),
            Tab(
              icon: Text('Preview'),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.black,
      body: TabBarView(
        controller: _tabController,
        children: [
          Container(
            margin: EdgeInsets.all(10),
            child: TextField(
              keyboardType: TextInputType.multiline,
              maxLines: null,
              controller: _editingController,
              style: TextStyle(
                color: Colors.white
              ),
              decoration: InputDecoration(
                  hintText: 'Input Text',
                  hintStyle: TextStyle(color: Colors.white),
                  border: InputBorder.none),
              onChanged: (text) {
                setState(() {
                  this.text = text;
                });
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(20),
            color: Colors.grey[700],
            child: MarkdownBody(
              data: text, 
              styleSheetTheme: MarkdownStyleSheetBaseTheme.material),
          ),
        ],
      ),
    );
  }
}
