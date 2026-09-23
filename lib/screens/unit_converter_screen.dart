import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UnitConverterScreen extends StatefulWidget {
  const UnitConverterScreen({Key? key}) : super(key: key);

  @override
  _UnitConverterScreenState createState() => _UnitConverterScreenState();
}

class _UnitConverterScreenState extends State<UnitConverterScreen> {
  String _selectedCategory = 'التحويلات المالية';

  final List<String> _categories = [
    'التحويلات المالية',
    'القياسات والأطوال',
    'درجات الحرارة',
    'التخزين الرقمي',
    'الوزن والكتلة',
    'السرعة',
    'الزمن',
  ];

  double _amount = 1.0;
  String _fromCurrency = 'دولار أمريكي (USD)';
  String _toCurrency = 'دينار ليبي (LYD)';
  double _result = 0.0;
  bool _isLoading = false;
  String _statusMessage = '';

  final Map<String, String> _currencyCodes = {
    'دولار أمريكي (USD)': 'USD',
    'دينار ليبي (LYD)': 'LYD',
    'ريال سعودي (SAR)': 'SAR',
    'يورو (EUR)': 'EUR',
    'جنيه إسترليني (GBP)': 'GBP',
    'درهم إماراتي (AED)': 'AED',
    'جنيه مصري (EGP)': 'EGP',
    'دينار كويتي (KWD)': 'KWD',
    'ريال قطري (QAR)': 'QAR',
    'دينار بحريني (BHD)': 'BHD',
    'ريال عماني (OMR)': 'OMR',
    'دينار أردني (JOD)': 'JOD',
    'دولار كندي (CAD)': 'CAD',
    'دولار أسترالي (AUD)': 'AUD',
    'ين ياباني (JPY)': 'JPY',
    'فرنك سويسري (CHF)': 'CHF',
    'يوان صيني (CNY)': 'CNY',
    'روبية هندية (INR)': 'INR',
    'ليرة تركية (TRY)': 'TRY',
    'درهم مغربي (MAD)': 'MAD',
    'دينار تونسي (TND)': 'TND',
    'دينار جزائري (DZD)': 'DZD',
    'دينار عراقي (IQD)': 'IQD',
  };

  final Map<String, double> _rates = {
    'USD': 1.0,
    'LYD': 4.85,
    'SAR': 3.75,
    'EUR': 0.91,
    'GBP': 0.76,
    'AED': 3.67,
    'EGP': 49.0,
    'KWD': 0.31,
    'QAR': 3.64,
    'BHD': 0.376,
    'OMR': 0.385,
    'JOD': 0.709,
    'CAD': 1.35,
    'AUD': 1.50,
    'JPY': 148.0,
    'CHF': 0.86,
    'CNY': 7.15,
    'INR': 83.5,
    'TRY': 34.0,
    'MAD': 9.95,
    'TND': 3.12,
    'DZD': 134.5,
    'IQD': 1310.0,
  };

  @override
  void initState() {
    super.initState();
    _fetchLiveRates();
  }

