import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math' show max; 

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stepHistoryBox = Hive.box('stepHistory');
    final accentColor = Theme.of(context).primaryColor; // Red
    
    // Theme-dependent colors for labels
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final chartTextColor = isDarkMode ? Colors.white70 : Colors.black54; 
    
    // We will keep the border color subtle for both themes
    final chartBorderColor = isDarkMode ? Colors.white12 : Colors.black12; 

    return Scaffold(
      appBar: AppBar(
        title: const Text("7-DAY HISTORY"),
      ),
      body: ValueListenableBuilder(
        valueListenable: stepHistoryBox.listenable(),
        builder: (context, box, widget) {
          final List<BarChartGroupData> chartData = [];
          final today = DateTime.now();
          int maxSteps = 0; 

          for (int i = 6; i >= 0; i--) {
            final day = today.subtract(Duration(days: i));
            final dayKey = DateFormat('yyyy-MM-dd').format(day);
            final steps = box.get(dayKey, defaultValue: 0);
            
            maxSteps = max(maxSteps, steps); 

            final bar = BarChartGroupData(
              x: 6 - i, 
              barRods: [
                BarChartRodData(
                  toY: steps.toDouble(), 
                  color: accentColor, 
                  width: 20,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                ),
              ],
            );
            chartData.add(bar);
          }

          if (chartData.isEmpty) {
            return const Center(child: Text("No data yet. Save some steps!"));
          }
          
          double maxY = max(10000.0, (maxSteps / 5000).ceil() * 5000.0);
          
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY, 
                // Only use FlBorderData for the external chart border
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: chartBorderColor, width: 1.0), 
                ),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: isDarkMode ? Colors.grey[800] : Colors.grey[200], 
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        rod.toY.round().toString(),
                        TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontWeight: FontWeight.bold), 
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  // Bottom (X-axis) titles
                  bottomTitles: AxisTitles(
                    // FIX: REMOVED the problematic 'axisLine'/'line' property entirely.
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        String text = '';
                        final day = today.subtract(Duration(days: 6 - value.toInt()));
                        text = DateFormat('E').format(day); 
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 4.0,
                          // Use dynamic text color for readability in both themes
                          child: Text(text, style: TextStyle(color: chartTextColor, fontSize: 12)), 
                        );
                      },
                    ),
                  ),
                  // Left (Y-axis) titles
                  leftTitles: AxisTitles(
                    // FIX: REMOVED the problematic 'axisLine'/'line' property entirely.
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 45,
                      getTitlesWidget: (value, meta) {
                        double interval = (maxY > 10000) ? 5000 : (maxY / 2).round().toDouble();
                        if (value % interval != 0 || value == 0) return Container(); 
                        return Text(
                          NumberFormat.compact().format(value), 
                          // Use dynamic text color for readability in both themes
                          style: TextStyle(color: chartTextColor, fontSize: 12), 
                          textAlign: TextAlign.left,
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                // Grid data for horizontal lines
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: chartBorderColor, // Use subtle color for internal lines
                    strokeWidth: 1,
                  ),
                ),
                barGroups: chartData,
              ),
            ),
          );
        },
      ),
    );
  }
}