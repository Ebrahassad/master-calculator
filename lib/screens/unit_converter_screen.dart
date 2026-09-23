import 'package:flutter/material.dart';

class UnitConverterScreen extends StatefulWidget {
  const UnitConverterScreen({Key? key}) : super(key: key);

  @override
  _UnitConverterScreenState createState() => _UnitConverterScreenState();
}

class _UnitConverterScreenState extends State<UnitConverterScreen> {
  final TextEditingController _valueController = TextEditingController(text: '1');
  String _selectedCategory = 'الطول';
  String _fromUnit = 'متر';
  String _toUnit = 'كيلومتر';
  double _result = 0.001;

  final Map<String, List<String>> _units = {
    'الطول': ['متر', 'كيلومتر', 'سنتيمتر', 'ملليمتر', 'ميل'],
    'الوزن': ['كجم', 'جرام', 'رطل', 'أوقية'],
    'المساحة': ['متر مربع', 'كيلومتر مربع', 'هكتار', 'فدان'],
  };

  final Map<String, Map<String, double>> _conversionRates = {
    'الطول': {
      'متر': 1.0,
      'كيلومتر': 0.001,
      'سنتيمتر': 100.0,
      'ملليمتر': 1000.0,
      'ميل': 0.000621371,
    },
    'الوزن': {
      'كجم': 1.0,
      'جرام': 1000.0,
      'رطل': 2.20462,
      'أوقية': 35.274,
    },
    'المساحة': {
      'متر مربع': 1.0,
      'كيلومتر مربع': 0.000001,
      'هكتار': 0.0001,
      'فدان': 0.0002381,
    },
  };

  void _convert() {
    double val = double.tryParse(_valueController.text) ?? 0.0;
    Map<String, double>? categoryRates = _conversionRates[_selectedCategory];
    if (categoryRates != null) {
      double? fromRate = categoryRates[_fromUnit];
      double? toRate = categoryRates[_toUnit];
      if (fromRate != null && toRate != null) {
        setState(() {
          double baseVal = val / fromRate;
          _result = baseVal * toRate;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.blueAccent, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.blueAccent.withOpacity(0.4),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.functions, color: Colors.white, size: 20),
        ),
      ),

        title: const Text('محول الوحدات الشامل', style: TextStyle(fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    dropdownColor: const Color(0xFF2C2C2C),
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: InputDecoration(
                      labelText: 'فئة التحويل',
                      labelStyle: const TextStyle(color: Colors.white60),
                      filled: true,
                      fillColor: const Color(0xFF2C2C2C),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                    items: _units.keys.map((cat) {
                      return DropdownMenuItem(value: cat, child: Text(cat));
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedCategory = val!;
                        _fromUnit = _units[_selectedCategory]![0];
                        _toUnit = _units[_selectedCategory]![1];
                        _convert();
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _valueController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: InputDecoration(
                      labelText: 'القيمة المراد تحويلها',
                      labelStyle: const TextStyle(color: Colors.white60),
                      prefixIcon: const Icon(Icons.edit, color: Colors.blueAccent),
                      filled: true,
                      fillColor: const Color(0xFF2C2C2C),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _fromUnit,
                          dropdownColor: const Color(0xFF2C2C2C),
                          style: const TextStyle(color: Colors.white, fontSize: 15),
                          decoration: InputDecoration(
                            labelText: 'من وحدة',
                            labelStyle: const TextStyle(color: Colors.white60),
                            filled: true,
                            fillColor: const Color(0xFF2C2C2C),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                          ),
                          items: _units[_selectedCategory]!.map((u) {
                            return DropdownMenuItem(value: u, child: Text(u));
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _fromUnit = val!;
                              _convert();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _toUnit,
                          dropdownColor: const Color(0xFF2C2C2C),
                          style: const TextStyle(color: Colors.white, fontSize: 15),
                          decoration: InputDecoration(
                            labelText: 'إلى وحدة',
                            labelStyle: const TextStyle(color: Colors.white60),
                            filled: true,
                            fillColor: const Color(0xFF2C2C2C),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                          ),
                          items: _units[_selectedCategory]!.map((u) {
                            return DropdownMenuItem(value: u, child: Text(u));
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _toUnit = val!;
                              _convert();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _convert,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('تحويل', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.blueAccent.withOpacity(0.25), Colors.blueAccent.withOpacity(0.1)]),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blueAccent.withOpacity(0.4)),
              ),
              child: Column(
                children: [
                  const Text('النتيجة', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 6),
                  Text(_result.toStringAsFixed(4), style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(_toUnit, style: const TextStyle(color: Colors.blueAccent, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
