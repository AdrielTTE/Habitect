import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:fl_heatmap/fl_heatmap.dart';


class GraphWidgets {
  final rows = [
    '22',
    '20',
    '18',
    '16',
    '14',
    '12',
    '10',
    '8',
    '6',
    '4',
    '2',
    '0',

  ];

  final columns = [
    '0', '10', '20', '30', '40', '50', '60'

  ];

  final r = Random();

  Widget buildGraphSection(String selectedCategory, int notDoneCount, int doneCount, int goalCount, int ongoingCount, int dailyCount, int monthlyCount, int weeklyCount, int customCount, int dailyCat, int familyCat, int worksCat, int schoolsCat, int groceriesCat, int exerciseCat, int othersCat) {
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

            SizedBox(height:20),
            Container(
              padding:EdgeInsets.all(20),
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
              child: Heatmap(heatmapData: HeatmapData(rows: rows, columns: columns, items: [
                for (int row = 0; row < rows.length; row++)
                  for (int col = 0; col < columns.length; col++)
                    HeatmapItem(
                        value: r.nextDouble() * 6,
                        xAxisLabel: columns[col],

                        yAxisLabel: rows[row]),
              ]),
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
