# Stride: Step Tracker & Calorie Counter 🏃‍♂️

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/github/license/mhd-farhanc/stride-app?style=for-the-badge" alt="License" />
  <img src="https://img.shields.io/github/stars/mhd-farhanc/stride-app?style=for-the-badge" alt="Stars" />
</p>

<p align="center">
  A feature-rich open-source step tracker built with Flutter. Dynamic goals, dark/light theme, a cute mascot, and a 30-day history chart — with all data kept private on your device.
</p>

---

## ✨ Features

- **Live Step Counting** — Real-time tracking using your phone's built-in sensors.
- **Dynamic Goal Setting** — Set your own daily step goal — no hardcoded defaults.
- **Calorie Counter** — Estimate calories burned based on your step count.
- **Daily Goal Ring** — Circular progress bar visualizing your daily goal.
- **30-Day History** — Bar chart (powered by `fl_chart`) showing your daily steps over the last 30 days.
- **Midnight Auto-Reset** — Step count automatically resets to 0 every day at midnight.
- **Dark & Light Themes** — Toggle between dark and light modes to suit your preference.
- **Mascot** — A friendly companion that reacts to your progress throughout the day.
- **Privacy-First** — All step data is stored 100% on-device with Hive. Nothing is uploaded.
- **Clean UI** — Minimalist, distraction-free design with a restructured dashboard.

## 🛠️ Tech Stack

Built with Flutter and Dart, using these key packages:

| Package | Purpose |
|---|---|
| `pedometer` | Access the phone's step sensor |
| `hive` & `hive_flutter` | Fast, on-device local storage |
| `fl_chart` | 30-day history bar chart |
| `permission_handler` | Request "Physical Activity" permission |
| `share_plus` | Share your progress with friends |
| `url_launcher` | Open links (GitHub profile, etc.) |

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (see [flutter.dev](https://flutter.dev))
- Dart SDK (bundled with Flutter)

### Run the app
```bash
flutter pub get
flutter run
```

### Windows build (optional)
A VS Code C/C++ IntelliSense config is included at `.vscode/c_cpp_properties.json` for contributors building on Windows.

## 🤝 How to Contribute

This is an open-source project! Fork the repository and submit a pull request. Ideas:

- Streaks & achievements
- Weekly/monthly reports
- Wear OS support
- Improved accessibility
- Bug fixes and UI polish

## 📄 License

This project is open source. Feel free to use the code as you wish.
