import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import '../widgets/common.dart';

class FinanceTab extends StatefulWidget {
  const FinanceTab({super.key});

  @override
  State<FinanceTab> createState() => _FinanceTabState();
}

class _FinanceTabState extends State<FinanceTab> {
  String _calc = 'fin_vat';

  final _c1 = TextEditingController(text: '1000');
  final _c2 = TextEditingController(text: '15');
  final _c3 = TextEditingController(text: '1');

  List<ResultLine> _results = [];

  static const List<String> _calcKeys = [
    'fin_vat',
    'fin_loan',
    'fin_investment',
    'fin_compound',
    'fin_simple_interest',
    'fin_profit_margin',
    'fin_break_even',
    'fin_savings_goal',
  ];

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  double _v(TextEditingController c) => parseNum(c.text);

  void _calculate() {
    final a = _v(_c1);
    final b = _v(_c2);
    final n = _v(_c3);
    List<ResultLine> r = [];

    switch (_calc) {
      case 'fin_vat':
        final tax = a * (b / 100);
        r = [
          ResultLine(tr(context, 'fin_sub_result'), tax.toStringAsFixed(2), color: Colors.blueAccent),
          ResultLine(tr(context, 'fin_total_result'), (a + tax).toStringAsFixed(2), color: Colors.greenAccent, big: true),
        ];
        break;
      case 'fin_loan':
        // قسط شهري بسيط (فائدة ثابتة سنوية موزعة على مدة السداد بالأشهر)
        final months = n <= 0 ? 1 : n;
        final totalInterest = a * (b / 100) * (months / 12);
        final total = a + totalInterest;
        final monthly = total / months;
        r = [
          ResultLine(tr(context, 'fin_monthly_payment'), monthly.toStringAsFixed(2), color: Colors.tealAccent, big: true),
          ResultLine(tr(context, 'fin_total_interest'), totalInterest.toStringAsFixed(2), color: Colors.orangeAccent),
          ResultLine(tr(context, 'fin_total_result'), total.toStringAsFixed(2), color: Colors.greenAccent),
        ];
        break;
      case 'fin_investment':
        final years = n <= 0 ? 1 : n;
        final profit = a * (b / 100) * years;
        r = [
          ResultLine(tr(context, 'fin_profit'), profit.toStringAsFixed(2), color: Colors.greenAccent, big: true),
          ResultLine(tr(context, 'fin_total_result'), (a + profit).toStringAsFixed(2), color: Colors.tealAccent),
        ];
        break;
      case 'fin_compound':
        final years = n <= 0 ? 1 : n;
        final result = a * math.pow(1 + (b / 100), years);
        r = [
          ResultLine(tr(context, 'fin_final_amount'), result.toStringAsFixed(2), color: Colors.tealAccent, big: true),
          ResultLine(tr(context, 'fin_profit'), (result - a).toStringAsFixed(2), color: Colors.greenAccent),
        ];
        break;
      case 'fin_simple_interest':
        final years = n <= 0 ? 1 : n;
        final interest = a * (b / 100) * years;
        r = [
          ResultLine(tr(context, 'fin_total_interest'), interest.toStringAsFixed(2), color: Colors.orangeAccent),
          ResultLine(tr(context, 'fin_final_amount'), (a + interest).toStringAsFixed(2), color: Colors.greenAccent, big: true),
        ];
        break;
      case 'fin_profit_margin':
        final margin = a == 0 ? 0.0 : ((a - b) / a) * 100;
        r = [
          ResultLine(tr(context, 'fin_profit'), (a - b).toStringAsFixed(2), color: Colors.greenAccent),
          ResultLine(tr(context, 'fin_margin_pct'), '${margin.toStringAsFixed(1)}%', color: Colors.tealAccent, big: true),
        ];
        break;
      case 'fin_break_even':
        final denom = a - b;
        final units = denom <= 0 ? 0.0 : n / denom;
        r = [
          ResultLine(tr(context, 'fin_breakeven_units'), (denom <= 0) ? '—' : units.ceil().toString(), color: Colors.tealAccent, big: true),
        ];
        break;
      case 'fin_savings_goal':
        final months = b <= 0 ? 1 : b;
        final monthly = a / months;
        r = [
          ResultLine(tr(context, 'fin_monthly_saving'), monthly.toStringAsFixed(2), color: Colors.tealAccent, big: true),
        ];
        break;
    }
    setState(() => _results = r);
  }

  @override
  Widget build(BuildContext context) {
    final calcLabels = {for (final k in _calcKeys) k: tr(context, k)};
    final isLoan = _calc == 'fin_loan';
    final isInvestment = _calc == 'fin_investment';
    final isCompound = _calc == 'fin_compound';
    final isSimpleInt = _calc == 'fin_simple_interest';
    final isMargin = _calc == 'fin_profit_margin';
    final isBreakEven = _calc == 'fin_break_even';
    final isSavings = _calc == 'fin_savings_goal';
    final needsThird = isLoan || isInvestment || isCompound || isSimpleInt || isBreakEven;

    String label1 = tr(context, 'fin_amount');
    String label2 = tr(context, 'fin_rate');
    String label3 = tr(context, 'fin_years');

    if (isMargin) {
      label1 = tr(context, 'fin_price');
      label2 = tr(context, 'fin_cost');
    } else if (isBreakEven) {
      label1 = tr(context, 'fin_unit_price');
      label2 = tr(context, 'fin_unit_cost');
      label3 = tr(context, 'fin_fixed_costs');
    } else if (isSavings) {
      label1 = tr(context, 'fin_goal_amount');
      label2 = tr(context, 'fin_months');
    } else if (isLoan) {
      label3 = tr(context, 'fin_months');
    }

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
          AppNumberField(controller: _c1, label: label1, onChanged: (_) => _calculate()),
          const SizedBox(height: 15),
          AppNumberField(controller: _c2, label: label2, onChanged: (_) => _calculate()),
          if (needsThird) ...[
            const SizedBox(height: 15),
            AppNumberField(controller: _c3, label: label3, onChanged: (_) => _calculate()),
          ],
          const SizedBox(height: 25),
          ResultCard(lines: _results),
        ],
      ),
    );
  }
}
