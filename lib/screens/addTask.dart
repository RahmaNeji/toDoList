import 'package:amine_formation/screens/taskDetail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Categories extends StatefulWidget {
  const Categories({Key? key}) : super(key: key);

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
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
            child: Text(
          'Add New Task To Your List',
          style:
              TextStyle(color: Color(0xff32CBAF), fontWeight: FontWeight.w700),
        )),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                FormContainerWidget(
                  controller: _taskController,
                  hintText: "New Task",
                  isPasswordField: false,
                ),
                const SizedBox(height: 20),
                FormContainerWidget(
                  controller: _descriptionController,
                  hintText: "Description",
                  isPasswordField: false,
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    if (_taskController.text.isNotEmpty &&
                        _descriptionController.text.isNotEmpty) {
                      _tasksCollection.add({
                        'task': _taskController.text,
                        'description': _descriptionController.text,
                        'isDone': false,
                      });
                      _taskController.clear();
                      _descriptionController.clear();
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
                        "Add Task",
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
                                    builder: (context) =>
                                        TaskDetailScreen(task: task),
                                  ),
                                );
                              },
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
