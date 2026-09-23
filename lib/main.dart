import 'package:flutter/material.dart';
import 'screens/unit_converter_screen.dart';
import 'screens/daily_calculator_screen.dart';
import 'screens/health_calculator_screen.dart';
import 'screens/business_calculator_screen.dart';

void main() {
  runApp(const MasterCalculatorApp());
}

class MasterCalculatorApp extends StatefulWidget {
  const MasterCalculatorApp({Key? key}) : super(key: key);

  @override
  State<MasterCalculatorApp> createState() => _MasterCalculatorAppState();
}

class _MasterCalculatorAppState extends State<MasterCalculatorApp> {
  Color _backgroundColor = const Color(0xFF121212);

  void _updateBackgroundColor(Color newColor) {
    setState(() {
      _backgroundColor = newColor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'موسوعة الحاسبات الشاملة',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: _backgroundColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: MainContainerScreen(
        backgroundColor: _backgroundColor,
        onColorChanged: _updateBackgroundColor,
      ),
    );
  }
}

class MainContainerScreen extends StatefulWidget {
  final Color backgroundColor;
  final ValueChanged<Color> onColorChanged;

  const MainContainerScreen({
    Key? key,
    required this.backgroundColor,
    required this.onColorChanged,
  }) : super(key: key);

  @override
  _MainContainerScreenState createState() => _MainContainerScreenState();
}

class _MainContainerScreenState extends State<MainContainerScreen> {
  int _currentIndex = 0;

  List<Widget> get _screens => [
    UnitConverterScreen(onOpenDrawer: _openDrawer, backgroundColor: widget.backgroundColor),
    DailyCalculatorScreen(onOpenDrawer: _openDrawer, backgroundColor: widget.backgroundColor),
    HealthCalculatorScreen(onOpenDrawer: _openDrawer, backgroundColor: widget.backgroundColor),
    BusinessCalculatorScreen(onOpenDrawer: _openDrawer, backgroundColor: widget.backgroundColor),
  ];

  void _openDrawer() {
    Scaffold.of(context).openDrawer();
  }

  void _showCustomColorPicker() {
    Color currentColor = widget.backgroundColor;
    int red = currentColor.red;
    int green = currentColor.green;
    int blue = currentColor.blue;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          Color selectedColor = Color.fromARGB(255, red, green, blue);
          return AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            title: const Text('اختر لون خلفية التطبيق بحرية', style: TextStyle(color: Colors.white, fontSize: 18)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: selectedColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white24, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: selectedColor.withOpacity(0.6),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('أحمر: $red', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  Slider(
                    value: red.toDouble(),
                    min: 0,
                    max: 255,
                    activeColor: Colors.red,
                    onChanged: (val) {
                      setDialogState(() {
                        red = val.toInt();
                      });
                    },
                  ),
                  Text('أخضر: $green', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                  Slider(
                    value: green.toDouble(),
                    min: 0,
                    max: 255,
                    activeColor: Colors.green,
                    onChanged: (val) {
                      setDialogState(() {
                        green = val.toInt();
                      });
                    },
                  ),
                  Text('أزرق: $blue', style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                  Slider(
                    value: blue.toDouble(),
                    min: 0,
                    max: 255,
                    activeColor: Colors.blue,
                    onChanged: (val) {
                      setDialogState(() {
                        blue = val.toInt();
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text('إلغاء', style: TextStyle(color: Colors.white70)),
                onPressed: () => Navigator.of(context).pop(),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                child: const Text('تطبيق اللون'),
                onPressed: () {
                  widget.onColorChanged(selectedColor);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
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
                children: const [
                  const Icon(Icons.functions, color: Colors.white, size: 40),
                  const SizedBox(height: 10),
                  Text(
                    'موسوعة الحاسبات',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'إعدادات المظهر المتقدمة',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.palette_rounded, color: Colors.blueAccent),
              title: const Text('تغيير لون الخلفية (اختيار حر)', style: TextStyle(color: Colors.white)),
              subtitle: const Text('اختر أي لون ترغب به للتطبيق', style: TextStyle(color: Colors.white60, fontSize: 12)),
              onTap: () {
                Navigator.pop(context); // إغلاق القائمة الجانبية أولاً
                _showCustomColorPicker();
              },
            ),
            const Divider(color: Colors.white24),
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.purpleAccent),
              title: const Text('حول التطبيق', style: TextStyle(color: Colors.white)),
              subtitle: const Text('الإصدار 2.0 الاحترافي', style: TextStyle(color: Colors.white60, fontSize: 12)),
              onTap: () {
                Navigator.pop(context);
                showAboutDialog(
                  context: context,
                  applicationName: 'موسوعة الحاسبات الشاملة',
                  applicationVersion: '2.0.0',
                  applicationIcon: const Icon(Icons.functions),
                  children: [const Text('تطبيق متكامل يضم كافة الحاسبات اليومية والعلمية والصحية والمالية بتصميم عصري فائق الجودة.')],
                );
              },
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Colors.transparent,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.white60,
          selectedFontSize: 13,
          unselectedFontSize: 12,
          elevation: 0,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.swap_horiz_rounded),
              label: 'التحويلات',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.blueAccent, Colors.purpleAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.functions,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              label: 'العلمية',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.favorite_rounded),
              label: 'الصحة',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_rounded),
              label: 'المال',
            ),
          ],
        ),
      ),
    );
  }
}
