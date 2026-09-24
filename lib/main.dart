import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'l10n/strings.dart';
import 'screens/finance_tab.dart';
import 'screens/health_tab.dart';
import 'screens/calculations_tab.dart';
import 'screens/conversions_tab.dart';
import 'screens/scientific_calculator_screen.dart';
import 'screens/history_screen.dart';
import 'screens/about_screen.dart';
import 'services/ads_service.dart';
import 'widgets/banner_ad_bar.dart';

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
  final List<String> _sessionHistory = [];

  @override
  void initState() {
    super.initState();
    // تهيئة نظام إعلانات Unity Ads مرة واحدة عند إقلاع التطبيق
    AdsService.instance.init();
  }

  void _updateBackgroundColor(Color newColor) {
    setState(() => _backgroundColor = newColor);
  }

  void _saveSession(String operation) {
    setState(() {
      _sessionHistory.insert(0, '${DateTime.now().toString().substring(0, 16)}: $operation');
    });
  }

  void _clearHistory() {
    setState(() => _sessionHistory.clear());
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
            home: HomeScreen(
              backgroundColor: _backgroundColor,
              onColorChanged: _updateBackgroundColor,
              onSaveSession: _saveSession,
              onClearHistory: _clearHistory,
              sessionHistory: _sessionHistory,
            ),
          );
        },
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final Color backgroundColor;
  final ValueChanged<Color> onColorChanged;
  final ValueChanged<String> onSaveSession;
  final VoidCallback onClearHistory;
  final List<String> sessionHistory;

  const HomeScreen({
    super.key,
    required this.backgroundColor,
    required this.onColorChanged,
    required this.onSaveSession,
    required this.onClearHistory,
    required this.sessionHistory,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  int _tabSwitchCount = 0;

  final List<Widget> _tabs = const [
    FinanceTab(),
    HealthTab(),
    CalculationsTab(),
    ConversionsTab(),
  ];

  void _onTabTap(int index) {
    setState(() => _currentIndex = index);
    _tabSwitchCount++;
    // إعلان بيني غير مزعج: يظهر كل 4 تنقلات بين التبويبات فقط، وليس في كل مرة
    if (_tabSwitchCount % 4 == 0) {
      AdsService.instance.showInterstitial();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr(context, 'app_title'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 2,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.functions, color: Colors.cyanAccent),
            tooltip: tr(context, 'scientific_tooltip'),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ScientificCalculatorScreen()));
            },
          ),
        ],
      ),
      drawer: AppDrawer(
        backgroundColor: widget.backgroundColor,
        onColorChanged: widget.onColorChanged,
        onSaveCurrentSession: () {
          widget.onSaveSession(tr(context, 'active_session'));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(tr(context, 'session_saved'))),
          );
        },
        onClearHistory: widget.onClearHistory,
        sessionHistory: widget.sessionHistory,
      ),
      body: Column(
        children: [
          Expanded(child: _tabs[_currentIndex]),
          const BannerAdBar(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, -2))],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTap,
          backgroundColor: const Color(0xFF1E1E1E),
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.white54,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: [
            BottomNavigationBarItem(icon: const Icon(Icons.attach_money), label: tr(context, 'nav_money')),
            BottomNavigationBarItem(icon: const Icon(Icons.favorite), label: tr(context, 'nav_health')),
            BottomNavigationBarItem(icon: const Icon(Icons.calculate), label: tr(context, 'nav_calc')),
            BottomNavigationBarItem(icon: const Icon(Icons.swap_horiz), label: tr(context, 'nav_convert')),
          ],
        ),
      ),
    );
  }
}

// ================= القائمة الجانبية (Drawer) =================
class AppDrawer extends StatelessWidget {
  final Color backgroundColor;
  final ValueChanged<Color> onColorChanged;
  final VoidCallback onSaveCurrentSession;
  final VoidCallback onClearHistory;
  final List<String> sessionHistory;

