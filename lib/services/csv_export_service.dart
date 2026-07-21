import 'dart:io';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:stride/services/step_repository.dart';
import 'package:stride/constants.dart';

/// Generates CSV exports of step history.
class CsvExportService {
  final StepRepository _repository;

  CsvExportService(this._repository);

  /// Export steps for the last [days] days to a CSV file.
  /// Returns the file path (or CSV content on web).
  Future<String> exportToCsv({int days = 30}) async {
    final data = <List<dynamic>>[
      ['Date', 'Steps', 'Calories', 'Distance (km)', 'Goal Met'],
    ];

    final today = DateTime.now();
    for (int i = days - 1; i >= 0; i--) {
      final day = today.subtract(Duration(days: i));
      final steps = _repository.getStepsForDate(day);
      final goal = _repository.getDailyGoal();
      final calories = steps * caloriesPerStep;
      final distanceKm = (steps * strideLengthMeters) / 1000;

      data.add([
        DateFormat('yyyy-MM-dd').format(day),
        steps,
        calories.toStringAsFixed(0),
        distanceKm.toStringAsFixed(2),
        steps >= goal ? 'Yes' : 'No',
      ]);
    }

    final csvString = const ListToCsvConverter().convert(data);

    if (kIsWeb) {
      return csvString;
    }

    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/stride_export_${DateFormat('yyyyMMdd').format(today)}.csv',
    );
    await file.writeAsString(csvString);

    return file.path;
  }
}
