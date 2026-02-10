import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/provider.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/splash_screen.dart';
import 'utils/notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://hqkcpsbfpqbbmzlzshms.supabase.co',
    anonKey: 'sb_publishable_TzTfWTFDc4A28uuCPsezRA_3dcHQ9Q1',
  );

  await NotificationService().init();
  runApp(
    ChangeNotifierProvider(
      create: (context) => QuestProvider(),
      child: const RPGQuestApp(),
    ),
  );
}

class RPGQuestApp extends StatelessWidget {
  const RPGQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RPG Quest Log',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          primary: Colors.green[700]!, // Grass Green
          secondary: Colors.lightBlue[400]!, // Sky Blue
          surface: const Color(0xFFF1F8E9), // Light Green Tint
          onSurface: const Color(0xFF1B5E20), // Deep Green
        ),
        scaffoldBackgroundColor: const Color(0xFFE8F5E9), // Very Light Green
        textTheme:
            GoogleFonts.pressStart2pTextTheme(
              Theme.of(context).textTheme,
            ).apply(
              bodyColor: const Color(0xFF0D47A1), // Deep Sky Blue for contrast
              displayColor: const Color(0xFF1B5E20), // Deep Green
            ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.green[800],
          foregroundColor: Colors.white,
          elevation: 0, // Flat for 8-bit
        ),
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: const Color(0xFFF1F8E9),
          shape: const BeveledRectangleBorder(),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.lightBlue[600],
          foregroundColor: Colors.white,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
