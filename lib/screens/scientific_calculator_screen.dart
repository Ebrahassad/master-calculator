import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

class ScientificCalculatorScreen extends StatefulWidget {
  const ScientificCalculatorScreen({Key? key}) : super(key: key);

  @override
  _ScientificCalculatorScreenState createState() => _ScientificCalculatorScreenState();
}

class _ScientificCalculatorScreenState extends State<ScientificCalculatorScreen> {
  String _expression = "";
  String _result = "0";

  void _onButtonPressed(String value) {
    setState(() {
      if (value == "C") {
        _expression = "";
        _result = "0";
      } else if (value == "⌫") {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
        }
      } else if (value == "=") {
        _calculateResult();
      } else {
        _expression += value;
      }
    });
  }

  void _calculateResult() {
    try {
      String finalExpression = _expression
          .replaceAll("×", "*")
          .replaceAll("÷", "/")
          .replaceAll("π", "3.141592653589793")
          .replaceAll("e", "2.718281828459045");

      Parser p = Parser();
      Expression exp = p.parse(finalExpression);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);
      
      setState(() {
        _result = eval.toString();
        if (_result.endsWith(".0")) {
          _result = _result.substring(0, _result.length - 2);
        }
      });
    } catch (e) {
      setState(() {
        _result = "خطأ في العملية";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text("الآلة الحاسبة الهندسية الشاملة", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E293B),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(20),
              alignment: Alignment.bottomRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _expression,
                    style: const TextStyle(fontSize: 24, color: Colors.white70),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _result,
                    style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.tealAccent),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: GridView.count(
                crossAxisCount: 4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.3,
                children: [
                  "sin(", "cos(", "tan(", "⌫",
                  "log(", "ln(", "√(", "^",
                  "C", "(", ")", "÷",
                  "7", "8", "9", "×",
                  "4", "5", "6", "-",
                  "1", "2", "3", "+",
                  "π", "0", ".", "=",
                ].map((btnText) {
                  bool isOperator = ["÷", "×", "-", "+", "=", "C", "⌫"].contains(btnText);
                  bool isScientific = ["sin(", "cos(", "tan(", "log(", "ln(", "√(", "^", "(", ")", "π"].contains(btnText);
                  
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isOperator 
                          ? Colors.teal 
                          : (isScientific ? const Color(0xFF334155) : const Color(0xFF475569)),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _onButtonPressed(btnText),
                    child: Text(
                      btnText,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
