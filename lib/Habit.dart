import 'package:flutter/material.dart';

// Define the To-Do Item model
class TodoItem {
  String title;
  bool isCompleted;
  String? dueDate;

  TodoItem({
    required this.title,
    this.isCompleted = false,
    this.dueDate,
  });
}

// Define the To-Do List model (which contains a list of TodoItems)
class TodoList {
  String title;
  List<TodoItem> subTasks;

  TodoList({
    required this.title,
    this.subTasks = const [],
  });
}

// Home Page Content
class Habit extends StatefulWidget {
  const Habit({Key? key}) : super(key: key);

  @override
  _HabitState createState() => _HabitState();
}

class _HabitState extends State<Habit> {
  final List<TodoList> _todoLists = [];
  final TextEditingController _listTitleController = TextEditingController();
  final TextEditingController _subTaskController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();

  // Add a new To-Do List
  void _addTodoList() {
    if (_listTitleController.text.isNotEmpty) {
      setState(() {
        _todoLists.add(TodoList(
          title: _listTitleController.text,
        ));
      });
      _listTitleController.clear();
    }
  }

  // Add a sub-task under a To-Do List
  void _addSubTask(int listIndex) {
    if (_subTaskController.text.isNotEmpty) {
      setState(() {
        _todoLists[listIndex].subTasks.add(TodoItem(
          title: _subTaskController.text,
          dueDate: _dueDateController.text.isNotEmpty
              ? _dueDateController.text
              : null,
        ));
      });
      _subTaskController.clear();
      _dueDateController.clear();
    }
  }

  // Toggle a sub-task as complete/incomplete
  void _toggleSubTaskComplete(int listIndex, int subTaskIndex) {
    setState(() {
      _todoLists[listIndex].subTasks[subTaskIndex].isCompleted =
      !_todoLists[listIndex].subTasks[subTaskIndex].isCompleted;
    });
  }

  // Delete a sub-task
  void _deleteSubTask(int listIndex, int subTaskIndex) {
    setState(() {
      _todoLists[listIndex].subTasks.removeAt(subTaskIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To Do List'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          const CircleAvatar(
            backgroundImage: AssetImage('assets/avatar.jpg'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Motivational Quote (your previous image section)
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(26),
                child: Row(
                  children: [
                    const Image(
                      image: AssetImage('assets/images/mask.png'),  // Keep the image code as is
                      width: 350,
                    ),
                  ],
                ),
              ),
              // Create New To-Do List Section - Updated Design
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[200], // Light grey background
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: TextButton(
                  onPressed: _addTodoList,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Text(
                      'Create New To Do List',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple, // Similar to the text color in your image
                      ),
                    ),
                  ),
                ),
              ),
              // To-Do List and Sub-Tasks Section (the rest of the app remains the same)
              ListView.builder(
                shrinkWrap: true,
                itemCount: _todoLists.length,
                itemBuilder: (context, listIndex) {
                  final todoList = _todoLists[listIndex];
                  return Card(
                    margin: const EdgeInsets.all(10),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title of the To-Do List
                          Text(
                            todoList.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Add Sub-Task Section
                          TextField(
                            controller: _subTaskController,
                            decoration: const InputDecoration(
                              labelText: 'Add a sub-task',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _dueDateController,
                            decoration: const InputDecoration(
                              labelText: 'Due Date (e.g., 24 March 2024)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () => _addSubTask(listIndex),
                            child: const Text('Add Sub-Task'),
                          ),
                          const SizedBox(height: 20),
                          // Display Sub-Tasks
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: todoList.subTasks.length,
                            itemBuilder: (context, subTaskIndex) {
                              final subTask = todoList.subTasks[subTaskIndex];
                              return ListTile(
                                title: Text(
                                  subTask.title,
                                  style: TextStyle(
                                    decoration: subTask.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                subtitle: subTask.dueDate != null
                                    ? Text(
                                  'Due: ${subTask.dueDate}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                )
                                    : null,
                                leading: IconButton(
                                  icon: Icon(
                                    subTask.isCompleted
                                        ? Icons.check_box
                                        : Icons.check_box_outline_blank,
                                  ),
                                  onPressed: () => _toggleSubTaskComplete(
                                      listIndex, subTaskIndex),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _deleteSubTask(
                                      listIndex, subTaskIndex),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
