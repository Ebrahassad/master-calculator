import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MasterCalculatorApp());
}

class MasterCalculatorApp extends StatefulWidget {
  const MasterCalculatorApp({Key? key}) : super(key: key);

  @override
  State<MasterCalculatorApp> createState() => _MasterCalculatorAppState();
}

class _MasterCalculatorAppState extends State<MasterCalculatorApp> {
  Color _backgroundColor = const Color(0xFF121212);
  Locale _locale = const Locale('ar');
  final List<String> _sessionHistory = [];

  void _updateBackgroundColor(Color newColor) {
    setState(() {
      _backgroundColor = newColor;
    });
  }

  void _toggleLanguage() {
    setState(() {
      _locale = _locale.languageCode == 'ar' ? const Locale('en') : const Locale('ar');
    });
  }

  void _saveSession(String operation) {
    setState(() {
      _sessionHistory.insert(0, '${DateTime.now().toString().substring(0, 16)}: $operation');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: _locale,
      title: 'موسوعة الحاسبات الشاملة',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: _backgroundColor,
        primaryColor: Colors.blueAccent,
      ),
      home: HomeScreen(
        backgroundColor: _backgroundColor,
        onColorChanged: _updateBackgroundColor,
        onToggleLanguage: _toggleLanguage,
        onSaveSession: _saveSession,
        sessionHistory: _sessionHistory,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final Color backgroundColor;
  final ValueChanged<Color> onColorChanged;
  final VoidCallback onToggleLanguage;
  final ValueChanged<String> onSaveSession;
  final List<String> sessionHistory;

  const HomeScreen({
    Key? key,
    required this.backgroundColor,
    required this.onColorChanged,
    required this.onToggleLanguage,
    required this.onSaveSession,
    required this.sessionHistory,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    FinanceTab(),
    HealthTab(),
    CalculationsTab(),
    ConversionsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('موسوعة الحاسبات الشاملة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xFF1E1E1E),
        actions: [
          IconButton(
            icon: const Icon(Icons.functions, color: Colors.cyanAccent),
            tooltip: 'الآلة الحاسبة العلمية الهندسية',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ScientificCalculatorScreen()),
              );
            },
          ),
        ],
      ),
      drawer: AppDrawer(
        backgroundColor: widget.backgroundColor,
        onColorChanged: widget.onColorChanged,
        onToggleLanguage: widget.onToggleLanguage,
        onSaveCurrentSession: () {
          widget.onSaveSession('جلسة حسابات مالية وصحية نشطة');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ تم حفظ الجلسة الحالية بنجاح في السجل')),
          );
        },
        sessionHistory: widget.sessionHistory,
      ),
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.white60,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: 'المال'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'الصحة'),
          BottomNavigationBarItem(icon: Icon(Icons.calculate), label: 'الحسابات'),
          BottomNavigationBarItem(icon: Icon(Icons.swap_horiz), label: 'التحويلات'),
        ],
      ),
    );
  }
}

// ================= القائمة الجانبية (Drawer) =================
class AppDrawer extends StatelessWidget {
  final Color backgroundColor;
  final ValueChanged<Color> onColorChanged;
  final VoidCallback onToggleLanguage;
  final VoidCallback onSaveCurrentSession;
  final List<String> sessionHistory;

