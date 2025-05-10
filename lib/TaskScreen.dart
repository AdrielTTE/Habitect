import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'ModifyTaskScreen.dart';
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
  Map<String, dynamic>? lastClickedTask;
  String? lastClickedTimestamp;

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  // Fetch tasks from Firestore
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
            'id': doc.id,
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

  // Record task click
  Future<void> recordTaskClick(Map<String, dynamic> task) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('users')
            .doc(user.uid)
            .collection('taskLogs')
            .add({
          'taskName': task['title'],
          'clickedAt': FieldValue.serverTimestamp(),
          'category': task['category'],
          'startTime': task['startTime'],
        });
        print('Task click recorded!');
      } catch (e) {
        print('Error recording task click: $e');
      }
    }
  }

  // Delete task
  Future<void> deleteTask(String taskId) async {
    bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
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
  }

  // Navigate to ModifyTaskScreen
  void modifyTask(String taskId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ModifyTaskScreen(taskId: taskId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange, // Orange app bar
        title: Text(
          "Your Tasks",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: tasks.isEmpty
                ? Center(child: Text('No tasks available.', style: TextStyle(fontSize: 18, color: Colors.grey)))
                : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    title: Text(
                      tasks[index]['title'],
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "Category: ${tasks[index]['category']}",
                      style: TextStyle(color: Colors.grey),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.check, color: Colors.green),
                          onPressed: () {
                            recordTaskClick(tasks[index]);
                            setState(() {
                              lastClickedTask = tasks[index];
                              lastClickedTimestamp = DateTime.now().toString();
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.orange),
                          onPressed: () {
                            modifyTask(tasks[index]['id']);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            deleteTask(tasks[index]['id']);
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => TaskDetailScreen(
                            task: tasks[index],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          if (lastClickedTask != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: EdgeInsets.all(10),
                color: Colors.grey[100],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Last Clicked Task:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(height: 5),
                    Text('Title: ${lastClickedTask!['title']}'),
                    Text('Category: ${lastClickedTask!['category']}'),
                    Text('Start Time: ${lastClickedTask!['startTime']}'),
                    Text('Start Date: ${lastClickedTask!['startDate']}'),
                    if (lastClickedTask!['endDate'] != null)
                      Text('End Date: ${lastClickedTask!['endDate']}'),
                    SizedBox(height: 10),
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
