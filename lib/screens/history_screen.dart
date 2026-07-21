import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math' show max;
import 'package:share_plus/share_plus.dart';

import 'package:stride/providers/step_provider.dart';

/// History screen with 7-day, 30-day, and yearly views plus CSV export.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedPeriod = '7D';

  String _getTitle() {
    switch (_selectedPeriod) {
      case '7D':
        return 'THIS WEEK';
      case '30D':
        return 'THIS MONTH';
      case 'YEAR':
        return 'THIS YEAR';
      default:
        return 'HISTORY';
    }
  }

  Future<void> _exportCsv() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final provider = context.read<StepProvider>();
      final days = _selectedPeriod == 'YEAR' ? 365 : (_selectedPeriod == '30D' ? 30 : 7);
      final path = await provider.exportCsv(days: days);
      await Share.shareXFiles(
        [XFile(path)],
        text: 'Stride step history',
        sharePositionOrigin: const Rect.fromLTWH(0, 0, 100, 100),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final stepProvider = context.watch<StepProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            onPressed: _exportCsv,
            tooltip: 'Export CSV',
          ),
        ],
      ),
      body: _buildChart(context, stepProvider),
    );
  }

  Widget _buildChart(BuildContext context, StepProvider stepProvider) {
    final accentColor = Theme.of(context).primaryColor;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final chartTextColor = isDarkMode ? Colors.white70 : Colors.black54;
    final chartBorderColor = isDarkMode ? Colors.white12 : Colors.black12;

    final Map<String, int> data;
    final bool isMonthlyView;
    final bool isThirtyDayView;
    if (_selectedPeriod == 'YEAR') {
      data = stepProvider.getHistoryForYear(DateTime.now().year);
      isMonthlyView = true;
      isThirtyDayView = false;
    } else {
      final days = _selectedPeriod == '30D' ? 30 : 7;
      data = stepProvider.getHistoryForRange(days);
      isMonthlyView = false;
      isThirtyDayView = days == 30;
    }

    final chartData = <BarChartGroupData>[];
    int maxSteps = 0;
    final today = DateTime.now();

    final entries = data.entries.toList();
    for (int i = 0; i < entries.length; i++) {
      maxSteps = max(maxSteps, entries[i].value);
      chartData.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: entries[i].value.toDouble(),
              color: accentColor,
              width: 20,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
          ],
        ),
      );
    }

    if (chartData.isEmpty) {
      return const Center(child: Text('No data yet. Save some steps!'));
    }

    final double maxY = max(10000.0, (maxSteps / 5000).ceil() * 5000.0);

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPeriodChip(context, '7D'),
              const SizedBox(width: 8),
              _buildPeriodChip(context, '30D'),
              const SizedBox(width: 8),
              _buildPeriodChip(context, 'YEAR'),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: chartBorderColor, width: 1.0),
                ),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor:
                        isDarkMode ? Colors.grey[800] : Colors.grey[200],
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        rod.toY.round().toString(),
                        TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= entries.length) {
                          return Container();
                        }
                        String label;
                        if (isMonthlyView) {
                          final monthNames = [
                            '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                            'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
                          ];
                          final monthIdx = int.tryParse(entries[idx].key) ?? 0;
                          label = monthIdx > 0 && monthIdx <= 12
                              ? monthNames[monthIdx]
                              : entries[idx].key;
                        } else if (isThirtyDayView) {
                          if (idx % 7 == 0 && idx < 28) {
                            label = 'Week ${(idx ~/ 7) + 1}';
                          } else {
                            return Container();
                          }
                        } else {
                          final day = today.subtract(Duration(days: entries.length - 1 - idx));
                          label = DateFormat('E').format(day);
                        }
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 4.0,
                          child: Text(
                            label,
                            style: TextStyle(
                              color: chartTextColor,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 45,
                      getTitlesWidget: (value, meta) {
                        final interval =
                            maxY > 10000 ? 5000.0 : (maxY / 2);
                        if (value % interval != 0 || value == 0) {
                          return Container();
                        }
                        return Text(
                          NumberFormat.compact().format(value),
                          style: TextStyle(
                            color: chartTextColor,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.left,
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: chartBorderColor,
                    strokeWidth: 1,
                  ),
                ),
                barGroups: chartData,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(
    BuildContext context,
    String label,
  ) {
    final selected = _selectedPeriod == label;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).primaryColor
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? Theme.of(context).primaryColor
                : isDarkMode ? Colors.white24 : Colors.black26,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? Colors.white
                : isDarkMode ? Colors.white54 : Colors.black54,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
