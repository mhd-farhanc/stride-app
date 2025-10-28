import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:stride/screens/dashboard_screen.dart';
import 'package:stride/screens/history_screen.dart';
import 'package:stride/screens/settings_screen.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('stepHistory');
  runApp(const StrideApp());
}

// Global variable to hold the theme box
final themeBox = Hive.box('stepHistory');


// --- MainNavigator Definition (Moved to top to fix L47 error) ---
class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _selectedIndex = 0;

  static final List<Widget> _screens = <Widget>[
    DashboardScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
// --- End MainNavigator Definition ---


// Convert StrideApp to StatefulWidget to manage theme state
class StrideApp extends StatefulWidget {
  const StrideApp({super.key});

  // Helper method to access the state from anywhere (made public)
  static StrideAppState of(BuildContext context) => context.findAncestorStateOfType<StrideAppState>()!;

  @override
  State<StrideApp> createState() => StrideAppState(); // Using public state name
}

class StrideAppState extends State<StrideApp> { // State class is now public
  // Read the initial theme preference from Hive
  bool get isDarkMode => themeBox.get('isDarkMode', defaultValue: true);

  // Method called by the Settings screen to change the theme
  void setBrightness(bool value) {
    themeBox.put('isDarkMode', value);
    setState(() {}); // Rebuild the entire app with the new theme
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stride',
      debugShowCheckedModeBanner: false,
      theme: _buildLightStrideTheme(),
      darkTheme: _buildDarkStrideTheme(), // Dark theme is generally the primary
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light, // Control theme mode
      home: const MainNavigator(),
    );
  }

  // --- Dark Theme Definition ---
  ThemeData _buildDarkStrideTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.black, // BLACK
      primaryColor: Colors.red.shade700,     // RED ACCENT
      
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
        bodyMedium: TextStyle(color: Colors.white70),
        labelLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.red.shade700,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
    );
  }

  // --- Light Theme Definition ---
  ThemeData _buildLightStrideTheme() {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white, // WHITE
      primaryColor: Colors.red.shade600,     // RED ACCENT (slightly softer)
      
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: Colors.black54, fontWeight: FontWeight.w300),
        bodyMedium: TextStyle(color: Colors.black87),
        labelLarge: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 1, 
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black), 
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.red.shade600,
        unselectedItemColor: Colors.black54,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
    );
  }
}