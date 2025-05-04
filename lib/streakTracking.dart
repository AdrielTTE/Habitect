import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();

    // Automatically set the selected year and month based on the system date
    selectedYear = currentYear.toString();
    selectedMonth = months[currentMonth - 1]; // Month is 1-based, list is 0-based
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
        const Text('Most Goals Completed: 5'),
        const Text('Average Completed Per Month: 2'),
        const SizedBox(height: 20),
        const Text('Goal Progress', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ..._buildGoalProgressCards(),
        const SizedBox(height: 20),
        const Text('Priority Chart', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        _buildPriorityChart(),
      ],
    );
  }

  // To Do content
  Widget _buildToDoContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('To Do Completed', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildGraphSection(),
        const SizedBox(height: 8),
        const Text('Most To Dos Completed: 18'),
        const Text('Average Completed Per Week: 9'),
        const SizedBox(height: 20),
        const Text('To Do Progress', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        _buildPriorityChart(),
      ],
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
      child: const Center(
        child: Text('Graph Placeholder', style: TextStyle(color: Colors.grey)),
      ),
    );
  }

  // Goal Progress Cards with better styling
  List<Widget> _buildGoalProgressCards() {
    final goals = [
      {'name': 'Read 10 books', 'progress': 78},
      {'name': 'Lose 5kg', 'progress': 74},
      {'name': 'Write a research thesis', 'progress': 71},
      {'name': 'Run 100KM', 'progress': 54},
      {'name': 'Get Cisco CCNA certification', 'progress': 47},
      {'name': 'Travel to 5 countries', 'progress': 27},
    ];

    return goals.map((goal) {
      return Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(goal['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: (goal['progress'] as int) / 100,
                color: Colors.orange,
                backgroundColor: Colors.grey.shade300,
                minHeight: 10,
              ),
              const SizedBox(height: 4),
              Text('${goal['progress']}%', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );
    }).toList();
  }

  // Pie Chart for Priority Breakdown (using pie_chart package)
  Widget _buildPriorityChart() {
    Map<String, double> data = {
      'Low Priority': 14.8,
      'Medium Priority': 19.4,
      'High Priority': 66.19,
    };

    return PieChart(
      dataMap: data,
      chartType: ChartType.ring,
      colorList: [Colors.red.shade700, Colors.orange.shade700, Colors.green.shade700],
      chartRadius: 150,
      centerText: "Priority",
      legendOptions: const LegendOptions(showLegends: true),
      chartValuesOptions: const ChartValuesOptions(showChartValues: false),
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
