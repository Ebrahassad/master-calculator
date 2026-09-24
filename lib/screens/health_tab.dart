import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import '../widgets/common.dart';

class HealthTab extends StatefulWidget {
  const HealthTab({super.key});

  @override
  State<HealthTab> createState() => _HealthTabState();
}

class _HealthTabState extends State<HealthTab> {
  String _calc = 'h_bmi';
  String _gender = 'h_male';
  String _activity = 'normal';

  final _weight = TextEditingController(text: '70');
  final _height = TextEditingController(text: '175');
  final _age = TextEditingController(text: '25');
  final _extra1 = TextEditingController(text: '0'); // رقبة / سكر تراكمي / أيام
  final _extra2 = TextEditingController(text: '0'); // خصر

  List<ResultLine> _results = [];

  static const List<String> _calcKeys = [
    'h_bmi',
    'h_bmr',
    'h_calories',
    'h_ideal_weight',
    'h_body_fat',
    'h_water',
    'h_hba1c',
    'h_heart_rate',
    'h_pregnancy',
  ];

  static const Map<String, double> _activityFactors = {
    'sedentary': 1.2,
    'light': 1.375,
    'normal': 1.55,
    'active': 1.725,
    'very_active': 1.9,
  };

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  double _v(TextEditingController c) => parseNum(c.text);
  bool get _isMale => _gender == 'h_male';

  void _calculate() {
    final w = _v(_weight);
    final h = _v(_height);
    final age = _v(_age);
    final e1 = _v(_extra1);
    final e2 = _v(_extra2);
    List<ResultLine> r = [];

    switch (_calc) {
      case 'h_bmi':
        if (h > 0) {
          final m = h / 100;
          final bmi = w / (m * m);
          String status;
          if (bmi < 18.5) {
            status = tr(context, 'h_status_low');
          } else if (bmi < 25) {
            status = tr(context, 'h_status_normal');
          } else if (bmi < 30) {
            status = tr(context, 'h_status_over');
          } else {
            status = tr(context, 'h_status_obese');
          }
          r = [
            ResultLine(tr(context, 'result'), bmi.toStringAsFixed(1), color: Colors.tealAccent, big: true),
            ResultLine(tr(context, 'h_result_health'), status, color: Colors.amberAccent),
          ];
        }
        break;
      case 'h_bmr':
        double bmr;
        if (_isMale) {
          bmr = (10 * w) + (6.25 * h) - (5 * age) + 5;
        } else {
          bmr = (10 * w) + (6.25 * h) - (5 * age) - 161;
        }
        r = [
          ResultLine(tr(context, 'h_bmr'), '${bmr.toStringAsFixed(0)} kcal/يوم', color: Colors.tealAccent, big: true),
        ];
        break;
      case 'h_calories':
        double bmr;
        if (_isMale) {
          bmr = (10 * w) + (6.25 * h) - (5 * age) + 5;
        } else {
          bmr = (10 * w) + (6.25 * h) - (5 * age) - 161;
        }
        final factor = _activityFactors[_activity] ?? 1.55;
        final maintain = bmr * factor;
        r = [
          ResultLine(tr(context, 'h_calories'), '${maintain.toStringAsFixed(0)} kcal', color: Colors.tealAccent, big: true),
          ResultLine('فقدان الوزن (عجز 20%)', '${(maintain * 0.8).toStringAsFixed(0)} kcal', color: Colors.orangeAccent),
          ResultLine('زيادة الوزن (فائض 15%)', '${(maintain * 1.15).toStringAsFixed(0)} kcal', color: Colors.greenAccent),
        ];
        break;
      case 'h_ideal_weight':
        // معادلة Devine
        double ideal;
        if (h <= 0) {
          ideal = 0;
        } else if (_isMale) {
          ideal = 50 + 2.3 * ((h / 2.54) - 60);
        } else {
          ideal = 45.5 + 2.3 * ((h / 2.54) - 60);
        }
        r = [
          ResultLine(tr(context, 'h_ideal_weight'), '${ideal.clamp(0, 999).toStringAsFixed(1)} kg', color: Colors.tealAccent, big: true),
        ];
        break;
      case 'h_body_fat':
        // معادلة الجيش الأمريكي (US Navy)
        double bodyFat = 0;
        if (h > 0 && e1 > 0) {
          if (_isMale) {
            bodyFat = 495 / (1.0324 - 0.19077 * _log10(e1 - e2) + 0.15456 * _log10(h)) - 450;
          } else {
            bodyFat = 495 / (1.29579 - 0.35004 * _log10(e1 + e2 - 0) + 0.22100 * _log10(h)) - 450;
          }
        }
        r = [
          ResultLine(tr(context, 'h_body_fat'), '${bodyFat.isFinite ? bodyFat.toStringAsFixed(1) : '—'}%', color: Colors.tealAccent, big: true),
        ];
        break;
      case 'h_water':
        final liters = w * 0.033;
        r = [
          ResultLine(tr(context, 'h_water'), '${liters.toStringAsFixed(2)} لتر/يوم', color: Colors.blueAccent, big: true),
        ];
        break;
      case 'h_hba1c':
        final eag = (28.7 * e1) - 46.7;
        r = [
          ResultLine('متوسط السكر التقديري', '${eag.toStringAsFixed(0)} mg/dL', color: Colors.tealAccent, big: true),
        ];
        break;
      case 'h_heart_rate':
        final maxHr = 220 - age;
        r = [
          ResultLine('أقصى معدل نبض', '${maxHr.toStringAsFixed(0)} نبضة/دقيقة', color: Colors.redAccent, big: true),
          ResultLine('منطقة حرق الدهون (50-65%)', '${(maxHr * 0.5).toStringAsFixed(0)} - ${(maxHr * 0.65).toStringAsFixed(0)}', color: Colors.orangeAccent),
          ResultLine('منطقة اللياقة القلبية (65-85%)', '${(maxHr * 0.65).toStringAsFixed(0)} - ${(maxHr * 0.85).toStringAsFixed(0)}', color: Colors.greenAccent),
        ];
        break;
      case 'h_pregnancy':
        final daysPassed = e1.toInt();
        final dueInDays = 280 - daysPassed;
        final weeksPregnant = (daysPassed / 7).floor();
        r = [
          ResultLine('الأسبوع الحالي تقريبًا', '$weeksPregnant أسبوع', color: Colors.pinkAccent, big: true),
          ResultLine('الأيام المتبقية تقريبًا للولادة', dueInDays > 0 ? '$dueInDays يوم' : 'قريبًا جدًا', color: Colors.tealAccent),
        ];
        break;
    }
    setState(() => _results = r);
  }

