import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:fl_heatmap/fl_heatmap.dart';
import 'package:d_chart/d_chart.dart';

class GraphWidgets {
  final rows = [
    '23',
    '22',
    '21',
    '20',
    '19',
    '18',
    '17',
    '16',
    '15',
    '14',
    '13',
    '12',
    '11',
    '10',
    '9',
    '8',
    '7',
    '6',
    '5',
    '4',
    '3',
    '2',
    '1',
    '0',
  ];

  final columns = [
    '0',
    '5',
    '10',
    '15',
    '20',
    '25',
    '30',
    '35',
    '40',
    '45',
    '50',
    '55',
  ];

  List<NumericData> test = [
    NumericData(domain: 5, measure: 5),
    NumericData(domain: 6, measure: 7),
    NumericData(domain: 1, measure: 1),
    NumericData(domain: 7, measure: 3),
    NumericData(domain: 3, measure: 4),
    NumericData(domain: 2, measure: 2),
  ];

  List<NumericData> getTaskTime(List<int> taskHour, List<int> taskMinute) {
    List<NumericData> taskTime = []; // Initialize the list outside the loop

    // Loop through the provided taskHour and taskMinute lists
    for (int i = 0; i < taskHour.length; i++) {
      // Create a NumericData object and add it to the taskTime list
      taskTime.add(NumericData(domain: taskMinute[i], measure: taskHour[i]));
    }
    print('taskHour: $taskHour');
    print('taskMinute: $taskMinute');
    return taskTime; // Return the populated list after the loop
  }

  Widget buildGraphSection(
    String selectedCategory,
    int notDoneCount,
    int doneCount,
    int goalCount,
    int ongoingCount,
    int dailyCount,
    int monthlyCount,
    int weeklyCount,
    int customCount,
    int dailyCat,
    int familyCat,
    int worksCat,
    int schoolsCat,
    int groceriesCat,
    int exerciseCat,
    int othersCat,
    List<int> taskHours,
    List<int> taskMinutes,
  ) {
    List<NumericData> taskTime = getTaskTime(taskHours, taskMinutes);

    print('taskHour: $taskHours');
    print('Tasktime: $taskTime');
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

            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(20),
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
              child: Column(
                children: [
                  Text(
                    'Incompleted To Do Timings',
                    style: TextStyle(fontSize: 24, color: Colors.black, fontWeight: FontWeight.bold)
                  ),
                  SizedBox(height: 10),
                  AspectRatio(
                    aspectRatio: 1 / 1,
                    child: DChartScatterN(
                      configSeriesScatter: ConfigSeriesScatterN(
                        seriesColor: Colors.orange,
                        showPointLabel: true,
                        pointRadiusBase: 10,

                        symbolRender: SymbolRenderCircle(isSolid: true),
                      ),
                      groupList: [NumericGroup(id: 'Task Time', data: taskTime)],
                    ),
                  ),
                ],
              )



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
}
