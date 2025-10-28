import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/services.dart';

import 'package:stride/main.dart'; 

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _goalController = TextEditingController();
  final _stepHistoryBox = Hive.box('stepHistory');
  final int _defaultGoal = 8000;
  String _message = '';

  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    final currentGoal = _stepHistoryBox.get('dailyGoal', defaultValue: _defaultGoal);
    _goalController.text = currentGoal.toString();
    _isDarkMode = _stepHistoryBox.get('isDarkMode', defaultValue: true); 
  }

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  void _saveGoal() {
    final newGoalString = _goalController.text.trim();
    final newGoal = int.tryParse(newGoalString);

    if (newGoal == null || newGoal <= 0) {
      setState(() {
        _message = 'Please enter a valid number greater than 0.';
      });
      return;
    }

    _stepHistoryBox.put('dailyGoal', newGoal);

    FocusScope.of(context).unfocus();
    setState(() {
      _message = 'Daily goal updated to $newGoal!';
    });
  }

  void _toggleTheme(bool value) {
    setState(() {
      _isDarkMode = value;
    });
    // Call the state management function in StrideApp to rebuild the UI
    StrideApp.of(context).setBrightness(value);
  }

  @override
  Widget build(BuildContext context) {
    // Removed unused 'bgColor' local variable
    final textColor = Theme.of(context).textTheme.headlineMedium!.color; 
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("SETTINGS"),
      ),
      body: SingleChildScrollView( 
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Theme Toggle Section ---
            Text(
              "Appearance",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                // Use theme brightness for background color decision
                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[900] : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isDarkMode ? "Dark Mode (Active)" : "Light Mode (Active)",
                    style: TextStyle(color: textColor, fontSize: 16),
                  ),
                  Switch(
                    value: _isDarkMode,
                    onChanged: _toggleTheme,
                    // FIX: Use activeThumbColor instead of deprecated activeColor
                    activeTrackColor: Theme.of(context).primaryColor.withOpacity(0.5),
                    activeThumbColor: Theme.of(context).primaryColor, 
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // --- Daily Step Goal Section ---
            Text(
              "Daily Step Goal",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _goalController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              style: TextStyle(color: textColor), 
              decoration: InputDecoration(
                hintText: 'e.g., 10000',
                hintStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color), 
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[900] : Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear, color: Theme.of(context).primaryColor),
                  onPressed: () => _goalController.clear(),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveGoal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor, 
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'SAVE GOAL',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 16, color: Colors.white), 
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_message.isNotEmpty)
              Text(
                _message,
                style: TextStyle(
                  color: _message.contains('updated') ? Theme.of(context).primaryColor : Colors.red, 
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }
}