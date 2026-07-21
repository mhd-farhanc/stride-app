/// App-wide constants for Stride step tracker.

// --- Physical Constants ---
const double strideLengthMeters = 0.76;
const double caloriesPerStep = 0.04;

// --- Defaults ---
const int defaultDailyGoal = 8000;
const int maxStreakDays = 365;
const int weeklyGoalMultiplier = 7;

// --- Hive Keys ---
const String kStepHistoryBox = 'stepHistory';
const String kDailyGoal = 'dailyGoal';
const String kIsDarkMode = 'isDarkMode';
const String kLastSensorTotal = 'lastSensorTotal';
const String kLastRunDate = 'lastRunDate';
const String kPersonalBestSteps = 'personalBestSteps';
const String kRemindersEnabled = 'remindersEnabled';
const String kDailyNotificationTime = 'dailyNotificationTime';
const String kCelebratedToday = 'celebratedToday';
const String kAchievements = 'achievements';
const String kTotalLifetimeSteps = 'totalLifetimeSteps';
const String kWorkoutLogs = 'workoutLogs';

// --- Step Constants ---
const int debounceDurationMs = 3000;
const int inactivityReminderMinutes = 60;
const int sensorErrorRetryCount = 3;
const int sensorErrorRetryDelayMs = 10000;

// --- Achievement Thresholds ---
const int achievementFirstSteps = 1000;
const int achievement10K = 10000;
const int achievementMarathon = 42000;
const int achievementCentury = 100000;
const int achievementWeekStreak = 7;
const int achievementMonthStreak = 30;

// --- Mascot Levels ---
const int mascotLevel2 = 1000;
const int mascotLevel3 = 10000;
const int mascotLevel4 = 50000;
const int mascotLevel5 = 100000;
const int mascotLevel6 = 500000;
