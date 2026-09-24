import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import '../widgets/common.dart';

class CalculationsTab extends StatefulWidget {
  const CalculationsTab({super.key});

  @override
  State<CalculationsTab> createState() => _CalculationsTabState();
}

class _CalculationsTabState extends State<CalculationsTab> {
  String _calc = 'c_discount';

  final _t1 = TextEditingController(text: '100');
  final _t2 = TextEditingController(text: '20');
  final _t3 = TextEditingController(text: '2');

  DateTime _dateA = DateTime.now();
  DateTime _dateB = DateTime.now();

  final List<TextEditingController> _gradeCtrls = [TextEditingController(text: '4.0')];
  final List<TextEditingController> _creditCtrls = [TextEditingController(text: '3')];

  List<ResultLine> _results = [];

  static const List<String> _calcKeys = [
    'c_discount',
    'c_percentage',
    'c_tip',
    'c_age',
    'c_date_diff',
    'c_gpa',
  ];

  @override
  void initState() {
    super.initState();
    _dateB = _dateA.subtract(const Duration(days: 30));
    _calculate();
  }

  double _v(TextEditingController c) => parseNum(c.text);

  void _calculate() {
    final v1 = _v(_t1);
    final v2 = _v(_t2);
    final v3 = _v(_t3);
    List<ResultLine> r = [];

    switch (_calc) {
      case 'c_discount':
        final saved = v1 * (v2 / 100);
        r = [
          ResultLine(tr(context, 'c_savings'), saved.toStringAsFixed(2), color: Colors.greenAccent),
          ResultLine(tr(context, 'c_final_price'), (v1 - saved).toStringAsFixed(2), color: Colors.blueAccent, big: true),
        ];
        break;
      case 'c_percentage':
        final result = v1 * (v2 / 100);
        r = [
          ResultLine('$v2% من $v1', result.toStringAsFixed(2), color: Colors.tealAccent, big: true),
        ];
        break;
      case 'c_tip':
        final tip = v1 * (v2 / 100);
        final total = v1 + tip;
        final people = v3 <= 0 ? 1 : v3;
        r = [
          ResultLine(tr(context, 'c_tip_amount'), tip.toStringAsFixed(2), color: Colors.orangeAccent),
          ResultLine(tr(context, 'fin_total_result'), total.toStringAsFixed(2), color: Colors.greenAccent),
          ResultLine(tr(context, 'c_per_person'), (total / people).toStringAsFixed(2), color: Colors.tealAccent, big: true),
        ];
        break;
      case 'c_age':
        final now = DateTime.now();
        int years = now.year - _dateA.year;
        int months = now.month - _dateA.month;
        int days = now.day - _dateA.day;
        if (days < 0) {
          months -= 1;
          final prevMonth = DateTime(now.year, now.month, 0);
          days += prevMonth.day;
        }
        if (months < 0) {
          years -= 1;
          months += 12;
        }
        final totalDays = now.difference(_dateA).inDays;
        r = [
          ResultLine(tr(context, 'result'), '$years سنة، $months شهر، $days يوم', color: Colors.tealAccent, big: true),
          ResultLine('إجمالي الأيام منذ الميلاد', '$totalDays يوم', color: Colors.blueAccent),
        ];
        break;
      case 'c_date_diff':
        final diff = _dateB.difference(_dateA).inDays.abs();
        r = [
          ResultLine(tr(context, 'result'), '$diff يوم', color: Colors.tealAccent, big: true),
          ResultLine('بالأسابيع تقريبًا', '${(diff / 7).toStringAsFixed(1)} أسبوع', color: Colors.blueAccent),
          ResultLine('بالأشهر تقريبًا', '${(diff / 30.44).toStringAsFixed(1)} شهر', color: Colors.orangeAccent),
        ];
        break;
      case 'c_gpa':
        double totalPoints = 0;
        double totalCredits = 0;
        for (int i = 0; i < _gradeCtrls.length; i++) {
          final g = parseNum(_gradeCtrls[i].text);
          final c = parseNum(_creditCtrls[i].text);
          totalPoints += g * c;
          totalCredits += c;
        }
        final gpa = totalCredits == 0 ? 0.0 : totalPoints / totalCredits;
        r = [
          ResultLine(tr(context, 'c_gpa'), gpa.toStringAsFixed(2), color: Colors.tealAccent, big: true),
        ];
        break;
    }
    setState(() => _results = r);
  }

