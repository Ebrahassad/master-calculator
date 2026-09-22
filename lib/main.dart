import 'package:flutter/material.dart';

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

  void _toggleLocale() {
    setState(() {
      _currentLocale = _currentLocale.languageCode == 'ar'
          ? const Locale('en')
          : const Locale('ar');
    });
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
      home: HomeScreen(onToggleLang: _toggleLocale, isArabic: isAr),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final VoidCallback onToggleLang;
  final bool isArabic;

  const HomeScreen({super.key, required this.onToggleLang, required this.isArabic});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      FinancialModule(isArabic: widget.isArabic),
      HealthModule(isArabic: widget.isArabic),
      UtilitiesModule(isArabic: widget.isArabic),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isArabic
              ? ['المال والأعمال', 'الصحة واللياقة', 'الحاسبات اليومية'][_selectedIndex]
              : ['Financial & Business', 'Health & Fitness', 'Everyday Utilities'][_selectedIndex],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.language_rounded),
            onPressed: widget.onToggleLang,
            tooltip: widget.isArabic ? 'Switch to English' : 'التحويل إلى العربية',
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
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
// 1. FINANCIAL MODULE (Dropdown Selector)
// ==========================================
class FinancialModule extends StatefulWidget {
  final bool isArabic;
  const FinancialModule({super.key, required this.isArabic});

  @override
  State<FinancialModule> createState() => _FinancialModuleState();
}

class _FinancialModuleState extends State<FinancialModule> {
  int _selectedCalc = 0; // 0: VAT, 1: Loan

  // VAT Controllers
  final TextEditingController _vatAmountController = TextEditingController();
  final TextEditingController _vatRateController = TextEditingController(text: '15');
  double _vatResult = 0.0, _totalWithVat = 0.0;

  // Loan Controllers
  final TextEditingController _loanAmountController = TextEditingController();
  final TextEditingController _loanInterestController = TextEditingController(text: '5');
  final TextEditingController _loanYearsController = TextEditingController(text: '3');
  double _monthlyInstallment = 0.0, _totalInterest = 0.0;

  void _calculateVat() {
    double amt = double.tryParse(_vatAmountController.text) ?? 0.0;
    double rate = double.tryParse(_vatRateController.text) ?? 0.0;
    setState(() {
      _vatResult = amt * (rate / 100);
      _totalWithVat = amt + _vatResult;
    });
  }

