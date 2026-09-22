import 'package:flutter/material.dart';

class UnitConverterScreen extends StatefulWidget {
  const UnitConverterScreen({Key? key}) : super(key: key);

  @override
  _UnitConverterScreenState createState() => _UnitConverterScreenState();
}

class _UnitConverterScreenState extends State<UnitConverterScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text("محول الوحدات الشامل", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E293B),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.tealAccent,
          labelColor: Colors.tealAccent,
          unselectedLabelColor: Colors.white60,
          isScrollable: true,
          tabs: const [
            Tab(text: "القياسات والأطوال"),
            Tab(text: "درجات الحرارة"),
            Tab(text: "التخزين الرقمي"),
            Tab(text: "التحويلات المالية"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          MeasurementConverterTab(),
          TemperatureConverterTab(),
          StorageConverterTab(),
          FinancialConverterTab(),
        ],
      ),
    );
  }
}

class MeasurementConverterTab extends StatefulWidget {
  const MeasurementConverterTab({Key? key}) : super(key: key);
  @override
  _MeasurementConverterTabState createState() => _MeasurementConverterTabState();
}

class _MeasurementConverterTabState extends State<MeasurementConverterTab> {
  double _inputVal = 0.0;
  String _fromUnit = "متر";
  String _toUnit = "كيلومتر";
  double _outputVal = 0.0;

  final Map<String, double> _units = {
    "متر": 1.0,
    "كيلومتر": 1000.0,
    "سنتيمتر": 0.01,
    "ميل": 1609.34,
    "قدم": 0.3048,
  };

