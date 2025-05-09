import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:habitect/BarGraph.dart';


class GraphWidgets {
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
