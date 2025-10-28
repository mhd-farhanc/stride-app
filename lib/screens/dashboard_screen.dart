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
  String _kcal = "0";
  String _distanceKm = "0.0"; 
  final double _strideLengthMeters = 0.76; 
  int _dailyGoal = 8000; 
  double _percent = 0.0;
  int _currentStreak = 0;
  int _personalBestSteps = 0; 

  final _stepHistoryBox = Hive.box('stepHistory');

  @override
  void initState() {
    super.initState();
    _loadGoal(); 
    _loadPersonalBest(); 
    initPedometer();
    _calculateStreak(); 
  }

  void _loadPersonalBest() {
    setState(() {
      _personalBestSteps = _stepHistoryBox.get('personalBestSteps', defaultValue: 0);
    });
  }

  void _loadGoal() {
    setState(() {
      _dailyGoal = _stepHistoryBox.get('dailyGoal', defaultValue: 8000);
    });
    // Attach listener to update UI instantly when goal changes in Settings
    _stepHistoryBox.listenable(keys: ['dailyGoal']).addListener(_updateGoalFromSettings);
  }
  
  void _updateGoalFromSettings() {
    setState(() {
      _dailyGoal = _stepHistoryBox.get('dailyGoal', defaultValue: 8000);
      int currentSteps = int.tryParse(_steps) ?? 0;
      _percent = (currentSteps / _dailyGoal).clamp(0.0, 1.0); 
    });
    _calculateStreak(); 
  }

  @override
  void dispose() {
    _stepHistoryBox.listenable(keys: ['dailyGoal']).removeListener(_updateGoalFromSettings);
    super.dispose();
  }

  void _calculateStreak() {
    int streak = 0;
    final today = DateTime.now();

    for (int i = 1; i < 365; i++) {
      final day = today.subtract(Duration(days: i));
      final dayKey = DateFormat('yyyy-MM-dd').format(day);
      final steps = _stepHistoryBox.get(dayKey, defaultValue: -1);

      if (steps == -1) break;

      if (steps >= _dailyGoal) { 
        streak++;
      } else {
        break;
      }
    }

    final todayKey = DateFormat('yyyy-MM-dd').format(today);
    final todaySteps = _stepHistoryBox.get(todayKey, defaultValue: 0);

    if (todaySteps >= _dailyGoal) { 
      streak++;
    }

    setState(() {
      _currentStreak = streak;
    });
  }

  void initPedometer() async {
    var status = await Permission.activityRecognition.status;
    if (status.isDenied) {
      status = await Permission.activityRecognition.request();
    }

    if (status.isPermanentlyDenied) {
      print("Activity recognition permission is permanently denied.");
      setState(() { _steps = "No permission"; });
      return;
    }

    if (status.isGranted) {
      _stepCountStream = Pedometer.stepCountStream;
      _stepCountStream.listen(_onStepCount).onError(_onStepCountError);
    } else {
      print("Permission not granted.");
      setState(() { _steps = "No permission"; });
    }
  }

  void _onStepCount(StepCount event) {
    final String todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final String lastRunDate = _stepHistoryBox.get('lastRunDate', defaultValue: '');
    final int lastSensorTotal = _stepHistoryBox.get('lastSensorTotal', defaultValue: 0);

    int todayCalculatedSteps = _stepHistoryBox.get(todayKey, defaultValue: 0);
    int newSteps = 0;

    if (todayKey != lastRunDate) {
      todayCalculatedSteps = 0;
      newSteps = 0;
      _stepHistoryBox.put('lastSensorTotal', 0);
    } else {
      if (event.steps < lastSensorTotal && lastSensorTotal > 0) {
        newSteps = event.steps;
      } else {
        newSteps = event.steps - lastSensorTotal;
      }
    }

    if (newSteps < 0) newSteps = 0;

    int totalForDay = todayCalculatedSteps + newSteps;

    // --- Distance Calculation ---
    double calculatedDistanceKm = (totalForDay * _strideLengthMeters) / 1000;
    // --- Calories Calculation ---
    const double caloriesPerStep = 0.04;
    double calculatedKcal = totalForDay * caloriesPerStep;

    // --- Check for Personal Best ---
    if (totalForDay > _personalBestSteps) {
      _personalBestSteps = totalForDay;
      _stepHistoryBox.put('personalBestSteps', totalForDay);
    }

    setState(() {
      _steps = totalForDay.toString();
      _percent = (totalForDay / _dailyGoal).clamp(0.0, 1.0); 
      _kcal = calculatedKcal.toStringAsFixed(0);
      _distanceKm = calculatedDistanceKm.toStringAsFixed(2);
    });

    _stepHistoryBox.put('lastRunDate', todayKey);
    _stepHistoryBox.put('lastSensorTotal', event.steps);
    _stepHistoryBox.put(todayKey, totalForDay);
    _stepHistoryBox.put("${todayKey}_kcal", calculatedKcal);
    
    _calculateStreak();
  }

  void _onStepCountError(error) {
    print("Pedometer Error: $error");
    setState(() {
      _steps = "N/A";
    });
  }
  
  // --- NEW: Mascot Logic ---
  String _getMascotEmoji() {
    if (_percent >= 1.0) {
      return "🎉"; // Goal Met: Celebrating
    } else if (_percent >= 0.75) {
      return "🏃"; // High Progress: Running
    } else if (_percent >= 0.50) {
      return "🚶"; // Halfway: Walking steadily
    } else if (_percent >= 0.10) {
      return "🤔"; // Starting: Thinking about movement
    } else {
      return "😴"; // Low Progress: Sleeping/Idle
    }
  }
  // -------------------------

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final today = DateFormat('MMMM d').format(DateTime.now()).toUpperCase();

    return Scaffold(
      appBar: AppBar(
        title: Text(today),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showAboutDialog(context);
            },
            tooltip: 'About',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildProgressRing(textTheme),
              
              Column(
                children: [
                  _buildHighlightRow(textTheme), 
                  const SizedBox(height: 24),
                  _buildCoreStatsRow(textTheme), 
                ],
              ),
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
          // --- Mascot Display (1st Item) ---
          Text(
            _getMascotEmoji(),
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(height: 4),
          // ---------------------------------
          // --- Step Count (2nd Item) ---
          Text(
            _steps,
            style: textTheme.displayLarge?.copyWith(fontSize: 64),
          ),
          // --- "Steps" Label (3rd Item) ---
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

  // --- Highlight Row (2 items: PB and Distance) ---
  Widget _buildHighlightRow(TextTheme textTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: _buildStatCard( 
            "PB",
            "🏅 ${NumberFormat.compact().format(_personalBestSteps)}",
            textTheme,
            large: true, 
          ),
        ),
        Expanded(
          child: _buildStatCard( 
            "DISTANCE",
            "👟 $_distanceKm km", 
            textTheme,
            large: true, 
          ),
        ),
      ],
    );
  }
  // --- Core Stats Row (3 items: Goal, Streak, Kcal) ---
  Widget _buildCoreStatsRow(TextTheme textTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatCard(
          "GOAL",
          NumberFormat.compact().format(_dailyGoal), 
          textTheme,
        ),
        _buildStatCard(
          "STREAK",
          "🔥 ${_currentStreak.toString()}",
          textTheme,
        ),
        _buildStatCard( 
          "KCAL",
          _kcal,
          textTheme,
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, TextTheme textTheme, {bool large = false}) {
    return Column(
      children: [
        Text(
          value,
          style: textTheme.labelLarge?.copyWith(fontSize: large ? 32 : 24, letterSpacing: large ? -0.5 : 0),
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

  void _showAboutDialog(BuildContext context) {
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