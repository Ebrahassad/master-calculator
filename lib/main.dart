import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/strings.dart';
import 'screens/landing_screen.dart';
import 'services/ads_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MasterCalculatorApp());
}

class MasterCalculatorApp extends StatefulWidget {
  const MasterCalculatorApp({super.key});

  @override
  State<MasterCalculatorApp> createState() => _MasterCalculatorAppState();
}

class _MasterCalculatorAppState extends State<MasterCalculatorApp> {
  Color _backgroundColor = const Color(0xFF121212);
  final LanguageController _lang = LanguageController();

  @override
  void initState() {
    super.initState();
    // تهيئة نظام إعلانات Unity Ads مرة واحدة عند إقلاع التطبيق
    AdsService.instance.init();
  }

  void _updateBackgroundColor(Color newColor) {
    setState(() => _backgroundColor = newColor);
  }

  @override
  Widget build(BuildContext context) {
    return Lang(
      controller: _lang,
      child: AnimatedBuilder(
        animation: _lang,
        builder: (context, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            locale: _lang.locale,
            supportedLocales: const [Locale('ar'), Locale('en')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            title: 'Master Calculator',
            theme: ThemeData.dark().copyWith(
              scaffoldBackgroundColor: _backgroundColor,
              primaryColor: Colors.blueAccent,
              colorScheme: ThemeData.dark().colorScheme.copyWith(secondary: Colors.tealAccent),
            ),
            builder: (context, child) {
              return Directionality(
                textDirection: _lang.direction,
                child: child!,
              );
            },
            home: LandingScreen(
              backgroundColor: _backgroundColor,
              onColorChanged: _updateBackgroundColor,
            ),
          );
        },
      ),
    );
  }
}
