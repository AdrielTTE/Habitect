import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
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

  final DateFormat formatter = DateFormat('MM/dd/yyyy');

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    User? user = _auth.currentUser;
    if (user != null) {
      uid = user.uid;

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

        // Sort by startDate ascending
        fetchedTasks.sort((a, b) =>
            formatter.parse(a['startDate']).compareTo(formatter.parse(b['startDate'])));

        setState(() {
          tasks = fetchedTasks;
          isLoading = false;
        });
      } catch (e) {
        setState(() => isLoading = false);
        print('Error fetching tasks: $e');
      }
    }
  }

  Future<void> recordTaskClick(Map<String, dynamic> task) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).collection('taskLogs').add({
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

  Future<void> deleteTask(String taskId) async {
    bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancel')),
            TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Delete')),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      try {
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('tasks')
            .doc(taskId)
            .delete();
        setState(() {
          tasks.removeWhere((task) => task['id'] == taskId);
        });
        print('Task deleted successfully!');
      } catch (e) {
        print('Error deleting task: $e');
      }
    }
  }

  void modifyTask(String taskId) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ModifyTaskScreen(taskId: taskId),
    ));
  }

  bool isApproachingEndDate(String endDate) {
    DateTime now = DateTime.now();
    DateTime taskEndDate = formatter.parse(endDate);
    Duration diff = taskEndDate.difference(now);
    return diff.inDays <= 3 && diff.inDays >= 0;
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();

    List<Map<String, dynamic>> ongoingTasks = tasks.where((task) {
      DateTime taskEndDate = formatter.parse(task['endDate']);
      return taskEndDate.isAfter(now) || taskEndDate.isAtSameMomentAs(now);
    }).toList();

    List<Map<String, dynamic>> endedTasks = tasks.where((task) {
      DateTime taskEndDate = formatter.parse(task['endDate']);
      return taskEndDate.isBefore(now);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text(
          "Your Tasks",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            sectionHeader('Ongoing Tasks'),
            taskListView(ongoingTasks, 'No ongoing tasks available.'),
            sectionHeader('Ended Tasks'),
            taskListView(endedTasks, 'No ended tasks available.'),
            if (lastClickedTask != null) lastClickedTaskWidget(),
          ],
        ),
      ),
    );
  }

  Widget sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    );
  }

  Widget taskListView(List<Map<String, dynamic>> tasks, String emptyMessage) {
    if (tasks.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(emptyMessage,
            style: TextStyle(fontSize: 16, color: Colors.grey)),
      );
    }

    return Column(children: tasks.map(taskCard).toList());
  }

  Widget lastClickedTaskWidget() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: EdgeInsets.all(10),
        color: Colors.grey[100],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Last Clicked Task:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
    );
  }

  Widget taskCard(Map<String, dynamic> task) {
    bool isUrgent = isApproachingEndDate(task['endDate']);
    Color urgentColor = Colors.red[300]!;
    Color normalColor = Colors.white;

    return Card(
      color: isUrgent ? urgentColor : normalColor,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        title: Text(task['title'],
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        subtitle: Text("Category: ${task['category']}",
            style: TextStyle(color: Colors.grey[700])),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(
            icon: Icon(Icons.check, color: isUrgent ? Colors.white : Colors.green),
            onPressed: () {
              recordTaskClick(task);
              setState(() {
                lastClickedTask = task;
                lastClickedTimestamp = DateTime.now().toString();
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.edit, color: isUrgent ? Colors.white : Colors.orange),
            onPressed: () => modifyTask(task['id']),
          ),
          IconButton(
            icon: Icon(Icons.delete, color: isUrgent ? Colors.white : Colors.red),
            onPressed: () => deleteTask(task['id']),
          ),
        ]),
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => TaskDetailScreen(task: task))),
      ),
    );
  }

}
