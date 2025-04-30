import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // For Line Chart

class StreakTracking extends StatefulWidget {
  const StreakTracking({super.key, required this.title});

  final String title;

  @override
  State<StreakTracking> createState() => _StreakTrackingState();
}

class _StreakTrackingState extends State<StreakTracking> {
  String selectedYear = '2024'; // Track the selected year

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Summary'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0, // Removing shadow for a cleaner look
        actions: [
          // Year Dropdown with custom styling
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButton<String>(
              value: selectedYear,
              items: ['2022', '2023', '2024']
                  .map((year) => DropdownMenuItem(
                value: year,
                child: Text(
                  year,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
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
              dropdownColor: Colors.deepPurple.shade300,
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Line Chart
                    Container(
                      height: 250,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: true),
                          titlesData: FlTitlesData(show: true),
                          borderData: FlBorderData(show: true),
                          lineBarsData: [
                            LineChartBarData(
                              spots: [
                                FlSpot(0, 5),
                                FlSpot(1, 6),
                                FlSpot(2, 10),
                                FlSpot(3, 12),
                                FlSpot(4, 14),
                                FlSpot(5, 18),
                                FlSpot(6, 20),
                                FlSpot(7, 25),
                              ],
                              isCurved: true,
                              colors: [Colors.deepPurple],
                              belowBarData: BarAreaData(show: true, colors: [Colors.deepPurple.withOpacity(0.3)]),
                              barWidth: 4,
                            ),
                          ],
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
                color: Colors.blue,
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
}
