import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import '../widgets/common.dart';
import '../data/currencies.dart';
import '../data/units.dart';
import '../services/currency_service.dart';

class ConversionsTab extends StatefulWidget {
  const ConversionsTab({super.key});

  @override
  State<ConversionsTab> createState() => _ConversionsTabState();
}

class _ConversionsTabState extends State<ConversionsTab> {
  // 'currency' أو أحد مفاتيح kUnitCategories
  String _categoryKey = 'currency';

  final _inputC = TextEditingController(text: '1');
  String _fromCurrency = 'USD';
  String _toCurrency = 'LYD';

  final Map<String, String> _fromUnit = {};
  final Map<String, String> _toUnit = {};

  Map<String, double>? _rates;
  bool _loadingRates = true;
  bool _offline = false;

  double _resultVal = 0;

  @override
  void initState() {
    super.initState();
    for (final cat in kUnitCategories) {
      _fromUnit[cat.key] = cat.units.first.key;
      _toUnit[cat.key] = cat.units.length > 1 ? cat.units[1].key : cat.units.first.key;
    }
    _loadRates();
  }

  Future<void> _loadRates({bool force = false}) async {
    setState(() => _loadingRates = true);
    try {
      final rates = await CurrencyService.instance.getRates(forceRefresh: force);
      setState(() {
        _rates = rates;
        _offline = CurrencyService.instance.lastUpdated == null;
        _loadingRates = false;
      });
    } catch (_) {
      setState(() {
        _offline = true;
        _loadingRates = false;
      });
    }
    _convert();
  }

  double _v() => parseNum(_inputC.text);

  void _convert() {
    if (_categoryKey == 'currency') {
      if (_rates == null) return;
      setState(() {
        _resultVal = CurrencyService.instance.convert(_v(), _fromCurrency, _toCurrency, _rates!);
      });
      return;
    }

    final cat = kUnitCategories.firstWhere((c) => c.key == _categoryKey);
    final from = cat.units.firstWhere((u) => u.key == _fromUnit[_categoryKey]);
    final to = cat.units.firstWhere((u) => u.key == _toUnit[_categoryKey]);
    final val = _v();

    if (cat.isTemperature) {
      setState(() => _resultVal = _convertTemperature(val, from.key, to.key));
      return;
    }

    if (cat.key == 'fuel') {
      setState(() => _resultVal = _convertFuel(val, from.key, to.key));
      return;
    }

    final baseVal = val * from.toBase;
    setState(() => _resultVal = baseVal / to.toBase);
  }

  double _convertTemperature(double val, String from, String to) {
    // تحويل عبر المئوية كوسيط
    double celsius;
    switch (from) {
      case 'f':
        celsius = (val - 32) * 5 / 9;
        break;
      case 'k':
        celsius = val - 273.15;
        break;
      default:
        celsius = val;
    }
    switch (to) {
      case 'f':
        return celsius * 9 / 5 + 32;
      case 'k':
        return celsius + 273.15;
      default:
        return celsius;
    }
  }

  double _convertFuel(double val, String from, String to) {
    if (val == 0) return 0;
    // نحول كل شيء أولًا إلى km/L كوسيط
    double kml;
    switch (from) {
      case 'l100km':
        kml = 100 / val;
        break;
      case 'mpg_us':
        kml = val * 0.425144;
        break;
      case 'mpg_uk':
        kml = val * 0.354006;
        break;
      default:
        kml = val;
    }
    switch (to) {
      case 'l100km':
        return kml == 0 ? 0 : 100 / kml;
      case 'mpg_us':
        return kml / 0.425144;
      case 'mpg_uk':
        return kml / 0.354006;
      default:
        return kml;
    }
  }

