import 'dart:math' as math;

class MathEvalException implements Exception {
  final String message;
  MathEvalException(this.message);
}

/// محرّك تقييم تعبيرات رياضية بسيط ومستقل (دوال مثلثية، لوغاريتمات، أقواس...)
/// يدعم وضع الدرجات (deg) أو الراديان (rad) للدوال المثلثية.
class ExpressionEvaluator {
  final String _src;
  int _pos = 0;
  final bool degreeMode;

  ExpressionEvaluator(this._src, {this.degreeMode = true});

  static double evaluate(String expression, {bool degreeMode = true}) {
    final cleaned = expression
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('−', '-')
        .replaceAll('π', 'pi')
        .replaceAll('√', 'sqrt')
        .trim();
    if (cleaned.isEmpty) return 0;
    final ev = ExpressionEvaluator(cleaned, degreeMode: degreeMode);
    final result = ev._parseExpression();
    ev._skipSpaces();
    if (ev._pos != cleaned.length) {
      throw MathEvalException('unexpected_char');
    }
    if (result.isNaN || result.isInfinite) {
      throw MathEvalException('math_error');
    }
    return result;
  }

  void _skipSpaces() {
    while (_pos < _src.length && _src[_pos] == ' ') {
      _pos++;
    }
  }

  bool _match(String c) {
    _skipSpaces();
    if (_pos < _src.length && _src[_pos] == c) {
      _pos++;
      return true;
    }
    return false;
  }

  String? _peekChar() {
    _skipSpaces();
    if (_pos < _src.length) return _src[_pos];
    return null;
  }

  // expression := term (('+'|'-') term)*
  double _parseExpression() {
    double value = _parseTerm();
    while (true) {
      final c = _peekChar();
      if (c == '+') {
        _pos++;
        value += _parseTerm();
      } else if (c == '-') {
        _pos++;
        value -= _parseTerm();
      } else {
        break;
      }
    }
    return value;
  }

  // term := factor (('*'|'/') factor)*
  double _parseTerm() {
    double value = _parseFactor();
    while (true) {
      final c = _peekChar();
      if (c == '*') {
        _pos++;
        value *= _parseFactor();
      } else if (c == '/') {
        _pos++;
        final divisor = _parseFactor();
        if (divisor == 0) throw MathEvalException('div_by_zero');
        value /= divisor;
      } else {
        break;
      }
    }
    return value;
  }

  // factor := unary ('^' factor)?   (right-assoc)
  double _parseFactor() {
    double value = _parseUnary();
    _skipSpaces();
    if (_match('^')) {
      final exponent = _parseFactor();
      value = math.pow(value, exponent).toDouble();
    }
    return value;
  }

  // unary := ('-'|'+')? postfix
  double _parseUnary() {
    _skipSpaces();
    if (_match('-')) {
      return -_parseUnary();
    }
    if (_match('+')) {
      return _parseUnary();
    }
    return _parsePostfix();
  }

  // postfix := primary ('!' | '%')*
  double _parsePostfix() {
    double value = _parsePrimary();
    while (true) {
      final c = _peekChar();
      if (c == '!') {
        _pos++;
        value = _factorial(value);
      } else if (c == '%') {
        _pos++;
        value = value / 100;
      } else {
        break;
      }
    }
    return value;
  }

  // primary := number | constant | identifier '(' expr ')' | '(' expr ')'
  double _parsePrimary() {
    _skipSpaces();
    if (_pos >= _src.length) {
      throw MathEvalException('unexpected_end');
    }

    if (_match('(')) {
      final value = _parseExpression();
      if (!_match(')')) throw MathEvalException('missing_paren');
      return value;
    }

    final c = _src[_pos];
    if (RegExp(r'[0-9.]').hasMatch(c)) {
      return _parseNumber();
    }

    if (RegExp(r'[a-zA-Z]').hasMatch(c)) {
      return _parseIdentifier();
    }

    throw MathEvalException('unexpected_char');
  }

  double _parseNumber() {
    final start = _pos;
    bool dotSeen = false;
    while (_pos < _src.length && (RegExp(r'[0-9]').hasMatch(_src[_pos]) || (_src[_pos] == '.' && !dotSeen))) {
      if (_src[_pos] == '.') dotSeen = true;
      _pos++;
    }
    final numStr = _src.substring(start, _pos);
    final value = double.tryParse(numStr);
    if (value == null) throw MathEvalException('bad_number');
    return value;
  }

  double _parseIdentifier() {
    final start = _pos;
    while (_pos < _src.length && RegExp(r'[a-zA-Z]').hasMatch(_src[_pos])) {
      _pos++;
    }
    final name = _src.substring(start, _pos).toLowerCase();

    // ثوابت
    if (name == 'pi') return math.pi;
    if (name == 'e') return math.e;
    if (name == 'ans') return 0; // يُستبدل مسبقًا في واجهة الحاسبة قبل التقييم

    // دوال بمعامل واحد بين قوسين
    _skipSpaces();
    if (_match('(')) {
      final arg = _parseExpression();
      if (!_match(')')) throw MathEvalException('missing_paren');
      return _applyFunction(name, arg);
    }

    throw MathEvalException('unknown_identifier');
  }

  double _applyFunction(String name, double arg) {
    double toRad(double deg) => degreeMode ? deg * math.pi / 180 : deg;
    double fromRad(double rad) => degreeMode ? rad * 180 / math.pi : rad;

    switch (name) {
      case 'sin':
        return math.sin(toRad(arg));
      case 'cos':
        return math.cos(toRad(arg));
      case 'tan':
        return math.tan(toRad(arg));
      case 'asin':
        return fromRad(math.asin(arg));
      case 'acos':
        return fromRad(math.acos(arg));
      case 'atan':
        return fromRad(math.atan(arg));
      case 'sqrt':
        if (arg < 0) throw MathEvalException('negative_sqrt');
        return math.sqrt(arg);
      case 'ln':
        if (arg <= 0) throw MathEvalException('log_domain');
        return math.log(arg);
      case 'log':
      case 'log10':
        if (arg <= 0) throw MathEvalException('log_domain');
        return math.log(arg) / math.ln10;
      case 'abs':
        return arg.abs();
      case 'exp':
        return math.exp(arg);
      case 'fact':
        return _factorial(arg);
      default:
        throw MathEvalException('unknown_function');
    }
  }

  double _factorial(double n) {
    if (n < 0 || n != n.roundToDouble() || n > 170) {
      throw MathEvalException('factorial_domain');
    }
    double result = 1;
    for (int i = 2; i <= n.toInt(); i++) {
      result *= i;
    }
    return result;
  }
}
