import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pie_chart/pie_chart.dart';

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
  int monthNumber = 1;
  int yearNumber=0;

  // Year options
  List<String> years = ['2022', '2023', '2024', '2025'];

  // Month options
  List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
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
  int goalCount = 0;
  int ongoingCount = 0;

  // For storing goal progress
  int dailyCount = 0;
  int monthlyCount = 0;
  int weeklyCount = 0;
  int customCount = 0;

  //For Categories
  int dailyCat = 0;
  int familyCat = 0;
  int groceriesCat = 0;
  int exerciseCat = 0;
  int worksCat = 0;
  int schoolsCat = 0;
  int othersCat = 0;
  int allTaskCount = 0;

  // To store task completion by hour (heatmap data)
  Map<int, int> taskHours = {};

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

  void _fetchGoalsData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {

        // Fetch all tasks from Firestore
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('tasks')
            .get(); // Fetching all tasks

        goalCount = querySnapshot.docs.length;
        // Initialize a list to store the filtered tasks
        List<QueryDocumentSnapshot> filteredDocs = [];

        // Loop through the tasks and filter based on the selected month and year
        querySnapshot.docs.forEach((doc) {
          String taskDateString = doc['startDate']; // For example, "5/13/2025"

          // Split the string by '/'
          List<String> dateParts = taskDateString.split('/');

          // Extract the month and year as integers
          int taskMonth = int.parse(dateParts[0]); // Extract month (e.g., 5 from "5/13/2025")
          int taskYear = int.parse(dateParts[2]); // Extract year (e.g., 2025 from "5/13/2025")

          // Debug: Print the extracted month and year
          print('Task Month: $taskMonth, Task Year: $taskYear');

          // Compare the task's month and year with the selected month and year
          if (taskMonth == monthNumber && taskYear == yearNumber) {
            // If the task's month and year match the selected month and year, add it to filteredDocs
            filteredDocs.add(doc);
         }

        });

        setState(() {
          // Reset counts for categories
          dailyCount = 0;
          monthlyCount = 0;
          weeklyCount = 0;
          customCount = 0;
          dailyCat = 0;
          familyCat = 0;
          groceriesCat = 0;
          exerciseCat = 0;
          worksCat = 0;
          schoolsCat = 0;
          othersCat = 0;
          allTaskCount = 0;

          ongoingCount = filteredDocs.length; // Count the total number of goals

          // Calculate the goal progress based on frequency for filtered tasks
          filteredDocs.forEach((doc) {
            // Check if 'frequency' is a map and get the 'type' field
            var frequency = doc['frequency'];

            if (frequency is Map && frequency.containsKey('type')) {
              // Access the 'type' field inside the map
              String frequencyType = frequency['type'];

              // Count based on frequency
              if (frequencyType == 'Daily') {
                dailyCount++;
              } else if (frequencyType == 'Monthly') {
                monthlyCount++;
              } else if (frequencyType == 'Weekly') {
                weeklyCount++;
              } else {
                customCount++;
              }
            }

            var category = doc['category'];

            switch (category) {
              case 'Daily':
                dailyCat++;
                break;
              case 'Family':
                familyCat++;
                break;
              case 'Groceries':
                groceriesCat++;
                break;
              case 'Exercise':
                exerciseCat++;
                break;
              case 'Works':
                worksCat++;
                break;
              case 'Schools':
                schoolsCat++;
                break;
              case 'Others':
                othersCat++;
                break;
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
        QuerySnapshot querySnapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('notes')
                .get();

        setState(() {
          _todoTasks =
              querySnapshot.docs
                  .map((doc) => doc.data() as Map<String, dynamic>)
                  .toList();

          // Recalculate the counts every time we fetch the tasks
          doneCount = _todoTasks.where((task) => task['isDon'] == true).length;
          notDoneCount =
              _todoTasks.where((task) => task['isDon'] == false).length;

          // Initialize the taskHours map to track tasks per hour
          taskHours.clear();
          _todoTasks.forEach((task) {
            String timeString =
                task['time'] ?? ''; // Assuming it's in the format "HH:mm"
            if (timeString.isNotEmpty) {
              // Validate and extract the hour part from time (e.g., "13:30" -> 13)
              int hour = int.tryParse(timeString.split(':')[0]) ?? 0;
              if (hour >= 0 && hour < 24) {
                // Increment the task count for the respective hour
                taskHours[hour] = (taskHours[hour] ?? 0) + 1;
              }
            }
          });
        });
      }
    } catch (e) {
      print("Error fetching To Do tasks: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    Color dropdownColor =
        Colors.orange.shade300; // Set consistent color for all dropdowns

    return Scaffold(
      appBar: AppBar(
        title: const Text('Summary'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0, // Removing shadow for a cleaner look
      ),
      body: SingleChildScrollView(
        // Wrap the content in SingleChildScrollView
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(
              height: 16,
            ), // Spacing between the title and dropdowns
            _buildCategoryYearMonthDropdowns(dropdownColor),
            _buildCategoryContent(),
          ],
        ),
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
              yearNumber = int.parse(selectedYear);
              print(yearNumber);
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
              switch (selectedMonth) {
                case 'January':
                  monthNumber = 1;
                  break;
                case 'February':
                  monthNumber = 2;
                  break;
                case 'March':
                  monthNumber = 3;
                  break;
                case 'April':
                  monthNumber = 4;
                  break;
                case 'May':
                  monthNumber = 5;
                  break;
                case 'June':
                  monthNumber = 6;
                  break;
                case 'July':
                  monthNumber = 7;
                  break;
                case 'August':
                  monthNumber = 8;
                  break;
                case 'September':
                  monthNumber = 9;
                  break;
                case 'October':
                  monthNumber = 10;
                  break;
                case 'November':
                  monthNumber = 11;
                  break;
                case 'December':
                  monthNumber = 12;
                  break;
                default:
                  monthNumber = -1;
                  break;
              }
              print(selectedMonth);
              print(monthNumber);
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
        items:
            items
                .map(
                  (item) => DropdownMenuItem<T>(
                    value: item as T,
                    child: Text(
                      item,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                )
                .toList(),
        onChanged: onChanged,
        icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
        dropdownColor:
            dropdownColor, // Make sure dropdown background color matches
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  // Content based on the selected category (Goals or To Do)
  Widget _buildCategoryContent() {
    return _buildGoalsContent();
  }

  Widget _buildGraphSection() {
    if (selectedCategory == 'To Do') {
      // This section is for the "To Do" pie chart
      return Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white, // Background color for the container
          borderRadius: BorderRadius.circular(16), // Rounded corners
        ),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  height: 191,
                  width: 191,
                  decoration: BoxDecoration(
                    color: Colors.deepOrange,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.5),
                        spreadRadius: 3,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    '\nIncompleted\n$notDoneCount',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 23),
                Container(
                  padding: EdgeInsets.all(16),
                  height: 191,
                  width: 191,
                  decoration: BoxDecoration(
                    color: Colors.lightGreen,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.5),
                        spreadRadius: 3,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    '\nCompleted\n$doneCount',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            Container(

              height: 350,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.5),
                    spreadRadius: 3,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: PieChart(
                dataMap: {
                  "Completed": doneCount.toDouble(),
                  "Incomplete": notDoneCount.toDouble(),
                },
                chartType: ChartType.ring,
                colorList: [
                  Colors.green,
                  Colors.red,
                ], // Completed in green, Incomplete in red
                chartRadius: 200,
                centerText: "Task Progress",
                centerTextStyle: TextStyle(fontSize: 24, color: Colors.black),
                legendOptions: const LegendOptions(
                  showLegends: true,
                  legendTextStyle: TextStyle(fontSize: 18),
                ),
                chartValuesOptions: const ChartValuesOptions(
                  showChartValues: false,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // This section is for the "Goals" pie chart
      return Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white, // Background color for the container
          borderRadius: BorderRadius.circular(16), // Rounded corners
        ),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  height: 191,
                  width: 191,
                  decoration: BoxDecoration(
                    color: Colors.deepOrange,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.5),
                        spreadRadius: 3,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    '\nTotal Goals\n$goalCount',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 23),
                Container(
                  padding: EdgeInsets.all(16),
                  height: 191,
                  width: 191,
                  decoration: BoxDecoration(
                    color: Colors.lightGreen,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.5),
                        spreadRadius: 3,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    '\nActive Goals\n$ongoingCount',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Container(
              height: 350,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.5),
                    spreadRadius: 3,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: PieChart(
                dataMap: {
                  "Daily": dailyCount.toDouble(),
                  "Monthly": monthlyCount.toDouble(),
                  "Weekly": weeklyCount.toDouble(),
                  "Custom": customCount.toDouble(),
                },
                chartType: ChartType.ring,
                colorList: [
                  Colors.orange,
                  Colors.blue,
                  Colors.green,
                  Colors.purple,
                ],
                chartRadius: 200,
                centerText: "Frequency",
                centerTextStyle: TextStyle(fontSize: 24, color: Colors.black),
                legendOptions: const LegendOptions(
                  showLegends: true,
                  legendTextStyle: TextStyle(fontSize: 18),
                ),
                chartValuesOptions: const ChartValuesOptions(
                  showChartValues: false,
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              height: 350,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.5),
                    spreadRadius: 3,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: PieChart(
                dataMap: {
                  "Daily": dailyCat.toDouble(),
                  "Family": familyCat.toDouble(),
                  "Groceries": groceriesCat.toDouble(),
                  "Exercise": exerciseCat.toDouble(),
                  "Works": worksCat.toDouble(),
                  "Schools": schoolsCat.toDouble(),
                  "Others": othersCat.toDouble(),
                },
                chartType: ChartType.ring,
                colorList: [
                  Colors.blueGrey,
                  Colors.cyanAccent,
                  Colors.pinkAccent,
                  Colors.teal,
                  Colors.cyan,
                  Colors.yellow,
                  Colors.green,
                ],
                chartRadius: 200,
                centerText: "Category",
                centerTextStyle: TextStyle(fontSize: 24, color: Colors.black),
                legendOptions: const LegendOptions(
                  showLegends: true,
                  legendTextStyle: TextStyle(fontSize: 18),
                ),
                chartValuesOptions: const ChartValuesOptions(
                  showChartValues: false,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  // Goals content
  Widget _buildGoalsContent() {
    if (selectedCategory == 'Goals') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 70),
          const Text(
            'Goals Summary',
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildGraphSection(),
          const SizedBox(height: 20),


        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 70),
          const Text(
            'To Dos Summary',
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildGraphSection(),
          const SizedBox(height: 20),
          const SizedBox(height: 20),
          const SizedBox(height: 10),
          const SizedBox(height: 20),
          const SizedBox(height: 20),
          const SizedBox(height: 10),
        ],
      );
    }
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

  // Build the heatmap for task times
  Widget _buildHeatmap() {
    return Container(
      height: 250,
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 24, // Represent each hour of the day
          childAspectRatio: 1.0,
        ),
        itemCount: 24,
        itemBuilder: (context, index) {
          // Get task count for each hour
          int taskCount = taskHours[index] ?? 0;

          return Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color:
                  taskCount > 0
                      ? Colors.green.withOpacity(taskCount / 5)
                      : Colors.grey,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$taskCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
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
