import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'TaskDetailScreen.dart';

class TaskScreen extends StatefulWidget {
  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late String uid;
  bool isLoading = true;
  List<Map<String, dynamic>> tasks = [];
  Map<String, dynamic>? lastClickedTask; // To store the last clicked task
  String? lastClickedTimestamp; // To store the timestamp when the button is clicked

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  // Fetch tasks based on UID
  Future<void> fetchTasks() async {
    User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        uid = user.uid;
      });

      try {
        QuerySnapshot snapshot = await _firestore
            .collection('users')
            .doc(uid)
            .collection('tasks')
            .get();

        List<Map<String, dynamic>> fetchedTasks = snapshot.docs.map((doc) {
          return {
            'id': doc.id, // Get the document ID for delete and update operations
            'category': doc['category'],
            'createdAt': doc['createdAt'],
            'endDate': doc['endDate'],
            'endTime': doc['endTime'],
            'frequency': doc['frequency'],
            'startDate': doc['startDate'],
            'startTime': doc['startTime'],
            'title': doc['title'],
          };
        }).toList();

        setState(() {
          tasks = fetchedTasks;
          isLoading = false;
        });
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        print('Error fetching tasks: $e');
      }
    }
  }

  // Function to record task click in Firebase
  Future<void> recordTaskClick(Map<String, dynamic> task) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        // Create a new record in the taskLogs collection
        await _firestore.collection('users')
            .doc(user.uid)
            .collection('taskLogs')
            .add({
          'taskName': task['title'],
          'clickedAt': FieldValue.serverTimestamp(),  // Record the current timestamp
          'category': task['category'],
          'startTime': task['startTime'],
        });
        print('Task click recorded!');
      } catch (e) {
        print('Error recording task click: $e');
      }
    }
  }

  // Function to delete a task
  Future<void> deleteTask(String taskId) async {
    try {
      await _firestore.collection('users')
          .doc(uid)
          .collection('tasks')
          .doc(taskId)
          .delete();
      print('Task deleted successfully!');
      setState(() {
        tasks.removeWhere((task) => task['id'] == taskId);
      });
    } catch (e) {
      print('Error deleting task: $e');
    }
  }

  // Function to update a task
  Future<void> updateTask(String taskId, Map<String, dynamic> updatedData) async {
    try {
      await _firestore.collection('users')
          .doc(uid)
          .collection('tasks')
          .doc(taskId)
          .update(updatedData);
      print('Task updated successfully!');
      fetchTasks(); // Re-fetch tasks after updating
    } catch (e) {
      print('Error updating task: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Your Tasks")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: tasks.isEmpty
                ? Center(child: Text('No tasks available.'))
                : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(tasks[index]['title']),
                  subtitle: Text("Category: ${tasks[index]['category']}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Task Click button (leading icon button)
                      IconButton(
                        icon: Icon(Icons.check),
                        onPressed: () {
                          recordTaskClick(tasks[index]);
                          setState(() {
                            lastClickedTask = tasks[index]; // Store the last clicked task
                            lastClickedTimestamp = DateTime.now().toString(); // Store the timestamp
                          });
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    // Navigate to TaskDetailScreen and pass the task data
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => TaskDetailScreen(
                          task: tasks[index],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (lastClickedTask != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: EdgeInsets.all(10),
                color: Colors.grey[200],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Last Clicked Task:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    Text('Title: ${lastClickedTask!['title']}'),
                    Text('Category: ${lastClickedTask!['category']}'),
                    Text('Start Time: ${lastClickedTask!['startTime']}'),
                    Text('Start Date: ${lastClickedTask!['startDate']}'),
                    Text('End Date: ${lastClickedTask!['endDate']}'),
                    SizedBox(height: 10),
                    // Display the timestamp when button was clicked
                    Text('Task clicked at: $lastClickedTimestamp'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
