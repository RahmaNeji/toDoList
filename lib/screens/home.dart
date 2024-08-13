import 'package:amine_formation/screens/taskDetail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final User? user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    final CollectionReference _tasksCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('tasks');

    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text('Your List Of Tasks',
                style: TextStyle(
                    color: Color(0xff32CBAF), fontWeight: FontWeight.w700))),
      ),
      body: StreamBuilder(
        stream: _tasksCollection.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          final tasks = snapshot.data!.docs;
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(task['task']),
                  subtitle: Text(task['description']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                          value: task['isDone'],
                          onChanged: (bool? value) {
                            _tasksCollection.doc(task.id).update({
                              'isDone': value,
                            });
                          },
                          activeColor: Color(0xff32CBAF)),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _tasksCollection.doc(task.id).delete();
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TaskDetailScreen(task: task),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
