import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StreakTracking extends StatefulWidget {
  const StreakTracking({super.key, required this.title});

  final String title;

  @override
  State<StreakTracking> createState() => _StreakTrackingState();
}


//UI
class _StreakTrackingState extends State<StreakTracking>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Summary'),
            centerTitle: true,
        backgroundColor: Colors.white,


        actions: [
          DropdownButton<String>(
            value: '2024',
            items: ['2022', '2023', '2024']
                .map((year) => DropdownMenuItem(
              value: year,
              child: Text(year),
            ))
                .toList(),
            onChanged: (value) {
              // Handle year change
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Graph Section
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
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
                    // Placeholder for Graph
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
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
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.house), label: 'Summary'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Learn'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Community'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }

  // Progress Cards
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
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                goal['name'] as String,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: (goal['progress'] as int) / 100,
                color: Colors.blue,
                backgroundColor: Colors.grey.shade300,
              ),
              const SizedBox(height: 4),
              Text('${goal['progress']}%'),
            ],
          ),
        ),
      );
    }).toList();
  }
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }
