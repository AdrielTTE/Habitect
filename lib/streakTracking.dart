import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pie_chart/pie_chart.dart'; // Import pie_chart package

class StreakTracking extends StatefulWidget {
  const StreakTracking({super.key, required this.title});

  final String title;

  @override
  State<StreakTracking> createState() => _StreakTrackingState();
}

class _StreakTrackingState extends State<StreakTracking> {
  String selectedCategory = 'Goals'; // Default category is 'Goals'
  String selectedYear = '';
  String selectedMonth = '';

  // Year options
  List<String> years = ['2022', '2023', '2024', '2025'];

  // Month options
  List<String> months = [
    'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August',
    'September', 'October', 'November', 'December'
  ];

  // Get the current date and month
  DateTime currentDate = DateTime.now();
  int currentMonth = DateTime.now().month;
  int currentYear = DateTime.now().year;

  // List to store the "To Do" tasks
  List<Map<String, dynamic>> _todoTasks = [];

  // Counts for completed and incomplete tasks
  int doneCount = 0;
  int notDoneCount = 0;

  // For storing goal progress
  int dailyCount = 0;
  int monthlyCount = 0;
  int weeklyCount = 0;

  @override
  void initState() {
    super.initState();

    // Automatically set the selected year and month based on the system date
    selectedYear = currentYear.toString();
    selectedMonth = months[currentMonth - 1]; // Month is 1-based, list is 0-based

    // Fetch the "To Do" tasks when the screen is initialized
    if (selectedCategory == 'To Do') {
      _fetchToDoTasks();
    } else {
      _fetchGoalsData();
    }
  }

  // Fetch "Goals" data from Firestore
  void _fetchGoalsData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Fetch goals from Firestore based on frequency
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('goals')
            .where('startDate', isGreaterThanOrEqualTo: selectedMonth)
            .get();