  void _convert() {
    setState(() {
      double baseInMeters = _inputVal * (_units[_fromUnit] ?? 1.0);
      _outputVal = baseInMeters / (_units[_toUnit] ?? 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          TextField(
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: "أدخل القيمة",
              labelStyle: const TextStyle(color: Colors.white70),
              enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white30), borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.tealAccent), borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: (val) {
              setState(() {
                _inputVal = double.tryParse(val) ?? 0.0;
                _convert();
              });
            },
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              DropdownButton<String>(
                value: _fromUnit,
                dropdownColor: const Color(0xFF1E293B),
                style: const TextStyle(color: Colors.white),
                items: _units.keys.map((String val) => DropdownMenuItem<String>(value: val, child: Text(val))).toList(),
                onChanged: (val) { setState(() { _fromUnit = val!; _convert(); }); },
              ),
              const Icon(Icons.arrow_forward, color: Colors.tealAccent),
              DropdownButton<String>(
                value: _toUnit,
                dropdownColor: const Color(0xFF1E293B),
                style: const TextStyle(color: Colors.white),
                items: _units.keys.map((String val) => DropdownMenuItem<String>(value: val, child: Text(val))).toList(),
                onChanged: (val) { setState(() { _toUnit = val!; _convert(); }); },
              ),
            ],
          ),
          const SizedBox(height: 30),
          Text("النتيجة: $_outputVal $_toUnit", style: const TextStyle(fontSize: 22, color: Colors.tealAccent, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class TemperatureConverterTab extends StatefulWidget {
  const TemperatureConverterTab({Key? key}) : super(key: key);
  @override
  _TemperatureConverterTabState createState() => _TemperatureConverterTabState();
}

class _TemperatureConverterTabState extends State<TemperatureConverterTab> {
  double _inputVal = 0.0;
  String _fromUnit = "سيلسيوس (°C)";
  String _toUnit = "فهرنهايت (°F)";
  double _outputVal = 0.0;

  void _convert() {
    setState(() {
      double celsius = _inputVal;
      if (_fromUnit == "فهرنهايت (°F)") celsius = (_inputVal - 32) * 5 / 9;
      else if (_fromUnit == "كلفن (K)") celsius = _inputVal - 273.15;

      if (_toUnit == "سيلسيوس (°C)") _outputVal = celsius;
      else if (_toUnit == "فهرنهايت (°F)") _outputVal = (celsius * 9 / 5) + 32;
      else if (_toUnit == "كلفن (K)") _outputVal = celsius + 273.15;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> units = ["سيلسيوس (°C)", "فهرنهايت (°F)", "كلفن (K)"];
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          TextField(
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: "درجة الحرارة",
              labelStyle: const TextStyle(color: Colors.white70),
              enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white30), borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: (val) { setState(() { _inputVal = double.tryParse(val) ?? 0.0; _convert(); }); },
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              DropdownButton<String>(
                value: _fromUnit,
                dropdownColor: const Color(0xFF1E293B),
                style: const TextStyle(color: Colors.white),
                items: units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                onChanged: (val) { setState(() { _fromUnit = val!; _convert(); }); },
              ),
              const Icon(Icons.arrow_forward, color: Colors.tealAccent),
              DropdownButton<String>(
                value: _toUnit,
                dropdownColor: const Color(0xFF1E293B),
                style: const TextStyle(color: Colors.white),
                items: units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                onChanged: (val) { setState(() { _toUnit = val!; _convert(); }); },
              ),
            ],
          ),
          const SizedBox(height: 30),
          Text("النتيجة: ${_outputVal.toStringAsFixed(2)} $_toUnit", style: const TextStyle(fontSize: 22, color: Colors.tealAccent, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class StorageConverterTab extends StatefulWidget {
  const StorageConverterTab({Key? key}) : super(key: key);
  @override
  _StorageConverterTabState createState() => _StorageConverterTabState();
}

class _StorageConverterTabState extends State<StorageConverterTab> {
  double _inputVal = 0.0;
  String _fromUnit = "ميغابايت (MB)";
  String _toUnit = "جيجابايت (GB)";
  double _outputVal = 0.0;

  final Map<String, double> _units = {
    "كيلوبايت (KB)": 1024,
    "ميغابايت (MB)": 1024 * 1024,
    "جيجابايت (GB)": 1024 * 1024 * 1024,
    "تيرابايت (TB)": 1024.0 * 1024 * 1024 * 1024,
  };

  void _convert() {
    setState(() {
      double bytes = _inputVal * (_units[_fromUnit] ?? 1.0);
      _outputVal = bytes / (_units[_toUnit] ?? 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          TextField(
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: "حجم التخزين",
              labelStyle: const TextStyle(color: Colors.white70),
              enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white30), borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: (val) { setState(() { _inputVal = double.tryParse(val) ?? 0.0; _convert(); }); },
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              DropdownButton<String>(
                value: _fromUnit,
                dropdownColor: const Color(0xFF1E293B),
                style: const TextStyle(color: Colors.white),
                items: _units.keys.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                onChanged: (val) { setState(() { _fromUnit = val!; _convert(); }); },
              ),
              const Icon(Icons.arrow_forward, color: Colors.tealAccent),
              DropdownButton<String>(
                value: _toUnit,
                dropdownColor: const Color(0xFF1E293B),
                style: const TextStyle(color: Colors.white),
                items: _units.keys.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                onChanged: (val) { setState(() { _toUnit = val!; _convert(); }); },
              ),
            ],
          ),
          const SizedBox(height: 30),
          Text("النتيجة: ${_outputVal.toStringAsFixed(4)} $_toUnit", style: const TextStyle(fontSize: 22, color: Colors.tealAccent, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class FinancialConverterTab extends StatefulWidget {
  const FinancialConverterTab({Key? key}) : super(key: key);
  @override
  _FinancialConverterTabState createState() => _FinancialConverterTabState();
}

class _FinancialConverterTabState extends State<FinancialConverterTab> {
  double _amount = 0.0;
  String _fromCurrency = "دولار أمريكي (USD)";
  String _toCurrency = "ريال سعودي (SAR)";
  double _result = 0.0;

  final Map<String, double> _rates = {
    "دولار أمريكي (USD)": 1.0,
    "يورو (EUR)": 0.92,
    "ريال سعودي (SAR)": 3.75,
    "جنيه مصري (EGP)": 48.5,
  };

  void _convert() {
    setState(() {
      double usdAmount = _amount / (_rates[_fromCurrency] ?? 1.0);
      _result = usdAmount * (_rates[_toCurrency] ?? 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          TextField(
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: "المبلغ المالي",
              labelStyle: const TextStyle(color: Colors.white70),
              enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white30), borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: (val) { setState(() { _amount = double.tryParse(val) ?? 0.0; _convert(); }); },
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              DropdownButton<String>(
                value: _fromCurrency,
                dropdownColor: const Color(0xFF1E293B),
                style: const TextStyle(color: Colors.white),
                items: _rates.keys.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                onChanged: (val) { setState(() { _fromCurrency = val!; _convert(); }); },
              ),
              const Icon(Icons.arrow_forward, color: Colors.tealAccent),
              DropdownButton<String>(
                value: _toCurrency,
                dropdownColor: const Color(0xFF1E293B),
                style: const TextStyle(color: Colors.white),
                items: _rates.keys.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                onChanged: (val) { setState(() { _toCurrency = val!; _convert(); }); },
              ),
            ],
          ),
          const SizedBox(height: 30),
          Text("المبلغ المحول: ${_result.toStringAsFixed(2)} $_toCurrency", style: const TextStyle(fontSize: 22, color: Colors.tealAccent, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