  const AppDrawer({
    super.key,
    required this.backgroundColor,
    required this.onColorChanged,
    required this.onSaveCurrentSession,
    required this.onClearHistory,
    required this.sessionHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF1A1A1A),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.purpleAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.calculate_rounded, color: Colors.white, size: 40),
                const SizedBox(height: 10),
                Text(tr(context, 'app_title'), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const Text('Master Calculator Hub', style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.bookmark_add, color: Colors.amber),
            title: Text(tr(context, 'drawer_save_session'), style: const TextStyle(color: Colors.white)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
            onTap: () {
              Navigator.pop(context);
              onSaveCurrentSession();
            },
          ),
          ListTile(
            leading: const Icon(Icons.history, color: Colors.blueAccent),
            title: Text(tr(context, 'drawer_history'), style: const TextStyle(color: Colors.white)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HistoryScreen(history: sessionHistory, onClear: onClearHistory)),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.palette, color: Colors.purpleAccent),
            title: Text(tr(context, 'drawer_background'), style: const TextStyle(color: Colors.white)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
            onTap: () {
              Navigator.pop(context);
              _showColorPicker(context, onColorChanged);
            },
          ),
          ListTile(
            leading: const Icon(Icons.language, color: Colors.tealAccent),
            title: Text(tr(context, 'drawer_language'), style: const TextStyle(color: Colors.white)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
            onTap: () {
              Lang.of(context).toggle();
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.share, color: Colors.lightGreenAccent),
            title: Text(tr(context, 'drawer_share'), style: const TextStyle(color: Colors.white)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
            onTap: () {
              Navigator.pop(context);
              Share.share(
                'جرّب تطبيق ${AppStrings.map['app_title']!['ar']} — موسوعة حاسبات مالية وصحية وهندسية وتحويلات لحظية شاملة!',
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.orangeAccent),
            title: Text(tr(context, 'drawer_about'), style: const TextStyle(color: Colors.white)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutScreen()));
            },
          ),
          const Divider(color: Colors.white24),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.redAccent),
            title: Text(tr(context, 'drawer_exit'), style: const TextStyle(color: Colors.redAccent)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
            onTap: () => SystemNavigator.pop(),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '${tr(context, 'drawer_version')} $kAppVersion\n${tr(context, 'drawer_contact')}: $kContactEmail',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showColorPicker(BuildContext context, ValueChanged<Color> onColorChanged) {
    const premiumColor = Color(0xFF3E2C0C);
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF222222),
            title: Text(tr(dialogContext, 'pick_color'), style: const TextStyle(color: Colors.white)),
            content: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _colorButton(dialogContext, const Color(0xFF121212), 'داكن أصلي', onColorChanged),
                _colorButton(dialogContext, const Color(0xFF0F172A), 'كحلي داكن', onColorChanged),
                _colorButton(dialogContext, const Color(0xFF1E1B4B), 'ليلي عميق', onColorChanged),
                _colorButton(dialogContext, const Color(0xFF14281D), 'أخضر داكن', onColorChanged),
                _colorButton(dialogContext, const Color(0xFF3B0764), 'بنفسجي ملكي', onColorChanged),
                _colorButton(dialogContext, const Color(0xFF1A1A1A), 'رمادي غرافيت', onColorChanged),
                FutureBuilder<bool>(
                  future: _isPremiumUnlocked(),
                  builder: (context, snapshot) {
                    final unlocked = snapshot.data ?? false;
                    if (unlocked) {
                      return _colorButton(dialogContext, premiumColor, tr(dialogContext, 'premium_theme'), onColorChanged);
                    }
                    return GestureDetector(
                      onTap: () => _handlePremiumTap(dialogContext, setDialogState),
                      child: Container(
                        width: 70,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFFB8860B), Color(0xFF4A3200)]),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amberAccent),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.lock, color: Colors.white, size: 18),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<bool> _isPremiumUnlocked() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('premium_theme_unlocked') ?? false;
  }

  void _handlePremiumTap(BuildContext dialogContext, void Function(void Function()) setDialogState) {
    AdsService.instance.showRewarded(
      onReward: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('premium_theme_unlocked', true);
        setDialogState(() {});
        if (dialogContext.mounted) {
          ScaffoldMessenger.of(dialogContext).showSnackBar(
            SnackBar(content: Text(tr(dialogContext, 'unlocked_now'))),
          );
        }
      },
      onNotReady: () {
        ScaffoldMessenger.of(dialogContext).showSnackBar(
          SnackBar(content: Text(tr(dialogContext, 'ad_not_ready_try_later'))),
        );
      },
    );
  }

  Widget _colorButton(BuildContext context, Color color, String label, ValueChanged<Color> onColorChanged) {
    return GestureDetector(
      onTap: () {
        onColorChanged(color);
        Navigator.pop(context);
      },
      child: Container(
        width: 70,
        height: 40,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white38)),
        alignment: Alignment.center,
        child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 10), textAlign: TextAlign.center),
      ),
    );
  }
}
