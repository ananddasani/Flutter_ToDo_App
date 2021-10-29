import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //glbal key will be needed for validation
  GlobalKey<FormState> _key = GlobalKey<FormState>();
  String _task = "";

  FirebaseFirestore db = FirebaseFirestore.instance;

  //onPressed method of FAB
  void _showDialog(bool isUpdate, DocumentSnapshot? ds) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: isUpdate ? Text("Update ToDo") : Text("Add ToDo"),
          content: Form(
            key: _key,
            autovalidateMode: AutovalidateMode.always,
            child: TextFormField(
              autofocus: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Task",
              ),
              validator: (_val) {
                if (_val!.isEmpty)
                  return "Can't be Empty";
                else
                  return null;
              },
              onChanged: (_val) {
                _task = _val;
              },
            ),
          ),
          actions: [
            TextButton(
              child: Text("Add"),

              //------------------------------------------
              //add the task or update the task onPress
              onPressed: () {
                //check for to update or create
                if (isUpdate) {
                  //update the existing value
                  db
                      .collection("tasks")
                      .doc(ds!.id)
                      .update({"task": _task, "time": DateTime.now()});
                } else {
                  //add the data to collection   key :  data  (JSON)
                  db
                      .collection("tasks")
                      .add({"task": _task, "time": DateTime.now()});
                }
                /*
                In db Collection create a collection named "tasks" if not created/started a collection
                and add the data as key pair where key is "task" and data is _task (given/added by the user)
                */
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("FireBase CRUD"),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showDialog(false, null),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: db.collection("tasks").orderBy("time").snapshots(),
        builder: (context, snapShot) {
          //if has data then show
          if (snapShot.hasData) {
            return ListView.builder(
              itemCount: snapShot.data!.docs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot ds = snapShot.data!.docs[index];
                return ListTile(
                  title: Text(ds["task"]),
                  //deleting by longPress
                  onLongPress: () {
                    db.collection("tasks").doc(ds.id).delete();
                  },
                  //updating on tap
                  onTap: () {
                    _showDialog(true, ds);
                  },
                );
              },
            );
          }
          //if no data then loading
          else if (snapShot.hasError)
            return CircularProgressIndicator();
          else
            return CircularProgressIndicator();
        },
      ),
    );
  }
}
