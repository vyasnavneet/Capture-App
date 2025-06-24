import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keep/screens/note_editor_screen.dart';
import 'package:provider/provider.dart';
import 'providers/notes_provider.dart';
import 'screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(Capture());
}

class Capture extends StatefulWidget {
  const Capture({super.key});

  @override
  CaptureState createState() => CaptureState();
}

class CaptureState extends State<Capture> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    loadThemePreference();
  }

  void loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? false;

    setState(() {
      _isDarkMode = isDark;

      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          systemNavigationBarColor: _isDarkMode ? Colors.black : Colors.white,
          systemNavigationBarIconBrightness:
              _isDarkMode ? Brightness.light : Brightness.dark,
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              _isDarkMode ? Brightness.light : Brightness.dark,
        ),
      );
    });
  }

  void handleSharedText(BuildContext context, String? sharedText) {
    if (sharedText != null && sharedText.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => NoteEditorScreen(initialContent: sharedText),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => NotesProvider(),
      child: MaterialApp(
        routes: {'/editor': (context) => const NoteEditorScreen()},
        builder: (context, child) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            MethodChannel(
              'com.example.keep/sharing',
            ).invokeMethod('getSharedText').then((sharedText) {
              if (sharedText != null && sharedText.isNotEmpty) {
                handleSharedText(context, sharedText);
              }
            });
          });
          return child!;
        },
        debugShowCheckedModeBanner: false,
        title: 'Capture!',
        theme:
            _isDarkMode
                ? ThemeData(
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: const Color.fromARGB(255, 255, 213, 79),
                    brightness: Brightness.dark,
                  ),
                  scaffoldBackgroundColor: Colors.black,
                  appBarTheme: const AppBarTheme(
                    backgroundColor: Colors.black,
                    iconTheme: IconThemeData(color: Colors.white),
                    elevation: 0,
                  ),
                )
                : ThemeData(
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: const Color.fromARGB(255, 255, 213, 79),
                    brightness: Brightness.light,
                  ),
                  scaffoldBackgroundColor: Colors.white,
                  appBarTheme: const AppBarTheme(
                    backgroundColor: Colors.white,
                    iconTheme: IconThemeData(color: Colors.black),
                    elevation: 0,
                  ),
                ),
        home: HomeScreen(changeTheme: loadThemePreference),
        themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      ),
    );
  }
}