  void _calculateLoan() {
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
              labelText: widget.isArabic ? 'اختر الحاسبة المالية' : 'Select Financial Calculator',
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
            items: [
              DropdownMenuItem(
                value: 0,
                child: Text(widget.isArabic ? 'حاسبة ضريبة القيمة المضافة (VAT)' : 'VAT Calculator'),
              ),
              DropdownMenuItem(
                value: 1,
                child: Text(widget.isArabic ? 'حاسبة القروض والأقساط (Loan & EMI)' : 'Loan & EMI Calculator'),
              ),
            ],
            onChanged: (val) => setState(() => _selectedCalc = val!),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _selectedCalc == 0 ? _buildVatView() : _buildLoanView(),
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
              crossAxisAlignment: CrossAxisAlignment.start,
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
                      Text('${widget.isArabic ? "الإجمالي الشامل:" : "Total with VAT:"} ${_totalWithVat.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
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
    return ListView(
      children: [
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _calculateLoan, child: Text(widget.isArabic ? 'حساب القسط الشهري' : 'Calculate EMI'))),
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
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// مساعد الرياضيات للأسس
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
// 2. HEALTH MODULE (Dropdown Selector)
// ==========================================
class HealthModule extends StatefulWidget {
  final bool isArabic;
  const HealthModule({super.key, required this.isArabic});

  @override
  State<HealthModule> createState() => _HealthModuleState();
}

class _HealthModuleState extends State<HealthModule> {
  int _selectedCalc = 0; // 0: BMI, 1: Calories

  // BMI
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  double _bmiValue = 0.0;
  String _bmiStatus = '';

  // Calories
  final TextEditingController _calWeight = TextEditingController();
  final TextEditingController _calHeight = TextEditingController();
  final TextEditingController _calAge = TextEditingController();
  double _dailyCalories = 0.0;

  void _calculateBmi() {
    double w = double.tryParse(_weightController.text) ?? 0.0;
    double hCm = double.tryParse(_heightController.text) ?? 0.0;
    if (w > 0 && hCm > 0) {
      double hM = hCm / 100;
      double bmi = w / (hM * hM);
      String status = '';
      if (bmi < 18.5) {
        status = widget.isArabic ? 'نقص في الوزن (Underweight)' : 'Underweight';
      } else if (bmi < 25) {
        status = widget.isArabic ? 'وزن مثالي وطبيعي (Normal)' : 'Normal Weight';
      } else if (bmi < 30) {
        status = widget.isArabic ? 'زيادة في الوزن (Overweight)' : 'Overweight';
      } else {
        status = widget.isArabic ? 'سمنة مفرطة (Obese)' : 'Obese';
      }
      setState(() {
        _bmiValue = bmi;
        _bmiStatus = status;
      });
    }
  }

  void _calculateCalories() {
    double w = double.tryParse(_calWeight.text) ?? 0.0;
    double h = double.tryParse(_calHeight.text) ?? 0.0;
    double age = double.tryParse(_calAge.text) ?? 0.0;
    if (w > 0 && h > 0 && age > 0) {
      double bmr = 10 * w + 6.25 * h - 5 * age + 5;
      setState(() {
        _dailyCalories = bmr * 1.375;
      });
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
              DropdownMenuItem(value: 1, child: Text(widget.isArabic ? 'السعرات الحرارية (Calories)' : 'Calorie Calculator')),
            ],
            onChanged: (val) => setState(() => _selectedCalc = val!),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _selectedCalc == 0 ? _buildBmiView() : _buildCaloriesView(),
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
                        Text('BMI: ${_bmiValue.toStringAsFixed(1)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal)),
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
                        '${widget.isArabic ? "احتياجك اليومي:" : "Daily Need:"} ${_dailyCalories.toStringAsFixed(0)} ${widget.isArabic ? "سعرة حرارية" : "Calories"}',
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
}

// ==========================================
// 3. UTILITIES MODULE (Dropdown Selector)
// ==========================================
class UtilitiesModule extends StatefulWidget {
  final bool isArabic;
  const UtilitiesModule({super.key, required this.isArabic});

  @override
  State<UtilitiesModule> createState() => _UtilitiesModuleState();
}

class _UtilitiesModuleState extends State<UtilitiesModule> {
  int _selectedCalc = 0; // 0: Discount, 1: Storage

  // Discount
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _discController = TextEditingController();
  double _finalPrice = 0.0, _savedAmount = 0.0;

  // Storage
  final TextEditingController _gbController = TextEditingController();
  double _mbResult = 0.0, _kbResult = 0.0;

  void _calculateDiscount() {
    double price = double.tryParse(_priceController.text) ?? 0.0;
    double disc = double.tryParse(_discController.text) ?? 0.0;
    setState(() {
      _savedAmount = price * (disc / 100);
      _finalPrice = price - _savedAmount;
    });
  }

  void _convertStorage() {
    double gb = double.tryParse(_gbController.text) ?? 0.0;
    setState(() {
      _mbResult = gb * 1024;
      _kbResult = gb * 1024 * 1024;
    });
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
            ],
            onChanged: (val) => setState(() => _selectedCalc = val!),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _selectedCalc == 0 ? _buildDiscountView() : _buildStorageView(),
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
                      Text('${widget.isArabic ? "مقدرا التوفير:" : "You Save:"} ${_savedAmount.toStringAsFixed(2)}'),
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
}
