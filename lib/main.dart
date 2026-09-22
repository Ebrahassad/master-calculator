import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:fl_chart/fl_chart.dart';
import 'screens/unit_converter_screen.dart';
import 'screens/scientific_calculator_screen.dart';

void main() {
  runApp(const MasterCalculatorApp());
}

class MasterCalculatorApp extends StatefulWidget {
  const MasterCalculatorApp({super.key});

  @override
  State<MasterCalculatorApp> createState() => _MasterCalculatorAppState();
}

class _MasterCalculatorAppState extends State<MasterCalculatorApp> {
  Locale _currentLocale = const Locale('ar');
  List<String> _historyList = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _historyList = prefs.getStringList('calc_history') ?? [];
    });
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('calc_history', _historyList);
  }

  void _toggleLocale() {
    HapticFeedback.selectionClick();
    setState(() {
      _currentLocale = _currentLocale.languageCode == 'ar'
          ? const Locale('en')
          : const Locale('ar');
    });
  }

  void _addToHistory(String record) {
    setState(() {
      _historyList.insert(0, record);
      if (_historyList.length > 25) _historyList.removeLast();
    });
    _saveHistory();
  }

  @override
  Widget build(BuildContext context) {
    final bool isAr = _currentLocale.languageCode == 'ar';
    return MaterialApp(
      title: isAr ? 'الموسوعة الشاملة للحاسبات' : 'Master Calculator Hub',
      debugShowCheckedModeBanner: false,
      locale: _currentLocale,
      builder: (context, child) {
        return Directionality(
          textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
          child: child!,
        );
      },
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        scaffoldBackgroundColor: Colors.grey.shade50,
      ),
      home: HomeScreen(
        onToggleLang: _toggleLocale,
        isArabic: isAr,
        historyList: _historyList,
        onAddHistory: _addToHistory,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final VoidCallback onToggleLang;
  final bool isArabic;
  final List<String> historyList;
  final Function(String) onAddHistory;

  const HomeScreen({
    super.key,
    required this.onToggleLang,
    required this.isArabic,
    required this.historyList,
    required this.onAddHistory,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Color _backgroundColor = Colors.teal;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final colorValue = prefs.getInt('bg_color');
    if (colorValue != null) {
      setState(() {
        _backgroundColor = Color(colorValue);
      });
    }
  }

  Future<void> _saveBackgroundColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('bg_color', color.value);
  }

  void _showColorPicker() {
    HapticFeedback.selectionClick();
    setState(() {
      _backgroundColor = _backgroundColor == Colors.teal ? Colors.indigo : Colors.teal;
    });
    _saveBackgroundColor(_backgroundColor);
  }

  void _showHistoryDialog() {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.isArabic ? 'سجل الجلسات السابقة (محفوظ)' : 'Session History (Saved)'),
        content: SizedBox(
          width: double.maxFinite,
          child: widget.historyList.isEmpty
              ? Text(widget.isArabic ? 'لا توجد عمليات سابقة مسجلة' : 'No history records found')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.historyList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const Icon(Icons.history, color: Colors.indigo),
                      title: Text(widget.historyList[index], style: const TextStyle(fontSize: 14)),
                      trailing: IconButton(
                        icon: const Icon(Icons.share_rounded, size: 20, color: Colors.teal),
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          Share.share(widget.historyList[index]);
                        },
                        tooltip: widget.isArabic ? 'مشاركة النتيجة' : 'Share',
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(widget.isArabic ? 'إغلاق' : 'Close'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.isArabic ? 'حول التطبيق / About App' : 'About App / حول التطبيق'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'HASSADI Master Calculator Hub\nالإصدار: 2.1.0 (Pro)\n',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
              ),
              Text(
                widget.isArabic
                    ? 'تطبيق شامل ومتكامل يضم كافة الحاسبات اليومية، المالية، والصحية المتقدمة مع دعم التخزين المحلي والرسوم البيانية ومشاركة النتائج.\n\nDeveloped by HASSADI.'
                    : 'A comprehensive and integrated application featuring advanced financial, health, and everyday utility calculators with local persistence, charts, and sharing.\n\nDeveloped by HASSADI.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(widget.isArabic ? 'حسناً' : 'OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      FinancialModule(isArabic: widget.isArabic, onCalculate: widget.onAddHistory),
      HealthModule(isArabic: widget.isArabic, onCalculate: widget.onAddHistory),
      UtilitiesModule(isArabic: widget.isArabic, onCalculate: widget.onAddHistory),
    ];

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.isArabic
              ? ['المال والأعمال', 'الصحة واللياقة', 'الحاسبات اليومية'][_selectedIndex]
              : ['Financial & Business', 'Health & Fitness', 'Everyday Utilities'][_selectedIndex],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calculate),
            onPressed: () {
              HapticFeedback.selectionClick();
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ScientificCalculatorScreen()));
            },
            tooltip: widget.isArabic ? 'الآلة الحاسبة العلمية' : 'Scientific Calculator',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.indigo),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(Icons.calculate, size: 48, color: Colors.white),
                  const SizedBox(height: 8),
                  Text(
                    widget.isArabic ? 'موسوعة الحاسبات الشاملة' : 'Master Calculator Hub',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Text('HASSADI Brand', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: Text(widget.isArabic ? 'محول الوحدات الشامل' : 'Unit Converter'),
              onTap: () {
                HapticFeedback.selectionClick();
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const UnitConverterScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.color_lens_rounded),
              title: Text(widget.isArabic ? 'تغيير لون الخلفية' : 'Change Background Color'),
              onTap: _showColorPicker,
            ),
            ListTile(
              leading: const Icon(Icons.language_rounded),
              title: Text(widget.isArabic ? 'التحويل إلى الإنجليزية' : 'Switch to English / Arabic'),
              onTap: widget.onToggleLang,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.history_rounded),
              title: Text(widget.isArabic ? 'سجل الجلسات والعمليات' : 'Session History'),
              onTap: () {
                Navigator.pop(context);
                _showHistoryDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: Text(widget.isArabic ? 'حول التطبيق' : 'About App'),
              onTap: () {
                Navigator.pop(context);
                _showAboutDialog();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.exit_to_app_rounded, color: Colors.red),
              title: Text(widget.isArabic ? 'خروج من التطبيق' : 'Exit App', style: const TextStyle(color: Colors.red)),
              onTap: () {
                SystemNavigator.pop();
              },
            ),
          ],
        ),
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          HapticFeedback.selectionClick();
          setState(() => _selectedIndex = index);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.attach_money_rounded),
            label: widget.isArabic ? 'المالية' : 'Financial',
          ),
          NavigationDestination(
            icon: const Icon(Icons.favorite_rounded),
            label: widget.isArabic ? 'الصحة' : 'Health',
          ),
          NavigationDestination(
            icon: const Icon(Icons.calculate_rounded),
            label: widget.isArabic ? 'اليومية' : 'Utilities',
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 1. FINANCIAL MODULE
// ==========================================
class FinancialModule extends StatefulWidget {
  final bool isArabic;
  final Function(String) onCalculate;
  const FinancialModule({super.key, required this.isArabic, required this.onCalculate});

  @override
  State<FinancialModule> createState() => _FinancialModuleState();
}

class _FinancialModuleState extends State<FinancialModule> {
  int _selectedCalc = 0;

  final TextEditingController _vatAmountController = TextEditingController();
  final TextEditingController _vatRateController = TextEditingController(text: '15');
  double _vatResult = 0.0, _totalWithVat = 0.0;

  final TextEditingController _loanAmountController = TextEditingController();
  final TextEditingController _loanInterestController = TextEditingController(text: '5');
  final TextEditingController _loanYearsController = TextEditingController(text: '3');
  double _monthlyInstallment = 0.0, _totalInterest = 0.0;

  final TextEditingController _basicSalaryController = TextEditingController();
  final TextEditingController _allowancesController = TextEditingController(text: '0');
  final TextEditingController _deductionsController = TextEditingController(text: '0');
  double _netSalary = 0.0;

  void _calculateVat() {
    HapticFeedback.mediumImpact();
    double amt = double.tryParse(_vatAmountController.text) ?? 0.0;
    double rate = double.tryParse(_vatRateController.text) ?? 0.0;
    setState(() {
      _vatResult = amt * (rate / 100);
      _totalWithVat = amt + _vatResult;
    });
    widget.onCalculate('VAT Total: ${_totalWithVat.toStringAsFixed(2)}');
  }

  void _calculateLoan() {
    HapticFeedback.mediumImpact();
    double principal = double.tryParse(_loanAmountController.text) ?? 0.0;
    double annualRate = double.tryParse(_loanInterestController.text) ?? 0.0;
    int years = int.tryParse(_loanYearsController.text) ?? 1;
    int months = years * 12;
    if (principal > 0 && months > 0) {
      double monthlyRate = (annualRate / 100) / 12;
      if (monthlyRate == 0) {
        _monthlyInstallment = principal / months;
        _totalInterest = 0;
      } else {
        _monthlyInstallment = (principal * monthlyRate * SystemMath.pow(1 + monthlyRate, months.toDouble())) /
            (SystemMath.pow(1 + monthlyRate, months.toDouble()) - 1);
        _totalInterest = (_monthlyInstallment * months) - principal;
      }
      setState(() {});
      widget.onCalculate('Loan EMI: ${_monthlyInstallment.toStringAsFixed(2)}');
    }
  }

  void _calculateSalary() {
    HapticFeedback.mediumImpact();
    double basic = double.tryParse(_basicSalaryController.text) ?? 0.0;
    double allowances = double.tryParse(_allowancesController.text) ?? 0.0;
    double deductions = double.tryParse(_deductionsController.text) ?? 0.0;
    setState(() {
      _netSalary = (basic + allowances) - deductions;
    });
    widget.onCalculate('Net Salary: ${_netSalary.toStringAsFixed(2)}');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          DropdownButtonFormField<int>(
            value: _selectedCalc,
            decoration: InputDecoration(
              labelText: widget.isArabic ? 'اختر الحاسبة المالية' : 'Select Financial Calculator',
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
            items: [
              DropdownMenuItem(value: 0, child: Text(widget.isArabic ? 'حاسبة ضريبة القيمة المضافة (VAT)' : 'VAT Calculator')),
              DropdownMenuItem(value: 1, child: Text(widget.isArabic ? 'حاسبة القروض والأقساط مع الرسم البياني' : 'Loan & EMI with Chart')),
              DropdownMenuItem(value: 2, child: Text(widget.isArabic ? 'حاسبة صافي الراتب (Net Salary)' : 'Net Salary Calculator')),
            ],
            onChanged: (val) {
              HapticFeedback.selectionClick();
              setState(() => _selectedCalc = val!);
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _selectedCalc == 0
                ? _buildVatView()
                : _selectedCalc == 1
                    ? _buildLoanView()
                    : _buildSalaryView(),
          ),
        ],
      ),
    );
  }

  Widget _buildVatView() {
    return ListView(
      children: [
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(controller: _vatAmountController, keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: widget.isArabic ? 'المبلغ الأساسي' : 'Base Amount', border: const OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: _vatRateController, keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: widget.isArabic ? 'نسبة الضريبة (%)' : 'VAT Rate (%)', border: const OutlineInputBorder())),
                const SizedBox(height: 16),
                SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _calculateVat, child: Text(widget.isArabic ? 'حساب الضريبة' : 'Calculate VAT'))),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    children: [
                      Text('${widget.isArabic ? "قيمة الضريبة:" : "VAT Amount:"} ${_vatResult.toStringAsFixed(2)}'),
                      const Divider(),
                      Text('${widget.isArabic ? "الإجمالي الشامل:" : "Total:"} ${_totalWithVat.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoanView() {
    double principal = double.tryParse(_loanAmountController.text) ?? 1.0;
    return ListView(
      children: [
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(controller: _loanAmountController, keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: widget.isArabic ? 'مبلغ القرض' : 'Loan Amount', border: const OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: _loanInterestController, keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: widget.isArabic ? 'نسبة الفائدة السنوية (%)' : 'Annual Interest (%)', border: const OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: _loanYearsController, keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: widget.isArabic ? 'المدة (بالسنوات)' : 'Duration (Years)', border: const OutlineInputBorder())),
                const SizedBox(height: 16),
                SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _calculateLoan, child: Text(widget.isArabic ? 'حساب القسط والرسوم' : 'Calculate EMI & Chart'))),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    children: [
                      Text('${widget.isArabic ? "القسط الشهري:" : "Monthly EMI:"} ${_monthlyInstallment.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.teal)),
                      const Divider(),
                      Text('${widget.isArabic ? "إجمالي الفوائد:" : "Total Interest:"} ${_totalInterest.toStringAsFixed(2)}'),
                    ],
                  ),
                ),
                if (_monthlyInstallment > 0) ...[
                  const SizedBox(height: 20),
                  Text(widget.isArabic ? 'توزيع القرض (أصل المبلغ مقابل الفوائد)' : 'Loan Breakdown (Principal vs Interest)',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.indigo)),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 160,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 35,
                        sections: [
                          PieChartSectionData(
                            color: Colors.teal,
                            value: principal > 0 ? principal : 1,
                            title: widget.isArabic ? 'الأصل' : 'Principal',
                            radius: 45,
                            titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          PieChartSectionData(
                            color: Colors.orange,
                            value: _totalInterest > 0 ? _totalInterest : 1,
                            title: widget.isArabic ? 'الفوائد' : 'Interest',
                            radius: 45,
                            titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  )
                ]
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSalaryView() {
    return ListView(
      children: [
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(controller: _basicSalaryController, keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: widget.isArabic ? 'الراتب الأساسي' : 'Basic Salary', border: const OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: _allowancesController, keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: widget.isArabic ? 'العلاوات والبدلات' : 'Allowances', border: const OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: _deductionsController, keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: widget.isArabic ? 'الخصومات والضرائب' : 'Deductions', border: const OutlineInputBorder())),
                const SizedBox(height: 16),
                SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _calculateSalary, child: Text(widget.isArabic ? 'حساب صافي الراتب' : 'Calculate Net Salary'))),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                  child: Center(
                    child: Text(
                      '${widget.isArabic ? "صافي الراتب:" : "Net Salary:"} ${_netSalary.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class SystemMath {
  static double pow(double base, double exponent) {
    if (exponent == 0) return 1;
    double result = 1;
    for (int i = 0; i < exponent.abs(); i++) {
      result *= base;
    }
    return exponent < 0 ? 1 / result : result;
  }
}

// ==========================================
// 2. HEALTH MODULE
// ==========================================
class HealthModule extends StatefulWidget {
  final bool isArabic;
  final Function(String) onCalculate;
  const HealthModule({super.key, required this.isArabic, required this.onCalculate});

  @override
  State<HealthModule> createState() => _HealthModuleState();
}

class _HealthModuleState extends State<HealthModule> {
  int _selectedCalc = 0;

  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  double _bmiValue = 0.0;
  String _bmiStatus = '';

  final TextEditingController _calWeight = TextEditingController();
  final TextEditingController _calHeight = TextEditingController();
  final TextEditingController _calAge = TextEditingController();
  double _dailyCalories = 0.0;

  final TextEditingController _hba1cController = TextEditingController();
  double _avgBloodSugar = 0.0;

  final TextEditingController _waterWeightController = TextEditingController();
  double _waterLiters = 0.0;

  void _calculateBmi() {
    HapticFeedback.mediumImpact();
    double w = double.tryParse(_weightController.text) ?? 0.0;
    double hCm = double.tryParse(_heightController.text) ?? 0.0;
    if (w > 0 && hCm > 0) {
      double hM = hCm / 100;
      double bmi = w / (hM * hM);
      String status = '';
      if (bmi < 18.5) {
        status = widget.isArabic ? 'نقص في الوزن' : 'Underweight';
      } else if (bmi < 25) {
        status = widget.isArabic ? 'وزن مثالي وطبيعي' : 'Normal Weight';
      } else if (bmi < 30) {
        status = widget.isArabic ? 'زيادة في الوزن' : 'Overweight';
      } else {
        status = widget.isArabic ? 'سمنة مفرطة' : 'Obese';
      }
      setState(() {
        _bmiValue = bmi;
        _bmiStatus = status;
      });
      widget.onCalculate('BMI: ${bmi.toStringAsFixed(1)} ($status)');
    }
  }

  void _calculateCalories() {
    HapticFeedback.mediumImpact();
    double w = double.tryParse(_calWeight.text) ?? 0.0;
    double h = double.tryParse(_calHeight.text) ?? 0.0;
    double age = double.tryParse(_calAge.text) ?? 0.0;
    if (w > 0 && h > 0 && age > 0) {
      double bmr = 10 * w + 6.25 * h - 5 * age + 5;
      setState(() {
        _dailyCalories = bmr * 1.375;
      });
      widget.onCalculate('Calories: ${_dailyCalories.toStringAsFixed(0)} kcal');
    }
  }

  void _calculateHbA1c() {
    HapticFeedback.mediumImpact();
    double a1c = double.tryParse(_hba1cController.text) ?? 0.0;
    if (a1c > 0) {
      setState(() {
        _avgBloodSugar = (28.7 * a1c) - 46.7;
      });
      widget.onCalculate('HbA1c: $a1c%, eAG: ${_avgBloodSugar.toStringAsFixed(1)} mg/dL');
    }
  }

  void _calculateWater() {
    HapticFeedback.mediumImpact();
    double w = double.tryParse(_waterWeightController.text) ?? 0.0;
    if (w > 0) {
      setState(() {
        _waterLiters = (w * 35) / 1000;
      });
      widget.onCalculate('Water Intake: ${_waterLiters.toStringAsFixed(2)} Liters');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          DropdownButtonFormField<int>(
            value: _selectedCalc,
            decoration: InputDecoration(
              labelText: widget.isArabic ? 'اختر حاسبة الصحة' : 'Select Health Calculator',
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
            items: [
              DropdownMenuItem(value: 0, child: Text(widget.isArabic ? 'مؤشر كتلة الجسم (BMI)' : 'BMI Calculator')),
              DropdownMenuItem(value: 1, child: Text(widget.isArabic ? 'السعرات الحرارية اليومية (Calories)' : 'Calorie Calculator')),
              DropdownMenuItem(value: 2, child: Text(widget.isArabic ? 'حاسبة السكر التراكمي (HbA1c)' : 'HbA1c & Blood Sugar')),
              DropdownMenuItem(value: 3, child: Text(widget.isArabic ? 'حاسبة استهلاك الماء اليومي (Water)' : 'Water Intake Calculator')),
            ],
            onChanged: (val) {
              HapticFeedback.selectionClick();
              setState(() => _selectedCalc = val!);
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _selectedCalc == 0
                ? _buildBmiView()
                : _selectedCalc == 1
                    ? _buildCaloriesView()
                    : _selectedCalc == 2
                        ? _buildHbA1cView()
                        : _buildWaterView(),
          ),
        ],
      ),
    );
  }

  Widget _buildBmiView() {
    return ListView(
      children: [
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(controller: _weightController, keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: widget.isArabic ? 'الوزن (كجم)' : 'Weight (kg)', border: const OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: _heightController, keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: widget.isArabic ? 'الطول (سم)' : 'Height (cm)', border: const OutlineInputBorder())),
                const SizedBox(height: 16),
                SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _calculateBmi, child: Text(widget.isArabic ? 'حساب المؤشر' : 'Calculate BMI'))),
                const SizedBox(height: 16),
                if (_bmiValue > 0)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      children: [
                        Text('BMI: ${_bmiValue.toStringAsFixed(1)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
                        const SizedBox(height: 4),
                        Text(_bmiStatus, style: const TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
                  )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCaloriesView() {
    return ListView(
      children: [
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(controller: _calWeight, keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: widget.isArabic ? 'الوزن (كجم)' : 'Weight (kg)', border: const OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: _calHeight, keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: widget.isArabic ? 'الطول (سم)' : 'Height (cm)', border: const OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: _calAge, keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: widget.isArabic ? 'العمر (سنوات)' : 'Age (years)', border: const OutlineInputBorder())),
                const SizedBox(height: 16),
                SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _calculateCalories, child: Text(widget.isArabic ? 'حساب السعرات' : 'Calculate Calories'))),
                const SizedBox(height: 16),
                if (_dailyCalories > 0)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8)),
                    child: Center(
                      child: Text(
                        '${widget.isArabic ? "احتياجك اليومي:" : "Daily Need:"} ${_dailyCalories.toStringAsFixed(0)} ${widget.isArabic ? "سعرة حرارية" : "kcal"}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 16),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHbA1cView() {
    return ListView(
      children: [
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(controller: _hba1cController, keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: widget.isArabic ? 'نسبة السكر التراكمي HbA1c (%)' : 'HbA1c Percentage (%)', border: const OutlineInputBorder())),
                const SizedBox(height: 16),
                SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _calculateHbA1c, child: Text(widget.isArabic ? 'حساب متوسط السكر' : 'Calculate eAG'))),
                const SizedBox(height: 16),
                if (_avgBloodSugar > 0)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                    child: Center(
                      child: Text(
                        '${widget.isArabic ? "متوسط السكر التقديري (eAG):" : "Estimated Avg Glucose:"}\n${_avgBloodSugar.toStringAsFixed(1)} mg/dL',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 16),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWaterView() {
    return ListView(
      children: [
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(controller: _waterWeightController, keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: widget.isArabic ? 'الوزن (كجم)' : 'Weight (kg)', border: const OutlineInputBorder())),
                const SizedBox(height: 16),
                SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _calculateWater, child: Text(widget.isArabic ? 'حساب كمية الماء' : 'Calculate Water Intake'))),
                const SizedBox(height: 16),
                if (_waterLiters > 0)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                    child: Center(
                      child: Text(
                        '${widget.isArabic ? "الكمية اليومية اللازمة:" : "Daily Water Intake:"}\n${_waterLiters.toStringAsFixed(2)} ${widget.isArabic ? "لتر" : "Liters"}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 16),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ==========================================
// 3. UTILITIES MODULE
// ==========================================
class UtilitiesModule extends StatefulWidget {
  final bool isArabic;
  final Function(String) onCalculate;
  const UtilitiesModule({super.key, required this.isArabic, required this.onCalculate});

  @override
  State<UtilitiesModule> createState() => _UtilitiesModuleState();
}

class _UtilitiesModuleState extends State<UtilitiesModule> {
  int _selectedCalc = 0;

  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _discController = TextEditingController();
  double _finalPrice = 0.0, _savedAmount = 0.0;

  final TextEditingController _gbController = TextEditingController();
  double _mbResult = 0.0, _kbResult = 0.0;

  int _calculatedYears = 0, _calculatedMonths = 0, _calculatedDays = 0;
  DateTime? _selectedDate;

  void _calculateDiscount() {
    HapticFeedback.mediumImpact();
    double price = double.tryParse(_priceController.text) ?? 0.0;
    double disc = double.tryParse(_discController.text) ?? 0.0;
    setState(() {
      _savedAmount = price * (disc / 100);
      _finalPrice = price - _savedAmount;
    });
    widget.onCalculate('Discount Final: ${_finalPrice.toStringAsFixed(2)}');
  }

  void _convertStorage() {
    HapticFeedback.mediumImpact();
    double gb = double.tryParse(_gbController.text) ?? 0.0;
    setState(() {
      _mbResult = gb * 1024;
      _kbResult = gb * 1024 * 1024;
    });
    widget.onCalculate('Storage MB: ${_mbResult.toStringAsFixed(0)}');
  }

  Future<void> _pickBirthDate(BuildContext context) async {
    HapticFeedback.mediumImpact();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        final now = DateTime.now();
        int years = now.year - picked.year;
        int months = now.month - picked.month;
        int days = now.day - picked.day;

        if (days < 0) {
          months--;
          days += DateTime(now.year, now.month, 0).day;
        }
        if (months < 0) {
          years--;
          months += 12;
        }
        _calculatedYears = years;
        _calculatedMonths = months;
        _calculatedDays = days;
      });
      widget.onCalculate('Age: $_calculatedYears years, $_calculatedMonths months');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          DropdownButtonFormField<int>(
            value: _selectedCalc,
            decoration: InputDecoration(
              labelText: widget.isArabic ? 'اختر الحاسبة اليومية' : 'Select Utility Calculator',
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
            items: [
              DropdownMenuItem(value: 0, child: Text(widget.isArabic ? 'حاسبة الخصم والنسبة (Discount)' : 'Discount Calculator')),
              DropdownMenuItem(value: 1, child: Text(widget.isArabic ? 'تحويل سعات التخزين (Storage)' : 'Storage Converter')),
              DropdownMenuItem(value: 2, child: Text(widget.isArabic ? 'حاسبة العمر الدقيقة (Age Calculator)' : 'Age Calculator')),
            ],
            onChanged: (val) {
              HapticFeedback.selectionClick();
              setState(() => _selectedCalc = val!);
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _selectedCalc == 0
                ? _buildDiscountView()
                : _selectedCalc == 1
                    ? _buildStorageView()
                    : _buildAgeView(),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountView() {
    return ListView(
      children: [
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(controller: _priceController, keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: widget.isArabic ? 'السعر الأصلي' : 'Original Price', border: const OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: _discController, keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: widget.isArabic ? 'نسبة الخصم (%)' : 'Discount (%)', border: const OutlineInputBorder())),
                const SizedBox(height: 16),
                SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _calculateDiscount, child: Text(widget.isArabic ? 'حساب الخصم' : 'Calculate Discount'))),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    children: [
                      Text('${widget.isArabic ? "مقدار التوفير:" : "You Save:"} ${_savedAmount.toStringAsFixed(2)}'),
                      const Divider(),
                      Text('${widget.isArabic ? "السعر النهائي:" : "Final Price:"} ${_finalPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStorageView() {
    return ListView(
      children: [
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(controller: _gbController, keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: widget.isArabic ? 'المساحة بـ (جيجابايت GB)' : 'Size in (GB)', border: const OutlineInputBorder())),
                const SizedBox(height: 16),
                SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _convertStorage, child: Text(widget.isArabic ? 'تحويل المساحة' : 'Convert Storage'))),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    children: [
                      Text('MB: ${_mbResult.toStringAsFixed(0)}'),
                      const Divider(),
                      Text('KB: ${_kbResult.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.purple)),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAgeView() {
    return ListView(
      children: [
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _pickBirthDate(context),
                    icon: const Icon(Icons.calendar_today_rounded),
                    label: Text(widget.isArabic ? 'اختر تاريخ الميلاد' : 'Select Birth Date'),
                  ),
                ),
                const SizedBox(height: 16),
                if (_selectedDate != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(8)),
                    child: Center(
                      child: Text(
                        widget.isArabic
                            ? 'عمرك هو:\n$_calculatedYears سنة، $_calculatedMonths أشهر، و$_calculatedDays يوم'
                            : 'Your Age:\n$_calculatedYears Years, $_calculatedMonths Months, $_calculatedDays Days',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo, fontSize: 16),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
