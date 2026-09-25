import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/strings.dart';
import '../services/ads_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/tab_scaffold.dart';
import '../widgets/math_symbols_background.dart';
import 'finance_tab.dart';
import 'health_tab.dart';
import 'calculations_tab.dart';
import 'conversions_tab.dart';
import 'scientific_calculator_screen.dart';

const String kDeveloperName = 'HASSADI';
const String kDeveloperUrl = 'https://ebrahassad.github.io/Hassadi-Apps/#apps';

class LandingScreen extends StatelessWidget {
  final Color backgroundColor;
  final ValueChanged<Color> onColorChanged;

  const LandingScreen({super.key, required this.backgroundColor, required this.onColorChanged});

  void _go(BuildContext context, WidgetBuilder builder) {
    AdsService.instance.trackNavigationAndMaybeShowAd();
    Navigator.push(context, MaterialPageRoute(builder: builder));
  }

  Future<void> _openDeveloperLink(BuildContext context) async {
    final uri = Uri.parse(kDeveloperUrl);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr(context, 'error_open_link'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(backgroundColor: backgroundColor, onColorChanged: onColorChanged),
      body: Stack(
        children: [
          // ===== خلفية زخرفية: رموز حسابية شفافة خلف كل المحتوى =====
          const Positioned.fill(child: MathSymbolsBackground()),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
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
                  _LanguageButton(),
                ],
              ),
              const Spacer(flex: 2),
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
                      gradient: LinearGradient(colors: [Colors.blueAccent, Colors.purpleAccent]),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.calculate_rounded, color: Colors.white, size: 46),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                tr(context, 'app_title'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                tr(context, 'landing_subtitle'),
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
              const Spacer(flex: 2),
              // ===== أزرار التنقل الرئيسية =====
              _MenuButton(
                icon: Icons.functions,
                label: tr(context, 'nav_scientific'),
                color: Colors.cyanAccent,
                onTap: () => _go(context, (_) => const ScientificCalculatorScreen()),
              ),
              const SizedBox(height: 12),
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
              const SizedBox(height: 12),
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
              const SizedBox(height: 12),
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
              const SizedBox(height: 12),
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
              const Spacer(flex: 3),
              // ===== تذييل الشاشة: الحقوق + المطوّر =====
              Text(tr(context, 'copyright_text'), style: const TextStyle(color: Colors.white38, fontSize: 11)),
              const SizedBox(height: 8),
              InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () => _openDeveloperLink(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipOval(
                        child: Image.asset(
                          'assets/hr_icon.png',
                          width: 26,
                          height: 26,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) => const CircleAvatar(
                            radius: 13,
                            backgroundColor: Colors.white24,
                            child: Icon(Icons.person, size: 16, color: Colors.white70),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        tr(context, 'developer_by'),
                        style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
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
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
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

  const _MenuButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
          boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 3))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 16),
          ],
        ),
      ),
    );
  }
}
