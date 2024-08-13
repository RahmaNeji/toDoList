import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskDetailScreen extends StatelessWidget {
  final DocumentSnapshot task;

  TaskDetailScreen({required this.task});

  final TextEditingController _subTaskController = TextEditingController();
  final TextEditingController _subTaskDescriptionController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        body: Center(child: Text('User not logged in')),
      );
    }

    final CollectionReference _subTasksCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('tasks')
        .doc(task.id)
        .collection('subtasks');

    return Scaffold(
      appBar: AppBar(
        title: Text(task['task']),
        backgroundColor: Color(0xff32CBAF),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                Text(
                  task['description'],
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                FormContainerWidget(
                  controller: _subTaskController,
                  hintText: "New Sub-Task",
                  isPasswordField: false,
                ),
                const SizedBox(height: 20),
                FormContainerWidget(
                  controller: _subTaskDescriptionController,
                  hintText: "Sub-Task Description",
                  isPasswordField: false,
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    if (_subTaskController.text.isNotEmpty &&
                        _subTaskDescriptionController.text.isNotEmpty) {
                      _subTasksCollection.add({
                        'subtask': _subTaskController.text,
                        'description': _subTaskDescriptionController.text,
                        'isDone': false,
                      });
                      _subTaskController.clear();
                      _subTaskDescriptionController.clear();
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      color: Color(0xff32CBAF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        "Add Sub-Task",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  height: MediaQuery.of(context).size.height * .5,
                  child: StreamBuilder(
                    stream: _subTasksCollection.snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return Text('Something went wrong');
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }
                      final subtasks = snapshot.data!.docs;
                      return ListView.builder(
                        itemCount: subtasks.length,
                        itemBuilder: (context, index) {
                          final subtask = subtasks[index];
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: Text(subtask['subtask']),
                              subtitle: Text(subtask['description']),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Checkbox(
                                      value: subtask['isDone'],
                                      onChanged: (bool? value) {
                                        _subTasksCollection
                                            .doc(subtask.id)
                                            .update({
                                          'isDone': value,
                                        });
                                      },
                                      activeColor: Color(0xff32CBAF)),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      _subTasksCollection
                                          .doc(subtask.id)
                                          .delete();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FormContainerWidget extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool isPasswordField;

  FormContainerWidget({
    required this.controller,
    required this.hintText,
    required this.isPasswordField,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hintText,
          ),
          obscureText: isPasswordField,
        ),
      ),
    );
  }
}
