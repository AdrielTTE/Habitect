import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ModifyTaskScreen extends StatefulWidget {
  final String taskId;

  ModifyTaskScreen({required this.taskId});

  @override
  _ModifyTaskScreenState createState() => _ModifyTaskScreenState();
}

class _ModifyTaskScreenState extends State<ModifyTaskScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late TextEditingController _titleController;
  late TextEditingController _categoryController;
  late TextEditingController _startDateController;
  late TextEditingController _startTimeController;
  late TextEditingController _endDateController;
  late TextEditingController _endTimeController;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _categoryController = TextEditingController();
    _startDateController = TextEditingController();
    _startTimeController = TextEditingController();
    _endDateController = TextEditingController();
    _endTimeController = TextEditingController();
    fetchTaskDetails();
  }

  // Fetch the task details from Firestore
  Future<void> fetchTaskDetails() async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(_auth.currentUser?.uid)
          .collection('tasks')
          .doc(widget.taskId)
          .get();

      if (doc.exists) {
        setState(() {
          _titleController.text = doc['title'];
          _categoryController.text = doc['category'];
          _startDateController.text = doc['startDate'];
          _startTimeController.text = doc['startTime'];
          _endDateController.text = doc['endDate'] ?? '';
          _endTimeController.text = doc['endTime'] ?? '';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching task: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Save the modified task to Firestore
  Future<void> saveTask() async {
    try {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser?.uid)
          .collection('tasks')
          .doc(widget.taskId)
          .update({
        'title': _titleController.text,
        'category': _categoryController.text,
        'startDate': _startDateController.text,
        'startTime': _startTimeController.text,
        'endDate': _endDateController.text,
        'endTime': _endTimeController.text,
      });
      Navigator.of(context).pop(); // Return to previous screen after saving
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Task updated successfully')));
    } catch (e) {
      print('Error updating task: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating task')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange, // Orange color for the app bar
        title: Text(
          'Modify Task',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black, // White text for contrast
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Text fields with styling
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: TextStyle(color: Colors.black),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.orange),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _categoryController,
                decoration: InputDecoration(
                  labelText: 'Category',
                  labelStyle: TextStyle(color: Colors.black),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.orange),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _startDateController,
                decoration: InputDecoration(
                  labelText: 'Start Date',
                  labelStyle: TextStyle(color: Colors.black),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.orange),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _startTimeController,
                decoration: InputDecoration(
                  labelText: 'Start Time',
                  labelStyle: TextStyle(color: Colors.black),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.orange),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _endDateController,
                decoration: InputDecoration(
                  labelText: 'End Date (optional)',
                  labelStyle: TextStyle(color: Colors.black),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.orange),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _endTimeController,
                decoration: InputDecoration(
                  labelText: 'End Time (optional)',
                  labelStyle: TextStyle(color: Colors.black),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.orange),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Save button with custom styling
              ElevatedButton(
                onPressed: saveTask,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.orange, // White text
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Save Task',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
