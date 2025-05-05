import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskDetailScreen extends StatefulWidget {
  final Map<String, dynamic> task;

  TaskDetailScreen({required this.task});

  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  bool isCompleted = false; // Initially, the task is not completed.
  bool isCheckboxDisabled = false; // Disable the checkbox after completion.

  @override
  void initState() {
    super.initState();
    // Set the initial state based on the task's current completion status
    isCompleted = widget.task['isCompleted'] ?? false;
    isCheckboxDisabled = isCompleted; // Disable the checkbox if already completed
  }

  // Update the task completion status in Firestore

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Task Details"),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Task Title
            Text(
              "Title: ${widget.task['title']}",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16),
            Divider(),

            // Task Category
            Text(
              "Category: ${widget.task['category']}",
              style: TextStyle(fontSize: 18, color: Colors.black54),
            ),
            SizedBox(height: 10),
            Divider(),

            // Task Start and End Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Start Date: ${widget.task['startDate']}",
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
                Text(
                  "End Date: ${widget.task['endDate']}",
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
              ],
            ),
            SizedBox(height: 16),
            Divider(),

            // Task Start and End Time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Start Time: ${widget.task['startTime']}",
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
                Text(
                  "End Time: ${widget.task['endTime']}",
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
              ],
            ),
            SizedBox(height: 20),
            Divider(),

            // Checkbox for task completion

          ],
        ),
      ),
    );
  }
}
