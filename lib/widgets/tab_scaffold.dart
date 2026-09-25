import 'package:flutter/material.dart';
import 'app_drawer.dart';
import 'banner_ad_bar.dart';

/// يغلّف كل شاشة وجهة (المال/الصحة/الحسابات/التحويلات) بشاشة كاملة موحدة:
/// AppBar برجوع تلقائي + قائمة جانبية + محتوى التبويب + شريط بانر أسفل الشاشة.
class TabScreenScaffold extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final Color backgroundColor;
  final ValueChanged<Color> onColorChanged;

  const TabScreenScaffold({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    required this.backgroundColor,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          ],
        ),
        backgroundColor: const Color(0xFF1E1E1E),
        centerTitle: true,
        elevation: 2,
      ),
      drawer: AppDrawer(backgroundColor: backgroundColor, onColorChanged: onColorChanged),
      body: Column(
        children: [
          Expanded(child: child),
          const BannerAdBar(),
        ],
      ),
    );
  }
}
