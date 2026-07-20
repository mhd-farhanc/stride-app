# Stride: A Minimalist Step Tracker 🏃‍♂️

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/github/license/mhd-farhanc/stride-app?style=for-the-badge" alt="License" />
</p>

<p align="center">
  A beautiful, minimalist open-source pedometer built with Flutter. Stark red, black, and white theme, a daily goal ring, and a 7-day history chart — with all data kept private on your device.
</p>

---

## ✨ Features

- **Live Step Counting** — Real-time tracking using your phone's built-in sensors.
- **Daily Goal Ring** — Circular progress bar visualizing your daily goal (default 8,000 steps).
- **24-Hour Reset** — Step count automatically resets to 0 every day at midnight.
- **7-Day History** — A clean bar chart (powered by `fl_chart`) showing your daily steps for the last week.
- **Privacy-First** — All step data is stored 100% on-device with Hive. Nothing is uploaded.
- **Minimalist UI** — A distraction-free "Nothing" theme (red, black, white).
- **About Page** — Links to the developer's GitHub profile.

## 🛠️ Tech Stack

Built with Flutter and Dart, using these key packages:

- **Hardware:** `pedometer` — access the phone's step sensor.
- **Local Database:** `hive` & `hive_flutter` — fast, on-device storage.
- **UI & Charts:** `fl_chart` — the 7-day history bar graph.
- **Permissions:** `permission_handler` — request "Physical Activity" permission.
- **Utils:** `url_launcher` — open the GitHub link.

## 🤝 How to Contribute

This is an open-source project! Fork the repository and submit a pull request. You can help by:

- Adding new features (streaks, calorie counting, etc.)
- Improving the UI
- Fixing bugs

## 📄 License

This project is open source. Feel free to use the code as you wish.
