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

  const HomeScreen({
    super.key,
    required this.onToggleLang,
    required this.isArabic,
  });

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

// 1. Financial Module (VAT Calculator)
class FinancialModule extends StatefulWidget {
  final bool isArabic;
  const FinancialModule({super.key, required this.isArabic});

  @override
  State<FinancialModule> createState() => _FinancialModuleState();
}

class _FinancialModuleState extends State<FinancialModule> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _vatRateController = TextEditingController(text: '15');
  double _vatResult = 0.0;
  double _totalWithVat = 0.0;

  void _calculateVat() {
    double amount = double.tryParse(_amountController.text) ?? 0.0;
    double rate = double.tryParse(_vatRateController.text) ?? 0.0;
    setState(() {
      _vatResult = amount * (rate / 100);
      _totalWithVat = amount + _vatResult;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isArabic ? 'حاسبة ضريبة القيمة المضافة' : 'VAT Calculator',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: widget.isArabic ? 'المبلغ الأساسي' : 'Base Amount',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _vatRateController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: widget.isArabic ? 'نسبة الضريبة (%)' : 'VAT Rate (%)',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _calculateVat,
                    icon: const Icon(Icons.check_circle_outline),
                    label: Text(widget.isArabic ? 'حساب الضريبة' : 'Calculate VAT'),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(widget.isArabic ? 'قيمة الضريبة:' : 'VAT Amount:'),
                          Text('${_vatResult.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(widget.isArabic ? 'الإجمالي الشامل:' : 'Total with VAT:', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('${_totalWithVat.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// 2. Health Module (BMI Calculator)
class HealthModule extends StatefulWidget {
  final bool isArabic;
  const HealthModule({super.key, required this.isArabic});

  @override
  State<HealthModule> createState() => _HealthModuleState();
}

class _HealthModuleState extends State<HealthModule> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  double _bmiValue = 0.0;
  String _bmiStatus = '';

  void _calculateBmi() {
    double weight = double.tryParse(_weightController.text) ?? 0.0;
    double heightCm = double.tryParse(_heightController.text) ?? 0.0;
    if (weight > 0 && heightCm > 0) {
      double heightM = heightCm / 100;
      double bmi = weight / (heightM * heightM);
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

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isArabic ? 'حاسبة مؤشر كتلة الجسم (BMI)' : 'BMI Calculator',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: widget.isArabic ? 'الوزن (كجم)' : 'Weight (kg)',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _heightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: widget.isArabic ? 'الطول (سم)' : 'Height (cm)',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _calculateBmi,
                    icon: const Icon(Icons.health_and_safety_outlined),
                    label: Text(widget.isArabic ? 'احسب المؤشر' : 'Calculate BMI'),
                  ),
                ),
                const SizedBox(height: 16),
                if (_bmiValue > 0)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'BMI: ${_bmiValue.toStringAsFixed(1)}',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal),
                        ),
                        const SizedBox(height: 8),
                        Text(_bmiStatus, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// 3. Utilities Module (Discount & Percentage Calculator)
class UtilitiesModule extends StatefulWidget {
  final bool isArabic;
  const UtilitiesModule({super.key, required this.isArabic});

  @override
  State<UtilitiesModule> createState() => _UtilitiesModuleState();
}

class _UtilitiesModuleState extends State<UtilitiesModule> {
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  double _finalPrice = 0.0;
  double _savedAmount = 0.0;

  void _calculateDiscount() {
    double price = double.tryParse(_priceController.text) ?? 0.0;
    double discount = double.tryParse(_discountController.text) ?? 0.0;
    double saved = price * (discount / 100);
    setState(() {
      _savedAmount = saved;
      _finalPrice = price - saved;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isArabic ? 'حاسبة الخصم والنسبة المئوية' : 'Discount & Percentage Calculator',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: widget.isArabic ? 'السعر الأصلي' : 'Original Price',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _discountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: widget.isArabic ? 'نسبة الخصم (%)' : 'Discount Percentage (%)',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _calculateDiscount,
                    icon: const Icon(Icons.percent_rounded),
                    label: Text(widget.isArabic ? 'احسب الخصم' : 'Calculate Discount'),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(widget.isArabic ? 'مقدار التوفير:' : 'You Save:'),
                          Text('${_savedAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(widget.isArabic ? 'السعر النهائي:' : 'Final Price:', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('${_finalPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
