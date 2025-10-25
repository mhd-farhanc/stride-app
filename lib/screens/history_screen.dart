// lib/screens/history_screen.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stepHistoryBox = Hive.box('stepHistory');
    final accentColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text("7-DAY HISTORY"),
      ),
      // Use ValueListenableBuilder to automatically rebuild
      // when the database changes.
      body: ValueListenableBuilder(
        valueListenable: stepHistoryBox.listenable(),
        builder: (context, box, widget) {
          // 1. Prepare data for the chart
          final List<BarChartGroupData> chartData = [];
          final today = DateTime.now();

          // 2. Loop backwards for the last 7 days
          for (int i = 6; i >= 0; i--) {
            final day = today.subtract(Duration(days: i));
            final dayKey = DateFormat('yyyy-MM-dd').format(day);

            // Get the steps from Hive. Default to 0 if no data exists.
            final steps = box.get(dayKey, defaultValue: 0);

            // Create a bar for the chart
            final bar = BarChartGroupData(
              x: 6 - i, // 0 = 6 days ago, 6 = today
              barRods: [
                BarChartRodData(
                  toY: steps.toDouble(), // The height of the bar
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

          // 3. Return the chart
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 20000, // TODO: Set this dynamically or to a high value
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.grey[800],
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        rod.toY.round().toString(),
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  // Bottom (X-axis) titles
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        // value is 0, 1, 2, 3, 4, 5, 6
                        String text = '';
                        final day = today.subtract(Duration(days: 6 - value.toInt()));
                        text = DateFormat('E').format(day); // e.g., "Mon"
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 4.0,
                          child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        );
                      },
                    ),
                  ),
                  // Left (Y-axis) titles
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 45,
                      getTitlesWidget: (value, meta) {
                        if (value % 5000 != 0 || value == 0) return Container();
                        return Text(
                          NumberFormat.compact().format(value), // e.g., "5k", "10k"
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                          textAlign: TextAlign.left,
                        );
                      },
                    ),
                  ),
                  // Hide top and right titles
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                // Hide grid and borders
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: chartData,
              ),
            ),
          );
        },
      ),
    );
  }
}