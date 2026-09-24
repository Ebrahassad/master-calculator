import 'package:flutter/material.dart';

const kCardColor = Color(0xFF1E1E1E);
const kAccentColor = Colors.tealAccent;

/// قائمة منسدلة موحدة الشكل
class AppDropdown<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final String Function(T) labelBuilder;
  final ValueChanged<T> onChanged;
  final String? label;

  const AppDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          dropdownColor: const Color(0xFF262626),
          borderRadius: BorderRadius.circular(14),
          style: const TextStyle(color: Colors.white, fontSize: 15),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: kAccentColor),
          items: items
              .map((v) => DropdownMenuItem(value: v, child: Text(labelBuilder(v), overflow: TextOverflow.ellipsis)))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

/// حقل إدخال رقمي موحد الشكل
class AppNumberField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final ValueChanged<String>? onChanged;
  final bool allowNegative;

  const AppNumberField({
    super.key,
    required this.controller,
    required this.label,
    this.onChanged,
    this.allowNegative = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: true, signed: allowNegative),
      style: const TextStyle(color: Colors.white, fontSize: 16),
      cursorColor: kAccentColor,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60),
        filled: true,
        fillColor: kCardColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: kAccentColor, width: 1.6),
        ),
      ),
      onChanged: onChanged,
    );
  }
}

/// بطاقة نتيجة موحدة تدعم أكثر من سطر نتيجة
class ResultCard extends StatelessWidget {
  final List<ResultLine> lines;
  const ResultCard({super.key, required this.lines});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
        boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        children: [
          for (int i = 0; i < lines.length; i++) ...[
            if (i > 0) const Divider(color: Colors.white24, height: 24),
            Text(lines[i].label, style: const TextStyle(color: Colors.white70, fontSize: 15), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              lines[i].value,
              style: TextStyle(
                color: lines[i].color ?? kAccentColor,
                fontSize: lines[i].big ? 30 : 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class ResultLine {
  final String label;
  final String value;
  final Color? color;
  final bool big;
  const ResultLine(this.label, this.value, {this.color, this.big = false});
}

/// عنوان قسم صغير
class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(text, style: const TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

double parseNum(String s) => double.tryParse(s.replaceAll(',', '.')) ?? 0;