        setState(() {
          // Reset counts for categories
          dailyCount = 0;
          monthlyCount = 0;
          weeklyCount = 0;

          // Calculate the goal progress based on frequency
          querySnapshot.docs.forEach((doc) {
            if (doc['frequency'] == 'Daily') {
              dailyCount++;
            } else if (doc['frequency'] == 'Monthly') {
              monthlyCount++;
            } else if (doc['frequency'] == 'Weekly') {
              weeklyCount++;
            }
          });
        });
      }
    } catch (e) {
      print("Error fetching Goals: $e");
    }
  }

  // Fetch "To Do" tasks from Firestore
  void _fetchToDoTasks() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Fetch tasks from Firestore
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('notes')
            .get();

        setState(() {
          _todoTasks = querySnapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();

          // Recalculate the counts every time we fetch the tasks
          doneCount = _todoTasks.where((task) => task['isDon'] == true).length;
          notDoneCount = _todoTasks.where((task) => task['isDon'] == false).length;
        });

        // For debugging
        print("Fetched To Do Tasks: $_todoTasks");
      }
    } catch (e) {
      print("Error fetching To Do tasks: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    Color dropdownColor = Colors.orange.shade300; // Set consistent color for all dropdowns

    return Scaffold(
      appBar: AppBar(
        title: const Text('Summary'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0, // Removing shadow for a cleaner look
      ),
      body: SingleChildScrollView( // Wrap the content in SingleChildScrollView
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 16), // Spacing between the title and dropdowns
            _buildCategoryYearMonthDropdowns(dropdownColor),
            _buildCategoryContent(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.house), label: 'Summary'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Learn'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Community'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }

  // Build Dropdowns for Category, Year, and Month
  Widget _buildCategoryYearMonthDropdowns(Color dropdownColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildDropdown<String>(
          value: selectedCategory,
          items: ['Goals', 'To Do'],
          onChanged: (value) {
            setState(() {
              selectedCategory = value!;
              selectedYear = currentYear.toString();
              selectedMonth = months[currentMonth - 1];
            });
            // Fetch "To Do" tasks when category is switched to 'To Do'
            if (selectedCategory == 'To Do') {
              _fetchToDoTasks();
            } else {
              _fetchGoalsData();
            }
          },
          dropdownColor: dropdownColor,
        ),
        _buildDropdown<String>(
          value: selectedYear,
          items: years,
          onChanged: (value) {
            setState(() {
              selectedYear = value!;
              selectedMonth = 'January';
            });
            // Fetch tasks based on the selected year
            if (selectedCategory == 'To Do') {
              _fetchToDoTasks();
            } else {
              _fetchGoalsData();
            }
          },
          dropdownColor: dropdownColor,
        ),
        _buildDropdown<String>(
          value: selectedMonth,
          items: _getAvailableMonths(),
          onChanged: (value) {
            setState(() {
              selectedMonth = value!;
            });
            // Fetch tasks again based on the selected month
            if (selectedCategory == 'To Do') {
              _fetchToDoTasks();
            } else {
              _fetchGoalsData();
            }
          },
          dropdownColor: dropdownColor,
        ),
      ],
    );
  }

  // Build a Dropdown for Category, Year, or Month
  Widget _buildDropdown<T>({
    required T value,
    required List<String> items,
    required ValueChanged<T?> onChanged,
    required Color dropdownColor,
  }) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: dropdownColor, // Use the same color for all dropdowns
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<T>(
        value: value,
        items: items
            .map((item) => DropdownMenuItem<T>(
          value: item as T,
          child: Text(item, style: const TextStyle(color: Colors.white)),
        ))
            .toList(),
        onChanged: onChanged,
        icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
        dropdownColor: dropdownColor, // Make sure dropdown background color matches
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  // Content based on the selected category (Goals or To Do)
  Widget _buildCategoryContent() {
    if (selectedCategory == 'Goals') {
      return _buildGoalsContent();
    }
    return _buildToDoContent();
  }

  // Goals content
  Widget _buildGoalsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Goals Completed', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildGraphSection(),
        const SizedBox(height: 8),
        Text('Most Goals Completed: $doneCount'),
        const SizedBox(height: 20),
        const Text('Goal Progress', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        const SizedBox(height: 20),
        const Text('Priority Chart', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
      ],
    );
  }

  // To Do content (Display the To Do tasks here)
  Widget _buildToDoContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('To Do Completed', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildGraphSection(),
        const SizedBox(height: 8),
        // Display dynamic count of completed and not completed tasks
        Text('Number of To Dos Completed: $doneCount'),
        Text('Number of To Dos Incompleted: $notDoneCount'),
        const SizedBox(height: 20),
        const Text('To Do List', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        _buildToDoList(),
      ],
    );
  }

  // Build the To Do list
  Widget _buildToDoList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: _todoTasks.length,
      itemBuilder: (context, index) {
        var task = _todoTasks[index];
        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            title: Text(task['title'] ?? 'No Title'),
            subtitle: Text(task['subtitle'] ?? 'No Subtitle'),
            trailing: Icon(
              task['isDon'] ? Icons.check_box : Icons.check_box_outline_blank,
              color: task['isDon'] ? Colors.green : Colors.grey,
            ),
          ),
        );
      },
    );
  }

  // Graph Section for Goals and To Do
  Widget _buildGraphSection() {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: PieChart(
        dataMap: {
          "Daily": dailyCount.toDouble(),
          "Monthly": monthlyCount.toDouble(),
          "Weekly": weeklyCount.toDouble(),
        },
        chartType: ChartType.ring,
        colorList: [Colors.orange, Colors.blue, Colors.green], // Updated colors
        chartRadius: 150,
        centerText: "Goal Progress",
        legendOptions: const LegendOptions(showLegends: true),
        chartValuesOptions: const ChartValuesOptions(showChartValues: false), // Remove numbers on Pie chart
      ),
    );
  }

  // Get available months based on the current year and month
  List<String> _getAvailableMonths() {
    List<String> availableMonths = months;

    if (int.parse(selectedYear) == currentYear) {
      availableMonths = months.sublist(0, currentMonth);
    }

    return availableMonths;
  }
}
