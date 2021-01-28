import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:social_media/widgets/header.dart';

class ToDoPage extends StatefulWidget {
  @override
  _ToDoPageState createState() => _ToDoPageState();
}

class _ToDoPageState extends State<ToDoPage> {
  final _toDoController = TextEditingController();
  List _toDoList = [];
  Map<String, dynamic> _lastRemoved;
  int _lastRemovedPos;

  void addToDo() {
    setState(() {
      Map<String, dynamic> _newToDo = Map();
      _newToDo["title"] = _toDoController.text;
      _newToDo["Ok"] = false;
      _toDoList.add(_newToDo);
      _toDoController.clear();
      _saveData();
    });
  }

  void clearAllToDo() {
    setState(() {
      _toDoController.clear();
      _toDoList.length = 0;
    });
  }

  Future<Null> _refresh() async {
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _toDoList.sort((a, b) {
        if (a["Ok"] && !b["Ok"])
          return 1;
        else if (!a["Ok"] && b["Ok"])
          return -1;
        else
          return 0;
      });
      _saveData();
    });
    return null;
  }

  @override
  void initState() {
    super.initState();
    _readData().then((data) {
      setState(() {
        _toDoList = json.decode(data);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        elevation: 0,
        title: Text(
          'ToDo List',
          style: TextStyle(
              color: Colors.white, fontSize: 25, fontFamily: 'Signatra'),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.clear_all, color: Colors.white),
            onPressed: clearAllToDo,
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(10, 20, 10, 0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(10)),
                    child: TextField(
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                      controller: _toDoController,
                      decoration: InputDecoration(
                        labelText: 'Errands',
                        hintText: 'type your tasks here ...',
                        hintStyle: TextStyle(color: Colors.white, fontSize: 15),
                        labelStyle:
                            TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 5.0,
                ),
                RaisedButton(
                  child: Text(
                    'Add',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    if (_toDoController.text.length <= 0) {
                      showDialog(
                          context: context,
                          builder: (_) {
                            return AlertDialog(
                              backgroundColor: Colors.greenAccent,
                              content: Text(
                                'Please Fill The Blanks To Get Add Your Errands ! Enjoy ',
                                style: TextStyle(color: Colors.white),
                              ),
                            );
                          });
                    } else {
                      addToDo();
                    }
                  },
                  colorBrightness: Brightness.dark,
                  color: Colors.greenAccent,
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(10, 40, 10, 0),
              child: RefreshIndicator(
                color: Colors.white,
                backgroundColor: Colors.greenAccent,
                onRefresh: _refresh,
                child: ListView.builder(
                  itemCount: _toDoList.length,
                  itemBuilder: _buildListTile,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(BuildContext context, index) {
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      direction: DismissDirection.startToEnd,
      background: Container(
        child: Align(
          alignment: Alignment(-0.9, 0.0),
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
        color: Colors.red,
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 10.0),
        decoration: BoxDecoration(
            color: Colors.grey[700],
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(20)),
        child: CheckboxListTile(
          title: Text(
            _toDoList[index]["title"],
            style: TextStyle(color: Colors.white),
          ),
          value: _toDoList[index]["Ok"],
          checkColor: Colors.white,
          onChanged: (value) {
            setState(() {
              _toDoList[index]["Ok"] = value;
              _saveData();
            });
          },
          secondary: CircleAvatar(
            child: Icon(
              _toDoList[index]["Ok"] ? Icons.check : Icons.home_work_outlined,
              color: Colors.white,
            ),
          ),
        ),
      ),
      onDismissed: (direction) {
        setState(() {
          _lastRemoved = Map.from(_toDoList[index]);
          _lastRemovedPos = index;
          _toDoList.removeAt(index);
          _saveData();

          final snack = SnackBar(
            content: Text(
              'Errands \" ${_lastRemoved["title"]} \" Removed',
              style: TextStyle(color: Colors.white),
            ),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                setState(() {
                  _toDoList.insert(_lastRemovedPos, _lastRemoved);
                  _saveData();
                });
              },
            ),
            duration: Duration(seconds: 2),
          );
          Scaffold.of(context).removeCurrentSnackBar();
          Scaffold.of(context).showSnackBar(snack);
        });
      },
    );
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/data.json');
  }

  Future<File> _saveData() async {
    String data = json.encode(_toDoList);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String> _readData() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (value) {
      return null;
    }
  }
}
