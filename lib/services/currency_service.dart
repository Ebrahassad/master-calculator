import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// خدمة جلب أسعار صرف العملات اللحظية (القاعدة: USD)
/// تعتمد على واجهة عامة مجانية بدون مفتاح، مع تخزين مؤقت محلي
/// للعمل حتى بدون اتصال بالإنترنت (يعرض آخر سعر محفوظ).
class CurrencyService {
  CurrencyService._();
  static final CurrencyService instance = CurrencyService._();

  static const String _prefsRatesKey = 'live_currency_rates_v1';
  static const String _prefsTimeKey = 'live_currency_rates_time_v1';
  static const Duration _cacheValidFor = Duration(hours: 6);

  Map<String, double>? _memoryRates;
  DateTime? _lastUpdated;

  DateTime? get lastUpdated => _lastUpdated;

  /// أسعار احتياطية تقريبية (تُستخدم فقط إذا تعذر الاتصال ولا يوجد أي تخزين سابق)
  static const Map<String, double> _fallbackRates = {
    'USD': 1.0,
    'EUR': 0.92,
    'GBP': 0.78,
    'LYD': 4.85,
    'SAR': 3.75,
    'AED': 3.67,
    'EGP': 48.5,
    'KWD': 0.31,
    'QAR': 3.64,
    'BHD': 0.376,
    'OMR': 0.385,
    'JOD': 0.709,
    'IQD': 1310,
    'TRY': 34.0,
    'CNY': 7.2,
    'JPY': 152.0,
    'INR': 83.5,
  };

  Future<Map<String, double>> getRates({bool forceRefresh = false}) async {
    if (!forceRefresh && _memoryRates != null) {
      return _memoryRates!;
    }

    final prefs = await SharedPreferences.getInstance();

    if (!forceRefresh) {
      final cachedTimeStr = prefs.getString(_prefsTimeKey);
      final cachedJson = prefs.getString(_prefsRatesKey);
      if (cachedTimeStr != null && cachedJson != null) {
        final cachedTime = DateTime.tryParse(cachedTimeStr);
        if (cachedTime != null && DateTime.now().difference(cachedTime) < _cacheValidFor) {
          _memoryRates = _decode(cachedJson);
          _lastUpdated = cachedTime;
          return _memoryRates!;
        }
      }
    }

    try {
      final rates = await _fetchLive();
      _memoryRates = rates;
      _lastUpdated = DateTime.now();
      await prefs.setString(_prefsRatesKey, jsonEncode(rates));
      await prefs.setString(_prefsTimeKey, _lastUpdated!.toIso8601String());
      return rates;
    } catch (_) {
      // فشل الاتصال: استخدم آخر نسخة محفوظة إن وجدت، وإلا الأسعار الاحتياطية
      final cachedJson = prefs.getString(_prefsRatesKey);
      final cachedTimeStr = prefs.getString(_prefsTimeKey);
      if (cachedJson != null) {
        _memoryRates = _decode(cachedJson);
        _lastUpdated = cachedTimeStr != null ? DateTime.tryParse(cachedTimeStr) : null;
        return _memoryRates!;
      }
      _memoryRates = Map<String, double>.from(_fallbackRates);
      _lastUpdated = null;
      return _memoryRates!;
    }
  }

  Map<String, double> _decode(String json) {
    final map = jsonDecode(json) as Map<String, dynamic>;
    return map.map((k, v) => MapEntry(k, (v as num).toDouble()));
  }

  Future<Map<String, double>> _fetchLive() async {
    // مصدر أساسي: open.er-api.com (مجاني، بدون مفتاح، يغطي أغلب عملات العالم)
    final primary = Uri.parse('https://open.er-api.com/v6/latest/USD');
    final res = await http.get(primary).timeout(const Duration(seconds: 12));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (data['result'] == 'success' && data['rates'] is Map) {
        final rates = data['rates'] as Map<String, dynamic>;
        return rates.map((k, v) => MapEntry(k, (v as num).toDouble()));
      }
    }
    throw Exception('primary_source_failed');
  }

  /// تحويل مبلغ من عملة إلى أخرى بالاعتماد على أسعار الصرف القائمة على USD
  double convert(double amount, String fromCode, String toCode, Map<String, double> rates) {
    final fromRate = rates[fromCode];
    final toRate = rates[toCode];
    if (fromRate == null || toRate == null || fromRate == 0) return 0;
    final usdValue = amount / fromRate;
    return usdValue * toRate;
  }
}
