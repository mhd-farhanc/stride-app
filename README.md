# Stride: A Minimalist Step Tracker 🏃‍♂️
Stride is a beautiful and minimalist open-source pedometer. Built with Flutter, this app features a stark red, black, and white theme. Watch your progress fill the ring as you walk, and review your accomplishments on a 7-day history chart. The step count resets daily, keeping all data private on your device.

(Note: You'll need to upload this screenshot to your GitHub repo and update the path)

✨ Features
Live Step Counting: Real-time step tracking using your phone's built-in sensors.

Daily Goal Ring: A circular progress bar to visualize your daily goal (default 8,000 steps).

24-Hour Reset: The step count automatically resets to 0 every day at midnight.

7-Day History: A beautiful bar chart (powered by fl_chart) to see your daily steps from the last week.

Privacy-First: All your step data is stored 100% on your device using Hive. Nothing is uploaded to a server.

Minimalist UI: A clean, distraction-free "Nothing" theme (red, black, white).

About Page: Links to the developer's GitHub profile.

🛠️ Tech Stack
This project is built with Flutter and Dart, using several key packages:

Hardware: pedometer for accessing the phone's step sensor.

Local Database: hive & hive_flutter for fast, on-device data storage.

UI & Charts: fl_chart for the 7-day history bar graph.

Permissions: permission_handler to request "Physical Activity" permission.

Utils: url_launcher to open the GitHub link.

🤝 How to Contribute
This is an open-source project! If you'd like to contribute, please feel free to fork the repository and submit a pull request. You can help by:

Adding new features (like streaks or calorie counting).

Improving the UI.

Fixing bugs.

📄 License
This project is open-source. Feel free to use the code as you wish.