  void _swap() {
    setState(() {
      if (_categoryKey == 'currency') {
        final t = _fromCurrency;
        _fromCurrency = _toCurrency;
        _toCurrency = t;
      } else {
        final t = _fromUnit[_categoryKey]!;
        _fromUnit[_categoryKey] = _toUnit[_categoryKey]!;
        _toUnit[_categoryKey] = t;
      }
      _convert();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Lang.of(context).isArabic;
    final isCurrency = _categoryKey == 'currency';

    final categoryItems = ['currency', ...kUnitCategories.map((c) => c.key)];
    String categoryLabel(String key) {
      if (key == 'currency') return tr(context, 'currency_category');
      final cat = kUnitCategories.firstWhere((c) => c.key == key);
      return tr(context, cat.titleKey);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          AppDropdown<String>(
            value: _categoryKey,
            items: categoryItems,
            labelBuilder: categoryLabel,
            onChanged: (v) => setState(() {
              _categoryKey = v;
              _convert();
            }),
          ),
          const SizedBox(height: 20),
          AppNumberField(
            controller: _inputC,
            label: tr(context, 'value_to_convert'),
            allowNegative: true,
            onChanged: (_) => _convert(),
          ),
          const SizedBox(height: 15),
          if (isCurrency) _currencyRow(isAr) else _unitRow(isAr),
          const SizedBox(height: 20),
          if (isCurrency) _rateStatusBar(context),
          if (isCurrency) const SizedBox(height: 10),
          ResultCard(lines: [
            ResultLine(
              tr(context, 'converted_value'),
              _resultVal.toStringAsFixed(_categoryKey == 'currency' ? 4 : 4),
              color: Colors.tealAccent,
              big: true,
            ),
          ]),
        ],
      ),
    );
  }

  Widget _currencyRow(bool isAr) {
    return Row(
      children: [
        Expanded(
          child: AppDropdown<String>(
            value: _fromCurrency,
            items: kCurrencies.map((c) => c.code).toList(),
            labelBuilder: (code) => kCurrencies.firstWhere((c) => c.code == code).label(isAr),
            onChanged: (v) => setState(() {
              _fromCurrency = v;
              _convert();
            }),
          ),
        ),
        IconButton(onPressed: _swap, icon: const Icon(Icons.swap_horiz, color: Colors.blueAccent)),
        Expanded(
          child: AppDropdown<String>(
            value: _toCurrency,
            items: kCurrencies.map((c) => c.code).toList(),
            labelBuilder: (code) => kCurrencies.firstWhere((c) => c.code == code).label(isAr),
            onChanged: (v) => setState(() {
              _toCurrency = v;
              _convert();
            }),
          ),
        ),
      ],
    );
  }

  Widget _unitRow(bool isAr) {
    final cat = kUnitCategories.firstWhere((c) => c.key == _categoryKey);
    return Row(
      children: [
        Expanded(
          child: AppDropdown<String>(
            value: _fromUnit[_categoryKey]!,
            items: cat.units.map((u) => u.key).toList(),
            labelBuilder: (key) => cat.units.firstWhere((u) => u.key == key).label(isAr),
            onChanged: (v) => setState(() {
              _fromUnit[_categoryKey] = v;
              _convert();
            }),
          ),
        ),
        IconButton(onPressed: _swap, icon: const Icon(Icons.swap_horiz, color: Colors.blueAccent)),
        Expanded(
          child: AppDropdown<String>(
            value: _toUnit[_categoryKey]!,
            items: cat.units.map((u) => u.key).toList(),
            labelBuilder: (key) => cat.units.firstWhere((u) => u.key == key).label(isAr),
            onChanged: (v) => setState(() {
              _toUnit[_categoryKey] = v;
              _convert();
            }),
          ),
        ),
      ],
    );
  }

  Widget _rateStatusBar(BuildContext context) {
    final lastUpdated = CurrencyService.instance.lastUpdated;
    String statusText;
    if (_loadingRates) {
      statusText = tr(context, 'fetching_rates');
    } else if (_offline || lastUpdated == null) {
      statusText = tr(context, 'offline_rates');
    } else {
      final t = lastUpdated;
      final timeStr = '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
      statusText = '${tr(context, 'last_updated')}: $timeStr';
    }
    return Row(
      children: [
        Expanded(
          child: Text(
            statusText,
            style: TextStyle(color: _offline ? Colors.orangeAccent : Colors.white54, fontSize: 12),
          ),
        ),
        if (_loadingRates)
          const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.tealAccent))
        else
          InkWell(
            onTap: () => _loadRates(force: true),
            child: Row(
              children: [
                const Icon(Icons.refresh, size: 16, color: Colors.tealAccent),
                const SizedBox(width: 4),
                Text(tr(context, 'refresh_rates'), style: const TextStyle(color: Colors.tealAccent, fontSize: 12)),
              ],
            ),
          ),
      ],
    );
  }
}
