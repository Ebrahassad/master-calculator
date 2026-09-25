import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import '../services/ads_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/tab_scaffold.dart';
import '../widgets/math_symbols_background.dart';
import '../widgets/developer_link.dart';
import 'finance_tab.dart';
import 'health_tab.dart';
import 'calculations_tab.dart';
import 'conversions_tab.dart';
import 'scientific_calculator_screen.dart';

class LandingScreen extends StatelessWidget {
  final Color backgroundColor;
  final ValueChanged<Color> onColorChanged;

  const LandingScreen(
      {super.key, required this.backgroundColor, required this.onColorChanged});

  void _go(BuildContext context, WidgetBuilder builder) {
    AdsService.instance.trackNavigationAndMaybeShowAd();
    Navigator.push(context, MaterialPageRoute(builder: builder));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(
          backgroundColor: backgroundColor, onColorChanged: onColorChanged),
      body: Stack(
        children: [
          // ===== خلفية زخرفية: رموز حسابية شفافة خلف كل المحتوى =====
          const Positioned.fill(child: MathSymbolsBackground()),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 6,
              ),
              child: Column(
                children: [
                  // ===== الشريط العلوي: زر القائمة + زر اللغة =====
                  Row(
                    children: [
                      Builder(
                        builder: (context) => IconButton(
                          icon: const Icon(Icons.menu, color: Colors.white70),
                          onPressed: () => Scaffold.of(context).openDrawer(),
                        ),
                      ),
                      const Spacer(),
                      const _LanguageButton(),
                    ],
                  ),
                  const SizedBox(height: 18),
                  // ===== الشعار + اسم التطبيق =====
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      'assets/app_icon.png',
                      width: 92,
                      height: 92,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) => Container(
                        width: 92,
                        height: 92,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                              colors: [Colors.blueAccent, Colors.purpleAccent]),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.calculate_rounded,
                            color: Colors.white, size: 46),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    tr(context, 'app_title'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tr(context, 'landing_subtitle'),
                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                  const SizedBox(height: 18),
                  // ===== أزرار التنقل الرئيسية =====
                  _MenuButton(
                    icon: Icons.functions,
                    label: tr(context, 'nav_scientific'),
                    color: Colors.cyanAccent,
                    onTap: () =>
                        _go(context, (_) => const ScientificCalculatorScreen()),
                  ),
                  const SizedBox(height: 8),
                  _MenuButton(
                    icon: Icons.swap_horiz_rounded,
                    label: tr(context, 'nav_convert'),
                    color: Colors.tealAccent,
                    onTap: () => _go(
                      context,
                      (_) => TabScreenScaffold(
                        title: tr(context, 'nav_convert'),
                        icon: Icons.swap_horiz_rounded,
                        backgroundColor: backgroundColor,
                        onColorChanged: onColorChanged,
                        child: const ConversionsTab(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _MenuButton(
                    icon: Icons.favorite_rounded,
                    label: tr(context, 'nav_health'),
                    color: Colors.pinkAccent,
                    onTap: () => _go(
                      context,
                      (_) => TabScreenScaffold(
                        title: tr(context, 'nav_health'),
                        icon: Icons.favorite_rounded,
                        backgroundColor: backgroundColor,
                        onColorChanged: onColorChanged,
                        child: const HealthTab(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _MenuButton(
                    icon: Icons.calculate_rounded,
                    label: tr(context, 'nav_calc'),
                    color: Colors.orangeAccent,
                    onTap: () => _go(
                      context,
                      (_) => TabScreenScaffold(
                        title: tr(context, 'nav_calc'),
                        icon: Icons.calculate_rounded,
                        backgroundColor: backgroundColor,
                        onColorChanged: onColorChanged,
                        child: const CalculationsTab(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _MenuButton(
                    icon: Icons.attach_money_rounded,
                    label: tr(context, 'nav_money'),
                    color: Colors.greenAccent,
                    onTap: () => _go(
                      context,
                      (_) => TabScreenScaffold(
                        title: tr(context, 'nav_money'),
                        icon: Icons.attach_money_rounded,
                        backgroundColor: backgroundColor,
                        onColorChanged: onColorChanged,
                        child: const FinanceTab(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  // ===== تذييل الشاشة: الحقوق + المطوّر =====
                  const DeveloperLink(
                    compact: false,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  const _LanguageButton();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => Lang.of(context).toggle(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.language, color: Colors.tealAccent, size: 18),
            const SizedBox(width: 6),
            Text(
              Lang.of(context).isArabic ? 'EN' : 'AR',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MenuButton(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white12),
          boxShadow: const [
            BoxShadow(
                color: Colors.black38, blurRadius: 8, offset: Offset(0, 3))
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 19),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white24, size: 16),
          ],
        ),
      ),
    );
  }
}
