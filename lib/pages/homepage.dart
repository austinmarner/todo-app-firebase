import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

final databaseReference = Firestore.instance;
QuerySnapshot todoList;

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  TextEditingController _textController = TextEditingController();

  int length = 0;

  void getlength() async {
    var temp;
    temp = await databaseReference.collection('todo').getDocuments();
    setState(() {
      todoList = temp;
      length = todoList.documents.length;
    });
  }

  Widget cardListBuilder() {
    getlength();
    return Expanded(
      child: ListView.builder(
        // reverse: true,
        itemCount: length,
        itemBuilder: (BuildContext context, int position) {
          return Card(
            color: Colors.blue,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Checkbox(
                  value: todoList.documents[position]['isDone'],
                  checkColor: Colors.black,
                  activeColor: Colors.white,
                  onChanged: (bool newValue) async {
                    var temp;
                    try {
                      databaseReference
                          .collection('todo')
                          .document(todoList.documents[position].documentID)
                          .updateData({'isDone': newValue});
                      temp = await databaseReference
                          .collection('todo')
                          .getDocuments();
                    } catch (e) {
                      print(e.toString());
                    }
                    setState(() {
                      todoList = temp;
                    });
                  },
                ),
                Text(
                  todoList.documents[position]['title'],
                  style: TextStyle(color: Colors.white),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  color: Colors.white,
                  onPressed: () async {
                    var temp;
                    try {
                      databaseReference
                          .collection('todo')
                          .document(todoList.documents[position].documentID)
                          .delete();
                      temp = await databaseReference
                          .collection('todo')
                          .getDocuments();
                    } catch (e) {
                      print(e.toString());
                    }
                    setState(() {
                      todoList = temp;
                    });
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo App'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () async {
              var temp =
                  await databaseReference.collection('todo').getDocuments();
              setState(() {
                todoList = temp;
              });
            },
          )
        ],
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.only(top: 30.0, left: 30.0, right: 30.0),
        child: Column(
          children: <Widget>[
            TextField(
              style:
                  TextStyle(color: Theme.of(context).textTheme.bodyText2.color),
              controller: _textController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter the Todo',
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
              child: RaisedButton(
                color: Colors.blue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                    Text(
                      'Add',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                onPressed: () async {
                  DocumentReference ref =
                      await databaseReference.collection('todo').add({
                    'title': '${_textController.text}',
                    'isDone': false,
                  });
                  var temp =
                      await databaseReference.collection('todo').getDocuments();
                  setState(() {
                    todoList = temp;
                  });
                  print(ref.documentID);
                },
              ),
            ),
            cardListBuilder(),
          ],
        ),
      ),
    );
  }
}
