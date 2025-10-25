// lib/screens/dashboard_screen.dart
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pedometer/pedometer.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Stream<StepCount> _stepCountStream;
  String _steps = "0";
  final int _dailyGoal = 8000;
  double _percent = 0.0;

  // Hive database box
  final _stepHistoryBox = Hive.box('stepHistory');

  @override
  void initState() {
    super.initState();
    initPedometer();
  }

  void initPedometer() async {
    // Check if permission is granted
    var status = await Permission.activityRecognition.status;
    if (status.isDenied) {
      // If denied, request permission
      status = await Permission.activityRecognition.request();
    }

    // If permission is permanently denied, we can't do anything
    if (status.isPermanentlyDenied) {
      print("Activity recognition permission is permanently denied.");
      setState(() {
        _steps = "No permission";
      });
      return; // Exit the function
    }

    // If permission is granted, start the stream
    if (status.isGranted) {
      _stepCountStream = Pedometer.stepCountStream;
      _stepCountStream.listen(_onStepCount).onError(_onStepCountError);
    } else {
      print("Permission not granted.");
      setState(() {
        _steps = "No permission";
      });
    }
  }

  void _onStepCount(StepCount event) {
    // 1. Get today's date key
    final String todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // 2. Get stored data from Hive
    final String lastRunDate =
        _stepHistoryBox.get('lastRunDate', defaultValue: '');
    final int lastSensorTotal =
        _stepHistoryBox.get('lastSensorTotal', defaultValue: 0);

    // Get the steps we've already counted for today
    int todayCalculatedSteps = _stepHistoryBox.get(todayKey, defaultValue: 0);
    int newSteps = 0;

    // 3. Check if it's a new day
    if (todayKey != lastRunDate) {
      // It's a new day! Reset the daily count.
      todayCalculatedSteps = 0;
      newSteps = 0;
      // We also clear the previous day's sensor total to start fresh
      _stepHistoryBox.put('lastSensorTotal', 0);
    } else {
      // It's the same day.
      // 4. Check if the phone rebooted (sensor count is less than last time)
      if (event.steps < lastSensorTotal && lastSensorTotal > 0) {
        // Phone rebooted. The new steps are just the sensor's new count.
        newSteps = event.steps;
      } else {
        // Normal case: calculate steps taken since the last update
        newSteps = event.steps - lastSensorTotal;
      }
    }

    // Ensure we don't get negative steps if the sensor is weird
    if (newSteps < 0) newSteps = 0;

    // 5. Calculate the total steps for the day
    int totalForDay = todayCalculatedSteps + newSteps;

    // 6. Update the UI
    setState(() {
      _steps = totalForDay.toString();
      _percent = (totalForDay / _dailyGoal).clamp(0.0, 1.0);
    });

    // 7. Save the new state for the next event
    _stepHistoryBox.put('lastRunDate', todayKey); // Save the date we last ran
    _stepHistoryBox.put(
        'lastSensorTotal', event.steps); // Save the latest raw sensor value
    _stepHistoryBox.put(todayKey, totalForDay); // Save the day's total
  }

  void _onStepCountError(error) {
    print("Pedometer Error: $error");
    setState(() {
      _steps = "N/A";
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final today = DateFormat('MMMM d').format(DateTime.now()).toUpperCase();

    return Scaffold(
      appBar: AppBar(
        title: Text(today),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline), // Adds an "info" icon
            onPressed: () {
              _showAboutDialog(context); // Calls the new function
            },
            tooltip: 'About',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          // This is the corrected Column for layout
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildProgressRing(textTheme),
              _buildStatsRow(textTheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressRing(TextTheme textTheme) {
    return CircularPercentIndicator(
      radius: 125.0,
      lineWidth: 16.0,
      percent: _percent,
      animateFromLastPercent: true,
      animation: true,
      animationDuration: 1000,
      center: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _steps,
            style: textTheme.displayLarge?.copyWith(fontSize: 64),
          ),
          Text(
            "Steps",
            style: textTheme.headlineMedium?.copyWith(color: Colors.white54),
          ),
        ],
      ),
      progressColor: Theme.of(context).primaryColor,
      backgroundColor: Colors.white.withAlpha((255 * 0.15).round()),
      circularStrokeCap: CircularStrokeCap.round,
    );
  }

  Widget _buildStatsRow(TextTheme textTheme) {
    String streak = "0";
    String kcal = "0";

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatCard(
          "Goal",
          NumberFormat.compact().format(_dailyGoal),
          textTheme,
        ),
        _buildStatCard(
          "Streak",
          "🔥 $streak",
          textTheme,
        ),
        _buildStatCard(
          "Kcal",
          kcal,
          textTheme,
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, TextTheme textTheme) {
    return Column(
      children: [
        Text(
          value,
          style: textTheme.labelLarge?.copyWith(fontSize: 24),
        ),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: textTheme.bodyMedium
              ?.copyWith(color: Colors.white54, letterSpacing: 1.1),
        ),
      ],
    );
  }

  // This is the "About" dialog function
  void _showAboutDialog(BuildContext context) {
    // TODO: Replace with your GitHub URL
    final String githubUrl = "https://github.com/mhd-farhanc";

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'About Stride',
            style: TextStyle(color: Colors.white),
          ),
          content: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.white70, height: 1.5),
              children: [
                const TextSpan(text: 'Developed by Muhammad Farhan C.\n\n'),
                const TextSpan(text: 'View the project or my other work on\n'),
                TextSpan(
                  text: 'GitHub',
                  style: TextStyle(
                    color: Colors.red.shade400,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      // Launch the URL
                      final Uri url = Uri.parse(githubUrl);
                      if (!await launchUrl(url)) {
                        print('Could not launch $url');
                      }
                    },
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Close', style: TextStyle(color: Colors.red.shade400)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}