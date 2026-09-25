import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import '../services/expression_evaluator.dart';
import '../widgets/banner_ad_bar.dart';

class ScientificCalculatorScreen extends StatefulWidget {
  const ScientificCalculatorScreen({super.key});

  @override
  State<ScientificCalculatorScreen> createState() => _ScientificCalculatorScreenState();
}

class _ScientificCalculatorScreenState extends State<ScientificCalculatorScreen> {
  String _expression = '';
  String _display = '0';
  bool _degreeMode = true;
  bool _showError = false;
  double _lastAnswer = 0;
  bool _secondPage = false;
  final List<String> _history = [];

  void _input(String value) {
    setState(() {
      _showError = false;
      _expression += value;
      _display = _expression.isEmpty ? '0' : _expression;
    });
  }

  void _clear() {
    setState(() {
      _expression = '';
      _display = '0';
      _showError = false;
    });
  }

  void _backspace() {
    setState(() {
      if (_expression.isNotEmpty) {
        _expression = _expression.substring(0, _expression.length - 1);
      }
      _display = _expression.isEmpty ? '0' : _expression;
      _showError = false;
    });
  }

  void _equals() {
    if (_expression.isEmpty) return;
    try {
      final withAns = _expression.replaceAll('ans', _lastAnswer.toString());
      final result = ExpressionEvaluator.evaluate(withAns, degreeMode: _degreeMode);
      final resultStr = _formatResult(result);
      setState(() {
        _history.insert(0, '$_expression = $resultStr');
        if (_history.length > 50) _history.removeLast();
        _lastAnswer = result;
        _expression = resultStr;
        _display = resultStr;
        _showError = false;
      });
    } catch (_) {
      setState(() {
        _display = tr(context, 'sci_error');
        _showError = true;
      });
    }
  }

  String _formatResult(double v) {
    if (v == v.roundToDouble() && v.abs() < 1e15) {
      return v.toStringAsFixed(0);
    }
    String s = v.toStringAsFixed(10);
    s = s.replaceFirst(RegExp(r'0+$'), '');
    s = s.replaceFirst(RegExp(r'\.$'), '');
    return s;
  }

  void _showHistory() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      builder: (_) => SizedBox(
        height: 400,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(tr(context, 'sci_history'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            Expanded(
              child: _history.isEmpty
                  ? Center(child: Text(tr(context, 'no_sessions'), style: const TextStyle(color: Colors.white54)))
                  : ListView.builder(
                      itemCount: _history.length,
                      itemBuilder: (_, i) => ListTile(
                        title: Text(_history[i], style: const TextStyle(color: Colors.white70)),
                        onTap: () {
                          Navigator.pop(context);
                          setState(() {
                            _expression = _history[i].split(' = ').first;
                            _display = _expression;
                          });
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr(context, 'scientific_tooltip')),
        backgroundColor: const Color(0xFF1E1E1E),
        centerTitle: true,
        elevation: 2,
        actions: [
          IconButton(icon: const Icon(Icons.history), onPressed: _showHistory),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _display1(),
            const Divider(height: 1, color: Colors.white24),
            _controlsRow(),
            Expanded(flex: 11, child: _secondPage ? _pageTwo() : _pageOne()),
            const BannerAdBar(),
          ],
        ),
      ),
    );
  }

  Widget _display1() {
    return Expanded(
      flex: 2,
      child: Container(
        width: double.infinity,
        alignment: Alignment.bottomRight,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          reverse: true,
          child: Text(
            _display,
            style: TextStyle(
              color: _showError ? Colors.redAccent : Colors.white,
              fontSize: _display.length > 12 ? 30 : 44,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _controlsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () => setState(() => _degreeMode = !_degreeMode),
            child: Text(
              _degreeMode ? tr(context, 'sci_deg') : tr(context, 'sci_rad'),
              style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () => setState(() => _secondPage = !_secondPage),
            child: Text(
              _secondPage ? '123' : 'ƒ(x)',
              style: const TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _btn(String text, {Color? color, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: SizedBox.expand(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? const Color(0xFF262626),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: EdgeInsets.zero,
          ),
          onPressed: onTap ?? () => _input(text),
          child: FittedBox(child: Text(text, style: const TextStyle(fontSize: 17, color: Colors.white))),
        ),
      ),
    );
  }

  /// شبكة أزرار تعتمد على Column/Row بنسب مرنة (Expanded) بدل GridView
  /// لضمان عدم حدوث أي تمرير أو تجاوز في الارتفاع على أي جهاز مهما كان صغيرًا
  Widget _grid(List<Widget> children) {
    const cols = 4;
    final rows = <Widget>[];
    for (int i = 0; i < children.length; i += cols) {
      final rowChildren = children.skip(i).take(cols).map((w) => Expanded(child: w)).toList();
      rows.add(Expanded(child: Row(children: rowChildren)));
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(children: rows),
    );
  }

  Widget _pageOne() {
    return _grid([
      _btn('C', color: const Color(0xFF3A1E1E), onTap: _clear),
      _btn('(', color: const Color(0xFF2A2A2A)),
      _btn(')', color: const Color(0xFF2A2A2A)),
      _btn('⌫', color: const Color(0xFF3A1E1E), onTap: _backspace),
      _btn('sin(', color: const Color(0xFF241A33)), _btn('cos(', color: const Color(0xFF241A33)), _btn('tan(', color: const Color(0xFF241A33)), _btn('÷', color: const Color(0xFF1A2E33)),
      _btn('7'), _btn('8'), _btn('9'), _btn('×', color: const Color(0xFF1A2E33)),
      _btn('4'), _btn('5'), _btn('6'), _btn('−', color: const Color(0xFF1A2E33)),
      _btn('1'), _btn('2'), _btn('3'), _btn('+', color: const Color(0xFF1A2E33)),
      _btn('0'), _btn('.'), _btn('%', color: const Color(0xFF1A2E33)), _btn('=', color: Colors.tealAccent[700], onTap: _equals),
    ]);
  }

  Widget _pageTwo() {
    return _grid([
      _btn('π', color: const Color(0xFF241A33)), _btn('e', color: const Color(0xFF241A33)), _btn('^', color: const Color(0xFF1A2E33)), _btn('!', color: const Color(0xFF241A33)),
      _btn('√(', color: const Color(0xFF241A33)), _btn('ln(', color: const Color(0xFF241A33)), _btn('log(', color: const Color(0xFF241A33)), _btn('÷', color: const Color(0xFF1A2E33)),
      _btn('asin(', color: const Color(0xFF241A33)), _btn('acos(', color: const Color(0xFF241A33)), _btn('atan(', color: const Color(0xFF241A33)), _btn('×', color: const Color(0xFF1A2E33)),
      _btn('exp(', color: const Color(0xFF241A33)), _btn('abs(', color: const Color(0xFF241A33)), _btn('ans', color: const Color(0xFF241A33)), _btn('−', color: const Color(0xFF1A2E33)),
      _btn('(', color: const Color(0xFF2A2A2A)), _btn(')', color: const Color(0xFF2A2A2A)), _btn('⌫', color: const Color(0xFF3A1E1E), onTap: _backspace), _btn('+', color: const Color(0xFF1A2E33)),
      _btn('C', color: const Color(0xFF3A1E1E), onTap: _clear), _btn('0'), _btn('.'), _btn('=', color: Colors.tealAccent[700], onTap: _equals),
    ]);
  }
}
