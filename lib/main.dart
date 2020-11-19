import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  runApp(MaterialApp(
    title: "Todos Demo",
    debugShowCheckedModeBanner: false,
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _initializedFirebase = false;

  String _todoItem = "";

  void initializeFirebase() async {
    await Firebase.initializeApp();
    setState(() {
      _initializedFirebase = true;
    });
  }

  @override
  void initState() {
    initializeFirebase();
    super.initState();
  }

  void _addTodo() {
    FirebaseFirestore.instance
        .collection('todos')
        .add({"todo": _todoItem})
        .then((value) => print("Added $value"))
        .catchError((error) => print(error));
  }

  void _deleteTodos(String id) {
    FirebaseFirestore.instance
        .collection('todos')
        .doc(id)
        .delete()
        .then((value) => print("Delete Success $id"))
        .catchError((error) => print(error));
  }

  @override
  Widget build(BuildContext context) {
    return (!_initializedFirebase)
        ? Scaffold(
            body: Center(
              child: Text(
                "Please wait, we are setting up things for you!",
                style: TextStyle(fontSize: 25),
              ),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              title: Text("Todos"),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        title: Text("Add Todo"),
                        content: TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Todo",
                          ),
                          onChanged: (String value) {
                            _todoItem = value;
                          },
                        ),
                        actions: <Widget>[
                          FlatButton(
                            onPressed: () {
                              _addTodo();
                              Navigator.of(context).pop();
                            },
                            child: Text("Add"),
                          )
                        ],
                      );
                    });
              },
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
            body: StreamBuilder(
                stream:
                    FirebaseFirestore.instance.collection("todos").snapshots(),
                builder: (context, snapshots) {
                  if (snapshots.hasData) {
                    return (snapshots.data.documents.length == 0)
                        ? Center(
                            child: Text("There is nothing ToDo, Sit back and Relex 😎", style: TextStyle(fontSize: 18),),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: snapshots.data.documents.length,
                            itemBuilder: (context, index) {
                              DocumentSnapshot documentSnapshot =
                                  snapshots.data.documents[index];
                              return Dismissible(
                                background: Container(
                                  padding: EdgeInsets.all(8),
                                  alignment: AlignmentDirectional.centerStart,
                                  color: Colors.red,
                                  child: Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                                onDismissed: (direction) {
                                  _deleteTodos(documentSnapshot.id);
                                },
                                key: Key(documentSnapshot.id),
                                child: Card(
                                  elevation: 4,
                                  margin: EdgeInsets.all(8),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  child: ListTile(
                                    title:
                                        Text(documentSnapshot.data()["todo"]),
                                  ),
                                ),
                              );
                            });
                  } else {
                    return Align(
                      alignment: FractionalOffset.bottomCenter,
                      child: CircularProgressIndicator(),
                    );
                  }
                }),
          );
  }
}
