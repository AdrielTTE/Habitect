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
  String selectedYear = '2024';
  String selectedMonth = 'January';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Summary'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0, // Removing shadow for a cleaner look
        actions: [
          // Multi-Level Dropdown Menu for Category (Goals, To Do, Habits)
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orange.shade300, // Change color to match the design
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButton<String>(
              value: selectedCategory,
              items: ['Goals', 'To Do', 'Habits']
                  .map((category) => DropdownMenuItem(
                value: category,
                child: Text(
                  category,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                  // Reset year and month on category change
                  selectedYear = '2024';
                  selectedMonth = 'January';
                });
              },
              icon: const Icon(
                Icons.arrow_drop_down,
                color: Colors.white,
              ),
              dropdownColor: Colors.orange.shade300, // Change color
              style: const TextStyle(color: Colors.white),
            ),
          ),
          // Year Dropdown
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange.shade200, // Change color to match the design
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButton<String>(
              value: selectedYear,
              items: ['2022', '2023', '2024']
                  .map((year) => DropdownMenuItem(
                value: year,
                child: Text(
                  year,
                  style: const TextStyle(color: Colors.white),
                ),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedYear = value!;
                });
              },
              icon: const Icon(
                Icons.arrow_drop_down,
                color: Colors.white,
              ),
              dropdownColor: Colors.orange.shade200, // Change color
              style: const TextStyle(color: Colors.white),
            ),
          ),
          // Month Dropdown
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange.shade200, // Change color to match the design
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButton<String>(
              value: selectedMonth,
              items: ['January', 'February', 'March', 'April', 'May']
                  .map((month) => DropdownMenuItem(
                value: month,
                child: Text(
                  month,
                  style: const TextStyle(color: Colors.white),
                ),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedMonth = value!;
                });
              },
              icon: const Icon(
                Icons.arrow_drop_down,
                color: Colors.white,
              ),
              dropdownColor: Colors.orange.shade200, // Change color
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Graph Section (Line Chart)
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Goals Completed (Jan - Aug)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Line Chart Placeholder (use your own graph logic here)
                    Container(
                      height: 250,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'Graph Placeholder',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Most Goals Completed: 5'),
                    const Text('Average Completed Per Month: 2'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Goal Progress Section
            const Text(
              'Goal Progress',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ..._buildGoalProgressCards(),
            const SizedBox(height: 20),
            // Priority Chart (Pie Chart using pie_chart package)
            const Text(
              'Priority Chart',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildPriorityChart(),
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
              Text(
                goal['name'] as String,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: (goal['progress'] as int) / 100,
                color: Colors.orange, // Change to orange to match the screenshot
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
      colorList: [Colors.red.shade700, Colors.orange.shade700, Colors.green.shade700], // Adjust colors
      chartRadius: 150,
      centerText: "Priority",
      legendOptions: const LegendOptions(showLegends: true),
      chartValuesOptions: const ChartValuesOptions(showChartValues: false),
    );
  }
}
