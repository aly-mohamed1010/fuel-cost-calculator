import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubit/fuel_calculator_cubit.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FuelCalculatorCubit(),
      child: MaterialApp(
        title: 'Fuel Calculator',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1E88E5), // Premium Blue
            brightness: Brightness.light,
            primary: const Color(0xFF1E88E5),
            secondary: const Color(0xFF00B0FF),
            surface: const Color(0xFFF5F7FA),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            iconTheme: IconThemeData(color: Colors.black87),
            titleTextStyle: TextStyle(
              color: Colors.black87,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 8,
            shadowColor: const Color(0x1A000000), // 10% black
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF42A5F5),
            brightness: Brightness.dark,
            primary: const Color(0xFF42A5F5),
            secondary: const Color(0xFF80D8FF),
            surface: const Color(0xFF121212),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
          ),
          cardTheme: CardThemeData(
            elevation: 8,
            shadowColor: const Color(0x4D000000), // 30% black
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
        ),
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}
