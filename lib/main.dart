import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Project Manager',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF8F8FA),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6A3DE8)),
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