  double _log10(double x) => x <= 0 ? 0 : (math.log(x) / math.ln10);

  @override
  Widget build(BuildContext context) {
    final calcLabels = {for (final k in _calcKeys) k: tr(context, k)};
    final needsHeight = ['h_bmi', 'h_bmr', 'h_calories', 'h_ideal_weight', 'h_body_fat'].contains(_calc);
    final needsAge = ['h_bmr', 'h_calories', 'h_heart_rate'].contains(_calc);
    final needsGender = ['h_bmr', 'h_calories', 'h_ideal_weight', 'h_body_fat'].contains(_calc);
    final needsActivity = _calc == 'h_calories';
    final needsWeight = ['h_bmi', 'h_bmr', 'h_calories', 'h_water'].contains(_calc);
    final needsHbA1c = _calc == 'h_hba1c';
    final needsBodyFatExtra = _calc == 'h_body_fat';
    final needsPregnancy = _calc == 'h_pregnancy';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          AppDropdown<String>(
            value: _calc,
            items: _calcKeys,
            labelBuilder: (k) => calcLabels[k]!,
            onChanged: (v) => setState(() {
              _calc = v;
              _calculate();
            }),
          ),
          const SizedBox(height: 20),
          if (needsGender) ...[
            AppDropdown<String>(
              value: _gender,
              items: const ['h_male', 'h_female'],
              labelBuilder: (k) => tr(context, k),
              onChanged: (v) => setState(() {
                _gender = v;
                _calculate();
              }),
            ),
            const SizedBox(height: 15),
          ],
          if (needsWeight) ...[
            AppNumberField(controller: _weight, label: tr(context, 'h_weight'), onChanged: (_) => _calculate()),
            const SizedBox(height: 15),
          ],
          if (needsHeight) ...[
            AppNumberField(controller: _height, label: tr(context, 'h_height'), onChanged: (_) => _calculate()),
            const SizedBox(height: 15),
          ],
          if (needsAge) ...[
            AppNumberField(controller: _age, label: tr(context, 'h_age'), onChanged: (_) => _calculate()),
            const SizedBox(height: 15),
          ],
          if (needsActivity) ...[
            AppDropdown<String>(
              value: _activity,
              items: _activityFactors.keys.toList(),
              labelBuilder: (k) => _activityLabel(context, k),
              onChanged: (v) => setState(() {
                _activity = v;
                _calculate();
              }),
            ),
            const SizedBox(height: 15),
          ],
          if (needsBodyFatExtra) ...[
            AppNumberField(controller: _extra1, label: tr(context, 'h_neck'), onChanged: (_) => _calculate()),
            const SizedBox(height: 15),
            AppNumberField(controller: _extra2, label: tr(context, 'h_waist'), onChanged: (_) => _calculate()),
            const SizedBox(height: 15),
          ],
          if (needsHbA1c) ...[
            AppNumberField(controller: _extra1, label: tr(context, 'h_hba1c_input'), onChanged: (_) => _calculate()),
            const SizedBox(height: 15),
          ],
          if (needsPregnancy) ...[
            AppNumberField(controller: _extra1, label: tr(context, 'h_lmp'), onChanged: (_) => _calculate()),
            const SizedBox(height: 15),
          ],
          const SizedBox(height: 10),
          ResultCard(lines: _results),
        ],
      ),
    );
  }

  String _activityLabel(BuildContext context, String key) {
    final isAr = Lang.of(context).isArabic;
    switch (key) {
      case 'sedentary':
        return isAr ? 'خامل (بدون رياضة)' : 'Sedentary';
      case 'light':
        return isAr ? 'نشاط خفيف' : 'Light activity';
      case 'normal':
        return isAr ? 'نشاط متوسط' : 'Moderate activity';
      case 'active':
        return isAr ? 'نشاط عالٍ' : 'Active';
      case 'very_active':
        return isAr ? 'نشاط عالٍ جدًا' : 'Very active';
      default:
        return key;
    }
  }
}