  const AppDrawer({
    Key? key,
    required this.backgroundColor,
    required this.onColorChanged,
    required this.onToggleLanguage,
    required this.onSaveCurrentSession,
    required this.sessionHistory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF1A1A1A),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
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
                Icon(Icons.calculate_rounded, color: Colors.white, size: 40),
                SizedBox(height: 10),
                Text('موسوعة الحاسبات الشاملة', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Master Calculator Hub', style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.bookmark_add, color: Colors.amber),
            title: const Text('1. حفظ الجلسة الحالية', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              onSaveCurrentSession();
            },
          ),
          ListTile(
            leading: const Icon(Icons.history, color: Colors.blueAccent),
            title: const Text('2. سجل الجلسات والعمليات', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HistoryScreen(history: sessionHistory)),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.palette, color: Colors.purpleAccent),
            title: const Text('3. تغيير الخلفية بألوان انتقائية', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              _showColorPicker(context, onColorChanged);
            },
          ),
          ListTile(
            leading: const Icon(Icons.language, color: Colors.tealAccent),
            title: const Text('4. تغيير اللغة', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              onToggleLanguage();
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.orangeAccent),
            title: const Text('5. حول التطبيق', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              showAboutDialog(
                context: context,
                applicationName: 'موسوعة الحاسبات الشاملة',
                applicationVersion: 'الإصدار 1.0.0',
                applicationLegalese: 'تواصل معنا: ebrahassadi77@gmail.com',
                children: const [Text('تطبيق شامل لجميع العمليات الحسابية والمالية والصحية والتحويلات اللحظية.')],
              );
            },
          ),
          const Divider(color: Colors.white24),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.redAccent),
            title: const Text('6. خروج من التطبيق', style: TextStyle(color: Colors.redAccent)),
            onTap: () => SystemNavigator.pop(),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('7. إصدار 1.0.0\nتواصل معنا: ebrahassadi77@gmail.com', style: TextStyle(color: Colors.white54, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  void _showColorPicker(BuildContext context, ValueChanged<Color> onColorChanged) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF222222),
        title: const Text('اختر لون الخلفية', style: TextStyle(color: Colors.white)),
        content: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _colorButton(context, const Color(0xFF121212), 'داكن أصلي', onColorChanged),
            _colorButton(context, const Color(0xFF0F172A), 'كحلي داكن', onColorChanged),
            _colorButton(context, const Color(0xFF1E1B4B), 'ليلي عميق', onColorChanged),
            _colorButton(context, const Color(0xFF14281D), 'أخضر داكن', onColorChanged),
            _colorButton(context, const Color(0xFF3B0764), 'بنفسجي ملكي', onColorChanged),
          ],
        ),
      ),
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

// ================= تبويب المال (Finance Tab) =================
class FinanceTab extends StatefulWidget {
  const FinanceTab({Key? key}) : super(key: key);

  @override
  State<FinanceTab> createState() => _FinanceTabState();
}

