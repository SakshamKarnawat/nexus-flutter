import 'package:flutter/material.dart';
import 'package:nexus/core/constants/constants.dart';
import 'package:nexus/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: kAppName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: Pallete.whiteColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: Pallete.whiteColor,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
            fontFamily: 'Cera Pro',
            fontSize: 24,
            color: Pallete.mainFontColor,
          ),
          bodyMedium: TextStyle(
            fontFamily: 'Cera Pro',
            fontSize: 18,
            color: Pallete.mainFontColor,
            fontWeight: FontWeight.w700,
          ),
          bodySmall: TextStyle(
            fontFamily: 'Cera Pro',
            fontSize: 14,
            color: Pallete.mainFontColor,
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