  Future<void> _pickDate(bool isA) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isA ? _dateA : _dateB,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isA) {
          _dateA = picked;
        } else {
          _dateB = picked;
        }
        _calculate();
      });
    }
  }

  String _fmt(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Widget _dateTile(String label, DateTime date, bool isA) {
    return InkWell(
      onTap: () => _pickDate(isA),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: kCardColor, borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70)),
            Row(
              children: [
                Text(_fmt(date), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                const Icon(Icons.calendar_month, color: Colors.tealAccent, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addGpaRow() {
    setState(() {
      _gradeCtrls.add(TextEditingController(text: '4.0'));
      _creditCtrls.add(TextEditingController(text: '3'));
      _calculate();
    });
  }

  void _removeGpaRow(int index) {
    if (_gradeCtrls.length <= 1) return;
    setState(() {
      _gradeCtrls.removeAt(index);
      _creditCtrls.removeAt(index);
      _calculate();
    });
  }

  @override
  Widget build(BuildContext context) {
    final calcLabels = {for (final k in _calcKeys) k: tr(context, k)};
    final isDiscount = _calc == 'c_discount';
    final isPercentage = _calc == 'c_percentage';
    final isTip = _calc == 'c_tip';
    final isAge = _calc == 'c_age';
    final isDateDiff = _calc == 'c_date_diff';
    final isGpa = _calc == 'c_gpa';

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
          if (isDiscount) ...[
            AppNumberField(controller: _t1, label: tr(context, 'c_original_value'), onChanged: (_) => _calculate()),
            const SizedBox(height: 15),
            AppNumberField(controller: _t2, label: tr(context, 'c_discount_pct'), onChanged: (_) => _calculate()),
          ],
          if (isPercentage) ...[
            AppNumberField(controller: _t2, label: 'النسبة (%)', onChanged: (_) => _calculate()),
            const SizedBox(height: 15),
            AppNumberField(controller: _t1, label: tr(context, 'c_original_value'), onChanged: (_) => _calculate()),
          ],
          if (isTip) ...[
            AppNumberField(controller: _t1, label: tr(context, 'c_bill_amount'), onChanged: (_) => _calculate()),
            const SizedBox(height: 15),
            AppNumberField(controller: _t2, label: tr(context, 'c_tip_pct'), onChanged: (_) => _calculate()),
            const SizedBox(height: 15),
            AppNumberField(controller: _t3, label: tr(context, 'c_people_count'), onChanged: (_) => _calculate()),
          ],
          if (isAge) _dateTile(tr(context, 'c_birth_date'), _dateA, true),
          if (isDateDiff) ...[
            _dateTile(tr(context, 'from'), _dateA, true),
            const SizedBox(height: 12),
            _dateTile(tr(context, 'to'), _dateB, false),
          ],
          if (isGpa) ...[
            for (int i = 0; i < _gradeCtrls.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Expanded(child: AppNumberField(controller: _gradeCtrls[i], label: 'الدرجة (0-4)', onChanged: (_) => _calculate())),
                    const SizedBox(width: 8),
                    Expanded(child: AppNumberField(controller: _creditCtrls[i], label: 'الساعات المعتمدة', onChanged: (_) => _calculate())),
                    IconButton(
                      onPressed: () => _removeGpaRow(i),
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                    ),
                  ],
                ),
              ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _addGpaRow,
                icon: const Icon(Icons.add, color: Colors.tealAccent),
                label: const Text('إضافة مادة', style: TextStyle(color: Colors.tealAccent)),
              ),
            ),
          ],
          const SizedBox(height: 15),
          ResultCard(lines: _results),
        ],
      ),
    );
  }
}
