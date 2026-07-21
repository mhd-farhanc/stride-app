import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';

import 'package:stride/providers/step_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _celebrationController;
  late Animation<double> _celebrationAnimation;
  bool _showCelebration = false;

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _celebrationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _celebrationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }

  void _checkForCelebration(StepProvider provider) {
    if (provider.goalJustReached) {
      HapticFeedback.heavyImpact();
      setState(() => _showCelebration = true);
      _celebrationController.forward().then((_) {
        setState(() => _showCelebration = false);
        _celebrationController.reset();
      });
      provider.clearGoalReached();
    }
  }

  Future<void> _shareStats(StepProvider provider) async {
    final stats = provider.stats;
    final text =
        'I walked ${stats.currentSteps} steps '
        '(${stats.distanceKm.toStringAsFixed(2)} km, '
        '${stats.kcal.toStringAsFixed(0)} kcal) '
        'today with Stride! 🚶';
    await Share.share(
      text,
      sharePositionOrigin: const Rect.fromLTWH(0, 0, 100, 100),
    );
  }

  void _showAboutDialog(BuildContext context) {
    const githubUrl = 'https://github.com/mhd-farhanc';

    showDialog(
      context: context,
      builder: (ctx) {
        final isDarkDialog = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDarkDialog ? Colors.grey[900] : Colors.white,
          title: Text(
            'About Stride',
            style: TextStyle(
              color: isDarkDialog ? Colors.white : Colors.black87,
            ),
          ),
          content: RichText(
            text: TextSpan(
              style: TextStyle(
                color: isDarkDialog ? Colors.white70 : Colors.black87,
                height: 1.5,
              ),
              children: [
                const TextSpan(text: 'Developed by Muhammad Farhan C.\n\n'),
                const TextSpan(
                  text: 'View the project or my other work on\n',
                ),
                TextSpan(
                  text: 'GitHub',
                  style: TextStyle(
                    color: Colors.red.shade400,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      final uri = Uri.parse(githubUrl);
                      if (!await launchUrl(uri)) {
                        debugPrint('Could not launch $githubUrl');
                      }
                    },
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Close',
                  style: TextStyle(color: Colors.red.shade400)),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final today = DateFormat('MMMM d').format(DateTime.now()).toUpperCase();
    final stepProvider = context.watch<StepProvider>();

    // Trigger celebration if goal just reached
    _checkForCelebration(stepProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(today),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareStats(stepProvider),
            tooltip: 'Share stats',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showAboutDialog(context),
            tooltip: 'About',
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildProgressRing(textTheme, stepProvider),
                  Column(
                    children: [
                      _buildWeeklyProgress(textTheme, stepProvider),
                      const SizedBox(height: 16),
                      _buildHighlightRow(textTheme, stepProvider),
                      const SizedBox(height: 16),
                      _buildCoreStatsRow(textTheme, stepProvider),
                      if (stepProvider.isWorkoutActive)
                        _buildWorkoutCard(textTheme, stepProvider),
                    ],
                  ),
                ],
              ),
            ),
            // Celebration overlay
            if (_showCelebration)
              FadeTransition(
                opacity: _celebrationAnimation,
                child: IgnorePointer(
                  child: Container(
                    color: Colors.transparent,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '🎉',
                            style: TextStyle(
                              fontSize: 72 + 48 * _celebrationAnimation.value,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'GOAL REACHED!',
                            style: textTheme.displayLarge?.copyWith(
                              fontSize: 28,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressRing(
    TextTheme textTheme,
    StepProvider provider,
  ) {
    final stats = provider.stats;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            CircularPercentIndicator(
              radius: 125.0,
              lineWidth: 16.0,
              percent: stats.percent,
              animateFromLastPercent: true,
              animation: true,
              animationDuration: 1000,
              center: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${provider.mascotLevelEmoji}${provider.mascotDailyEmoji}',
                    style: const TextStyle(fontSize: 28),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stats.currentSteps.toString(),
                    style: textTheme.displayLarge
                        ?.copyWith(fontSize: 64),
                  ),
                  Text(
                    'Steps',
                    style: textTheme.headlineMedium
                        ?.copyWith(color: isDarkMode ? Colors.white54 : Colors.black45),
                  ),
                ],
              ),
              progressColor: Theme.of(context).primaryColor,
              backgroundColor:
                  isDarkMode ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.06),
              circularStrokeCap: CircularStrokeCap.round,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeeklyProgress(
    TextTheme textTheme,
    StepProvider provider,
  ) {
    final weeklyGoal = provider.dailyGoal * 7;
    final weeklyPercent =
        weeklyGoal > 0 ? (provider.weeklyTotal / weeklyGoal).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.05),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'WEEKLY PROGRESS',
                style: textTheme.bodyMedium?.copyWith(
                  letterSpacing: 1.1,
                  fontSize: 12,
                ),
              ),
              Text(
                '${NumberFormat.compact().format(provider.weeklyTotal)} / ${NumberFormat.compact().format(weeklyGoal)}',
                style: textTheme.labelLarge?.copyWith(fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: weeklyPercent,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(
                Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightRow(
    TextTheme textTheme,
    StepProvider provider,
  ) {
    final stats = provider.stats;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: _buildStatCard(
            'PB',
            '🏅 ${NumberFormat.compact().format(stats.personalBestSteps)}',
            textTheme,
            large: true,
          ),
        ),
        Expanded(
          child: _buildStatCard(
            'DISTANCE',
            '👟 ${stats.distanceKm.toStringAsFixed(2)} km',
            textTheme,
            large: true,
          ),
        ),
      ],
    );
  }

  Widget _buildCoreStatsRow(
    TextTheme textTheme,
    StepProvider provider,
  ) {
    final stats = provider.stats;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatCard(
          'GOAL',
          NumberFormat.compact().format(stats.dailyGoal),
          textTheme,
        ),
        _buildStatCard(
          'STREAK',
          '🔥 ${stats.streak.toString()}',
          textTheme,
        ),
        _buildStatCard(
          'KCAL',
          stats.kcal.toStringAsFixed(0),
          textTheme,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    TextTheme textTheme, {
    bool large = false,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Text(
          value,
          style: textTheme.labelLarge?.copyWith(
            fontSize: large ? 28 : 22,
            letterSpacing: large ? -0.5 : 0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: textTheme.bodyMedium?.copyWith(
            color: isDarkMode ? Colors.white54 : Colors.black45,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutCard(
    TextTheme textTheme,
    StepProvider provider,
  ) {
    final duration = provider.workoutDuration;
    final minutes = duration?.inMinutes ?? 0;
    final seconds = (duration?.inSeconds ?? 0) % 60;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
        border: Border.all(
          color: Theme.of(context).primaryColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'WORKOUT ACTIVE',
                style: textTheme.labelLarge?.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                style: textTheme.displayLarge?.copyWith(fontSize: 28),
              ),
              Text(
                '${provider.workoutSteps} steps',
                style: textTheme.bodyMedium,
              ),
            ],
          ),
          ElevatedButton(
            onPressed: provider.endWorkout,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
            ),
            child: const Text('END'),
          ),
        ],
      ),
    );
  }
}
