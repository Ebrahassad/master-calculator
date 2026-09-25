import 'package:flutter/material.dart';

/// خلفية زخرفية لشاشة القائمة الرئيسية: رموز ومعادلات حسابية صغيرة
/// شبه شفافة موزّعة خلف الأزرار، لإعطاء طابع "حاسبة" للشاشة دون تشتيت الانتباه.
class MathSymbolsBackground extends StatelessWidget {
  const MathSymbolsBackground({super.key});

  static const List<_SymbolSpec> _symbols = [
    _SymbolSpec('π', 0.08, 0.05, 26, -0.25),
    _SymbolSpec('÷', 0.80, 0.04, 30, 0.2),
    _SymbolSpec('√', 0.55, 0.09, 22, 0.1),
    _SymbolSpec('7+5', 0.15, 0.16, 16, -0.1),
    _SymbolSpec('×', 0.85, 0.14, 24, -0.15),
    _SymbolSpec('%', 0.06, 0.24, 20, 0.3),
    _SymbolSpec('=', 0.40, 0.20, 24, 0),
    _SymbolSpec('∑', 0.70, 0.22, 26, 0.2),
    _SymbolSpec('x²', 0.90, 0.30, 20, -0.2),
    _SymbolSpec('12÷4', 0.08, 0.34, 15, 0.15),
    _SymbolSpec('−', 0.30, 0.38, 28, 0.1),
    _SymbolSpec('∞', 0.60, 0.40, 22, -0.1),
    _SymbolSpec('+', 0.85, 0.44, 26, 0.25),
    _SymbolSpec('9×3', 0.12, 0.48, 16, -0.15),
    _SymbolSpec('½', 0.45, 0.50, 22, 0.05),
    _SymbolSpec('log', 0.75, 0.53, 18, -0.2),
    _SymbolSpec('÷', 0.05, 0.58, 22, 0.2),
    _SymbolSpec('100%', 0.55, 0.60, 15, 0.1),
    _SymbolSpec('×', 0.90, 0.63, 24, -0.1),
    _SymbolSpec('√9', 0.20, 0.68, 18, 0.15),
    _SymbolSpec('=', 0.65, 0.70, 22, -0.2),
    _SymbolSpec('π', 0.35, 0.74, 24, 0.2),
    _SymbolSpec('+', 0.08, 0.80, 24, -0.1),
    _SymbolSpec('÷', 0.80, 0.82, 26, 0.15),
    _SymbolSpec('8-2', 0.50, 0.86, 16, 0),
    _SymbolSpec('×', 0.25, 0.90, 22, 0.2),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        return Stack(
          children: [
            for (final s in _symbols)
              Positioned(
                left: s.dx * w,
                top: s.dy * h,
                child: Transform.rotate(
                  angle: s.rotation,
                  child: Text(
                    s.text,
                    style: TextStyle(
                      fontSize: s.size,
                      color: Colors.white.withOpacity(0.14),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SymbolSpec {
  final String text;
  final double dx; // نسبة الموضع الأفقي (0-1)
  final double dy; // نسبة الموضع الرأسي (0-1)
  final double size;
  final double rotation;
  const _SymbolSpec(this.text, this.dx, this.dy, this.size, this.rotation);
}