class _FinanceTabState extends State<FinanceTab> {
  String _selectedCalc = 'ضريبة القيمة المضافة (VAT)';
  final TextEditingController _amountController = TextEditingController(text: '1000');
  final TextEditingController _rateController = TextEditingController(text: '15');
  double _res1 = 0;
  double _res2 = 0;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    double amt = double.tryParse(_amountController.text) ?? 0;
    double rt = double.tryParse(_rateController.text) ?? 0;
    if (_selectedCalc.contains('VAT')) {
      setState(() {
        _res1 = amt * (rt / 100);
        _res2 = amt + _res1;
      });
    } else {
      setState(() {
        _res1 = amt * (rt / 100);
        _res2 = (amt + _res1) / 12;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(12)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCalc,
                dropdownColor: const Color(0xFF1E1E1E),
                style: const TextStyle(color: Colors.white, fontSize: 16),
                isExpanded: true,
                items: ['ضريبة القيمة المضافة (VAT)', 'حاسبة القروض والفوائد', 'حاسبة الاستثمار والأرباح']
                    .map((val) => DropdownMenuItem(value: val, child: Text(val)))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedCalc = val!;
                    _calculate();
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'المبلغ الأساسي',
              labelStyle: const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: const Color(0xFF1E1E1E),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: (_) => _calculate(),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _rateController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'النسبة أو الفائدة (%)',
              labelStyle: const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: const Color(0xFF1E1E1E),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: (_) => _calculate(),
          ),
          const SizedBox(height: 25),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                const Text('الناتج الفرعي / الزيادة:', style: TextStyle(color: Colors.white70, fontSize: 16)),
                const SizedBox(height: 5),
                Text(_res1.toStringAsFixed(2), style: const TextStyle(color: Colors.blueAccent, fontSize: 26, fontWeight: FontWeight.bold)),
                const Divider(color: Colors.white24, height: 20),
                const Text('الإجمالي الشامل:', style: TextStyle(color: Colors.white70, fontSize: 16)),
                const SizedBox(height: 5),
                Text(_res2.toStringAsFixed(2), style: const TextStyle(color: Colors.greenAccent, fontSize: 30, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================= تبويب الصحة (Health Tab) =================
class HealthTab extends StatefulWidget {
  const HealthTab({Key? key}) : super(key: key);

  @override
  State<HealthTab> createState() => _HealthTabState();
}

class _HealthTabState extends State<HealthTab> {
  String _selectedCalc = 'مؤشر كتلة الجسم (BMI)';
  final TextEditingController _c1 = TextEditingController(text: '70');
  final TextEditingController _c2 = TextEditingController(text: '175');
  String _resText = '';
  String _statusText = '';

  @override
  void initState() {
    super.initState();
    _calcHealth();
  }

  void _calcHealth() {
    double v1 = double.tryParse(_c1.text) ?? 0;
    double v2 = double.tryParse(_c2.text) ?? 0;
    if (_selectedCalc.contains('BMI')) {
      if (v2 > 0) {
        double m = v2 / 100;
        double bmi = v1 / (m * m);
        setState(() {
          _resText = bmi.toStringAsFixed(1);
          if (bmi < 18.5) _statusText = 'وزن منخفض';
          else if (bmi < 25) _statusText = 'وزن مثالي ورائع';
          else if (bmi < 30) _statusText = 'زيادة في الوزن';
          else _statusText = 'سمنة مفرطة';
        });
      }
    } else {
      double eag = (28.7 * v1) - 46.7;
      setState(() {
        _resText = '${eag.toStringAsFixed(0)} mg/dL';
        if (v1 < 5.7) _statusText = 'معدل طبيعي ممتاز';
        else if (v1 < 6.5) _statusText = 'مرحلة ما قبل السكري';
        else _statusText = 'مستوى مرتفع (سكري)';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(12)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCalc,
                dropdownColor: const Color(0xFF1E1E1E),
                style: const TextStyle(color: Colors.white, fontSize: 16),
                isExpanded: true,
                items: ['مؤشر كتلة الجسم (BMI)', 'معدل السكر التراكمي (HbA1c)', 'حاسبة احتياج الماء اليومي']
                    .map((val) => DropdownMenuItem(value: val, child: Text(val)))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedCalc = val!;
                    if (_selectedCalc.contains('BMI')) {
                      _c1.text = '70';
                      _c2.text = '175';
                    } else {
                      _c1.text = '6.1';
                      _c2.text = '0';
                    }
                    _calcHealth();
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _c1,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: _selectedCalc.contains('BMI') ? 'الوزن (كجم)' : 'نسبة السكر التراكمي (%)',
              labelStyle: const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: const Color(0xFF1E1E1E),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: (_) => _calcHealth(),
          ),
          if (_selectedCalc.contains('BMI')) ...[
            const SizedBox(height: 15),
            TextField(
              controller: _c2,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'الطول (سم)',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (_) => _calcHealth(),
            ),
          ],
          const SizedBox(height: 25),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                const Text('النتيجة الصحية:', style: TextStyle(color: Colors.white70, fontSize: 16)),
                const SizedBox(height: 8),
                Text(_resText, style: const TextStyle(color: Colors.tealAccent, fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(_statusText, style: const TextStyle(color: Colors.amberAccent, fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================= تبويب الحسابات (Calculations Tab) =================
class CalculationsTab extends StatefulWidget {
  const CalculationsTab({Key? key}) : super(key: key);

  @override
  State<CalculationsTab> createState() => _CalculationsTabState();
}

class _CalculationsTabState extends State<CalculationsTab> {
  String _selectedCalc = 'حاسبة الخصم والنسبة (Discount)';
  final TextEditingController _t1 = TextEditingController(text: '100');
  final TextEditingController _t2 = TextEditingController(text: '20');
  double _r1 = 0;
  double _r2 = 0;

  @override
  void initState() {
    super.initState();
    _calc();
  }

  void _calc() {
    double v1 = double.tryParse(_t1.text) ?? 0;
    double v2 = double.tryParse(_t2.text) ?? 0;
    setState(() {
      _r1 = v1 * (v2 / 100);
      _r2 = v1 - _r1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(12)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCalc,
                dropdownColor: const Color(0xFF1E1E1E),
                style: const TextStyle(color: Colors.white, fontSize: 16),
                isExpanded: true,
                items: ['حاسبة الخصم والنسبة (Discount)', 'حاسبة النسب المئوية البسيطة']
                    .map((val) => DropdownMenuItem(value: val, child: Text(val)))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedCalc = val!;
                    _calc();
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _t1,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'السعر الأصلي أو القيمة',
              labelStyle: const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: const Color(0xFF1E1E1E),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: (_) => _calc(),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _t2,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'نسبة الخصم (%)',
              labelStyle: const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: const Color(0xFF1E1E1E),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: (_) => _calc(),
          ),
          const SizedBox(height: 25),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                const Text('مقدار التوفير:', style: TextStyle(color: Colors.white70, fontSize: 16)),
                const SizedBox(height: 5),
                Text(_r1.toStringAsFixed(2), style: const TextStyle(color: Colors.greenAccent, fontSize: 26, fontWeight: FontWeight.bold)),
                const Divider(color: Colors.white24, height: 20),
                const Text('السعر النهائي:', style: TextStyle(color: Colors.white70, fontSize: 16)),
                const SizedBox(height: 5),
                Text(_r2.toStringAsFixed(2), style: const TextStyle(color: Colors.blueAccent, fontSize: 30, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================= تبويب التحويلات (Conversions Tab) =================
class ConversionsTab extends StatefulWidget {
  const ConversionsTab({Key? key}) : super(key: key);

  @override
  State<ConversionsTab> createState() => _ConversionsTabState();
}

class _ConversionsTabState extends State<ConversionsTab> {
  String _category = 'تحويل العملات (أسعار لحظية معتمدة)';
  final TextEditingController _inputC = TextEditingController(text: '1');
  String _from = 'دولار أمريكي (USD)';
  String _to = 'دينار ليبي (LYD)';
  double _resultVal = 4.85;

  // خريطة الأسعار المعتمدة
  final Map<String, double> _rates = {
    'USD': 1.0,
    'LYD': 4.85,
    'EUR': 0.92,
    'GBP': 0.78,
  };

  @override
  void initState() {
    super.initState();
    _convert();
  }

  void _convert() {
    double val = double.tryParse(_inputC.text) ?? 0;
    if (_category.contains('العملات')) {
      String fKey = _from.contains('USD') ? 'USD' : _from.contains('LYD') ? 'LYD' : _from.contains('EUR') ? 'EUR' : 'GBP';
      String tKey = _to.contains('USD') ? 'USD' : _to.contains('LYD') ? 'LYD' : _to.contains('EUR') ? 'EUR' : 'GBP';
      
      double fRate = _rates[fKey] ?? 1.0;
      double tRate = _rates[tKey] ?? 1.0;

      setState(() {
        _resultVal = (val / fRate) * tRate;
      });
    } else {
      setState(() {
        _resultVal = _from.contains('متر') && _to.contains('كيلو') ? val / 1000 : val * 1000;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(12)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _category,
                dropdownColor: const Color(0xFF1E1E1E),
                style: const TextStyle(color: Colors.white, fontSize: 16),
                isExpanded: true,
                items: ['تحويل العملات (أسعار لحظية معتمدة)', 'تحويل المسافات والقياسات']
                    .map((val) => DropdownMenuItem(value: val, child: Text(val)))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _category = val!;
                    if (_category.contains('العملات')) {
                      _from = 'دولار أمريكي (USD)';
                      _to = 'دينار ليبي (LYD)';
                    } else {
                      _from = 'متر';
                      _to = 'كيلومتر';
                    }
                    _convert();
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _inputC,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'القيمة المراد تحويلها',
              labelStyle: const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: const Color(0xFF1E1E1E),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: (_) => _convert(),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _from,
                  dropdownColor: const Color(0xFF1E1E1E),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'من',
                    filled: true,
                    fillColor: const Color(0xFF1E1E1E),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: (_category.contains('العملات')
                          ? ['دولار أمريكي (USD)', 'دينار ليبي (LYD)', 'يورو (EUR)', 'جنيه استرليني (GBP)']
                          : ['متر', 'كيلومتر', 'سنتيمتر'])
                      .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      _from = val!;
                      _convert();
                    });
                  },
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.arrow_forward, color: Colors.blueAccent),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _to,
                  dropdownColor: const Color(0xFF1E1E1E),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'إلى',
                    filled: true,
                    fillColor: const Color(0xFF1E1E1E),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: (_category.contains('العملات')
                          ? ['دينار ليبي (LYD)', 'دولار أمريكي (USD)', 'يورو (EUR)', 'جنيه استرليني (GBP)']
                          : ['كيلومتر', 'متر', 'سنتيمتر'])
                      .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      _to = val!;
                      _convert();
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                const Text('المبلغ / القيمة المحولة:', style: TextStyle(color: Colors.white70, fontSize: 16)),
                const SizedBox(height: 8),
                Text(_resultVal.toStringAsFixed(4), style: const TextStyle(color: Colors.tealAccent, fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text(_to, style: const TextStyle(color: Colors.white54, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================= سجل الجلسات =================
class HistoryScreen extends StatelessWidget {
  final List<String> history;
  const HistoryScreen({Key? key, required this.history}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('سجل الجلسات والعمليات'), backgroundColor: const Color(0xFF1E1E1E)),
      body: history.isEmpty
          ? const Center(child: Text('لا توجد جلسات محفوظة حتى الآن', style: TextStyle(color: Colors.white54, fontSize: 16)))
          : ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                return Card(
                  color: const Color(0xFF1E1E1E),
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.history_edu, color: Colors.blueAccent),
                    title: Text(history[index], style: const TextStyle(color: Colors.white)),
                  ),
                );
              },
            ),
    );
  }
}

// ================= الآلة الحاسبة العلمية الهندسية =================
class ScientificCalculatorScreen extends StatefulWidget {
  const ScientificCalculatorScreen({Key? key}) : super(key: key);

  @override
  State<ScientificCalculatorScreen> createState() => _ScientificCalculatorScreenState();
}

class _ScientificCalculatorScreenState extends State<ScientificCalculatorScreen> {
  String _display = '0';

  void _onBtn(String txt) {
    setState(() {
      if (_display == '0') {
        _display = txt;
      } else {
        _display += txt;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الآلة الحاسبة العلمية الهندسية'), backgroundColor: const Color(0xFF1E1E1E)),
      body: Column(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(24),
              child: Text(_display, style: const TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.bold)),
            ),
          ),
          const Divider(height: 1, color: Colors.white24),
          Expanded(
            flex: 2,
            child: GridView.count(
              crossAxisCount: 4,
              padding: const EdgeInsets.all(8),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: [
                'sin', 'cos', 'tan', 'C',
                '7', '8', '9', '/',
                '4', '5', '6', '*',
                '1', '2', '3', '-',
                '0', '.', '=', '+',
              ].map((text) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E1E1E)),
                  onPressed: () {
                    if (text == 'C') {
                      setState(() => _display = '0');
                    } else if (text == '=') {
                      setState(() => _display += ' (تمت)');
                    } else {
                      _onBtn(text);
                    }
                  },
                  child: Text(text, style: const TextStyle(fontSize: 18, color: Colors.white)),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
