import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:stride/providers/step_provider.dart';
import 'package:stride/providers/theme_provider.dart';
import 'package:stride/screens/badges_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _goalController = TextEditingController();
  String _message = '';

  @override
  void initState() {
    super.initState();
    // Delay reading provider to avoid accessing during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final goal = context.read<StepProvider>().dailyGoal;
      _goalController.text = goal.toString();
    });
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
      setState(() => _message = 'Please enter a valid number greater than 0.');
      return;
    }

    context.read<StepProvider>().updateGoal(newGoal);
    FocusScope.of(context).unfocus();
    setState(() => _message = 'Daily goal updated to $newGoal!');
  }

  @override
  Widget build(BuildContext context) {
    final stepProvider = context.watch<StepProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final textColor =
        Theme.of(context).textTheme.headlineMedium?.color ?? Colors.white;
    final bgColor = isDark ? Colors.grey[900] : Colors.grey[200];

    return Scaffold(
      appBar: AppBar(
        title: const Text('SETTINGS'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Achievements ──────────────────────────────
            Text(
              'Badges',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            _buildBadgesPreview(context),
            const SizedBox(height: 32),

            // ─── Appearance ────────────────────────────────
            Text(
              'Appearance',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isDark ? 'Dark Mode (Active)' : 'Light Mode (Active)',
                    style: TextStyle(color: textColor, fontSize: 16),
                  ),
                  Switch(
                    value: isDark,
                    onChanged: (v) => themeProvider.setDarkMode(v),
                    activeTrackColor:
                        Theme.of(context).primaryColor.withValues(alpha: 0.5),
                    activeThumbColor: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ─── Daily Step Goal ───────────────────────────
            Text(
              'Daily Step Goal',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _goalController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: 'e.g., 10000',
                hintStyle: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium!.color,
                ),
                filled: true,
                fillColor: bgColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Theme.of(context).primaryColor,
                  ),
                  onPressed: () => _goalController.clear(),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ─── Goal Suggestion ───────────────────────────
            _buildGoalSuggestion(stepProvider),
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
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_message.isNotEmpty)
              Text(
                _message,
                style: TextStyle(
                  color: _message.contains('updated')
                      ? Theme.of(context).primaryColor
                      : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            const SizedBox(height: 32),

            // ─── Reminders ─────────────────────────────────
            Text(
              'Reminders',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Inactivity Reminder',
                          style:
                              TextStyle(color: textColor, fontSize: 16),
                        ),
                        Text(
                          'Get a nudge after 60 min of inactivity',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white54
                                : Colors.black54,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: stepProvider.remindersEnabled,
                    onChanged: (v) => stepProvider.setRemindersEnabled(v),
                    activeTrackColor: Theme.of(context)
                        .primaryColor
                        .withValues(alpha: 0.5),
                    activeThumbColor: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ─── Workout ───────────────────────────────────
            Text(
              'Quick Workout',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: stepProvider.isWorkoutActive
                    ? stepProvider.endWorkout
                    : stepProvider.startWorkout,
                icon: Icon(
                  stepProvider.isWorkoutActive
                      ? Icons.stop
                      : Icons.directions_walk,
                ),
                label: Text(
                  stepProvider.isWorkoutActive
                      ? 'END WORKOUT'
                      : 'START WORKOUT',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      stepProvider.isWorkoutActive
                          ? Colors.red
                          : Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgesPreview(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const BadgesScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[900]
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
                child: Text(
                  'View your achievement badges',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.headlineMedium?.color ?? Colors.white,
                    fontSize: 16,
                  ),
                ),
            ),
            const Icon(Icons.emoji_events, size: 32),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalSuggestion(StepProvider provider) {
    final suggested = provider.getSuggestedGoal();
    if (suggested == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Based on your weekly average, try $suggested steps!',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium!.color,
                fontSize: 14,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              _goalController.text = suggested.toString();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}
