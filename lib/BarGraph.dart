import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
class BarGraph{

  Widget buildBarGraph(){
    return Container(
      height: 200,
      width: 200,
      child: BarChart(
        BarChartData(
          barGroups:[
            BarChartGroupData(x: 0,
              barRods: [
                BarChartRodData(toY: 10),
              ],
            
            ),
            BarChartGroupData(x: 0,
              barRods: [
                BarChartRodData(toY: 13),
              ],

            ),
            BarChartGroupData(x: 0,
              barRods: [
                BarChartRodData(toY: 14),
              ],



            )
            
          ]
        )
      ),

    );

  }
}