  Future<void> _fetchLiveRates() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'جاري تحديث أسعار الصرف الحية...';
    });

    try {
      final response = await http.get(Uri.parse('https://open.er-api.com/v6/latest/USD')).timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['result'] == 'success') {
          final ratesMap = data['rates'] as Map<String, dynamic>;
          setState(() {
            ratesMap.forEach((key, value) {
              if (_rates.containsKey(key)) {
                _rates[key] = (value as num).toDouble();
              }
            });
            _statusMessage = 'تم تحديث الأسعار الحية ✓';
            _isLoading = false;
          });
          _convertCurrency();
          return;
        }
      }
    } catch (e) {
      // Fallback
    }

    setState(() {
      _statusMessage = 'وضع عدم الاتصال (الأسعار المحفوظة)';
      _isLoading = false;
    });
    _convertCurrency();
  }

  void _convertCurrency() {
    setState(() {
      String fromCode = _currencyCodes[_fromCurrency] ?? 'USD';
      String toCode = _currencyCodes[_toCurrency] ?? 'LYD';
      
      double fromRate = _rates[fromCode] ?? 1.0;
      double toRate = _rates[toCode] ?? 1.0;

      double usdAmount = _amount / fromRate;
      _result = usdAmount * toRate;
    });
  }

  void _swapCurrencies() {
    setState(() {
      String temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
      _convertCurrency();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<String> currencyKeys = _currencyCodes.keys.toList();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        title: const Text('محول الوحدات الشامل', style: TextStyle(color: Colors.white, fontSize: 18)),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(65.0),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            color: const Color(0xFF181818),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.category_outlined, color: Colors.blueAccent, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'نوع التحويل: ',
                  style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2C),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.blueAccent.withOpacity(0.4)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        dropdownColor: const Color(0xFF1E1E1E),
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.blueAccent),
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                        isExpanded: true,
                        items: _categories.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category, overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedCategory = newValue;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF181818), Color(0xFF121212)],
          ),
        ),
        child: _buildSelectedBody(currencyKeys),
      ),
    );
  }

  Widget _buildSelectedBody(List<String> currencyKeys) {
    if (_selectedCategory == 'التحويلات المالية') {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            if (_isLoading || _statusMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isLoading) ...[
                      const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      _statusMessage,
                      style: TextStyle(fontSize: 13, color: _isLoading ? Colors.blueAccent : Colors.greenAccent),
                    ),
                  ],
                ),
              ),
            TextField(
              controller: TextEditingController(text: _amount == 0.0 ? '' : _amount.toString())
                ..selection = TextSelection.fromPosition(TextPosition(offset: (_amount == 0.0 ? '' : _amount.toString()).length)),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: 'المبلغ المالي',
                labelStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.attach_money, color: Colors.blueAccent),
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white24), borderRadius: BorderRadius.circular(16)),
                focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.blueAccent, width: 2), borderRadius: BorderRadius.circular(16)),
              ),
              onChanged: (val) {
                setState(() {
                  _amount = double.tryParse(val) ?? 0.0;
                  _convertCurrency();
                });
              },
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _fromCurrency,
              dropdownColor: const Color(0xFF1E1E1E),
              style: const TextStyle(color: Colors.white, fontSize: 15),
              decoration: InputDecoration(
                labelText: 'من عملة الأساس',
                labelStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.arrow_upward, color: Colors.greenAccent),
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white24), borderRadius: BorderRadius.circular(16)),
                focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.blueAccent, width: 2), borderRadius: BorderRadius.circular(16)),
              ),
              items: currencyKeys.map((String currency) {
                return DropdownMenuItem<String>(
                  value: currency,
                  child: Text(currency),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _fromCurrency = newValue;
                    _convertCurrency();
                  });
                }
              },
            ),
            const SizedBox(height: 12),
            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24),
                ),
                child: IconButton(
                  onPressed: _swapCurrencies,
                  icon: const Icon(Icons.swap_vert, size: 28, color: Colors.blueAccent),
                  tooltip: 'تبديل العملات',
                ),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _toCurrency,
              dropdownColor: const Color(0xFF1E1E1E),
              style: const TextStyle(color: Colors.white, fontSize: 15),
              decoration: InputDecoration(
                labelText: 'إلى العملة المستهدفة',
                labelStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.arrow_downward, color: Colors.orangeAccent),
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white24), borderRadius: BorderRadius.circular(16)),
                focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.blueAccent, width: 2), borderRadius: BorderRadius.circular(16)),
              ),
              items: currencyKeys.map((String currency) {
                return DropdownMenuItem<String>(
                  value: currency,
                  child: Text(currency),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _toCurrency = newValue;
                    _convertCurrency();
                  });
                }
              },
            ),
            const SizedBox(height: 28),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueAccent.withOpacity(0.25), Colors.blueAccent.withOpacity(0.1)],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.blueAccent.withOpacity(0.4)),
              ),
              child: Column(
                children: [
                  const Text('المبلغ المحول بدقة', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 10),
                  Text(
                    '${_result.toStringAsFixed(2)} $_toCurrency',
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _fetchLiveRates,
              icon: const Icon(Icons.refresh),
              label: const Text('تحديث الأسعار المباشرة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      );
    } else {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.construction_rounded, size: 64, color: Colors.blueAccent),
              const SizedBox(height: 16),
              Text(
                'قسم "$_selectedCategory" قيد التحديث',
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'سيتم إضافة حاسبة هذا القسم قريباً بتصميم احترافي.',
                style: TextStyle(color: Colors.white60, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
  }
}
