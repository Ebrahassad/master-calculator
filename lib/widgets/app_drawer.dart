import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/strings.dart';
import '../services/ads_service.dart';
import '../services/sessions_repository.dart';
import '../screens/history_screen.dart';
import '../screens/about_screen.dart';
import 'developer_link.dart';

/// القائمة الجانبية المشتركة بين كل شاشات التطبيق
class AppDrawer extends StatelessWidget {
  final Color backgroundColor;
  final ValueChanged<Color> onColorChanged;

  const AppDrawer(
      {super.key, required this.backgroundColor, required this.onColorChanged});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF1A1A1A),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.purpleAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/app_icon.png',
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 10),
                Text(tr(context, 'app_title'),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const Text('Master Calculator Hub',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          _tile(
            context,
            icon: Icons.note_add_outlined,
            color: Colors.amber,
            label: tr(context, 'drawer_save_session'),
            onTap: () {
              Navigator.pop(context);
              _showNotesDialog(context);
            },
          ),
          _tile(
            context,
            icon: Icons.history,
            color: Colors.blueAccent,
            label: tr(context, 'drawer_history'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const HistoryScreen()));
            },
          ),
          _tile(
            context,
            icon: Icons.palette,
            color: Colors.purpleAccent,
            label: tr(context, 'drawer_background'),
            onTap: () {
              Navigator.pop(context);
              _showColorPicker(context, onColorChanged);
            },
          ),
          _tile(
            context,
            icon: Icons.language,
            color: Colors.tealAccent,
            label: tr(context, 'drawer_language'),
            onTap: () {
              Lang.of(context).toggle();
              Navigator.pop(context);
            },
          ),
          _tile(
            context,
            icon: Icons.share,
            color: Colors.lightGreenAccent,
            label: tr(context, 'drawer_share'),
            onTap: () {
              Navigator.pop(context);
              Share.share(tr(context, 'share_app_message'));
            },
          ),
          _tile(
            context,
            icon: Icons.info_outline,
            color: Colors.orangeAccent,
            label: tr(context, 'drawer_about'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const AboutScreen()));
            },
          ),
          const Divider(color: Colors.white24),
          _tile(
            context,
            icon: Icons.exit_to_app,
            color: Colors.redAccent,
            label: tr(context, 'drawer_exit'),
            labelColor: Colors.redAccent,
            onTap: () => SystemNavigator.pop(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
            child: Column(
              children: [
                Text(
                  '${tr(context, 'drawer_version')} $kAppVersion',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                const DeveloperLink(
                  compact: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
    Color? labelColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(color: labelColor ?? Colors.white)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      onTap: onTap,
    );
  }

  // ================= نافذة كتابة وحفظ الملاحظات =================
  void _showNotesDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF222222),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(tr(dialogContext, 'notes_title'),
            style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 5,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: tr(dialogContext, 'notes_hint'),
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: const Color(0xFF1A1A1A),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(tr(dialogContext, 'cancel'),
                style: const TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.tealAccent[700]),
            onPressed: () async {
              final text = controller.text.trim();
              if (text.isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(
                      content: Text(tr(dialogContext, 'notes_empty_error'))),
                );
                return;
              }
              await SessionsRepository.instance.add(text);
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(tr(context, 'notes_saved'))),
                );
              }
            },
            child: Text(tr(dialogContext, 'save'),
                style: const TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  // ================= نافذة اختيار لون الخلفية =================
  void _showColorPicker(
      BuildContext context, ValueChanged<Color> onColorChanged) {
    const premiumColor = Color(0xFF3E2C0C);
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF222222),
            title: Text(tr(dialogContext, 'pick_color'),
                style: const TextStyle(color: Colors.white)),
            content: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _colorButton(dialogContext, const Color(0xFF121212),
                    tr(dialogContext, 'theme_dark_original'), onColorChanged),
                _colorButton(dialogContext, const Color(0xFF0F172A),
                    tr(dialogContext, 'theme_navy_dark'), onColorChanged),
                _colorButton(dialogContext, const Color(0xFF1E1B4B),
                    tr(dialogContext, 'theme_deep_night'), onColorChanged),
                _colorButton(dialogContext, const Color(0xFF14281D),
                    tr(dialogContext, 'theme_dark_green'), onColorChanged),
                _colorButton(dialogContext, const Color(0xFF3B0764),
                    tr(dialogContext, 'theme_royal_purple'), onColorChanged),
                _colorButton(dialogContext, const Color(0xFF1A1A1A),
                    tr(dialogContext, 'theme_graphite_gray'), onColorChanged),
                FutureBuilder<bool>(
                  future: _isPremiumUnlocked(),
                  builder: (context, snapshot) {
                    final unlocked = snapshot.data ?? false;
                    if (unlocked) {
                      return _colorButton(dialogContext, premiumColor,
                          tr(dialogContext, 'premium_theme'), onColorChanged);
                    }
                    return GestureDetector(
                      onTap: () =>
                          _handlePremiumTap(dialogContext, setDialogState),
                      child: Container(
                        width: 70,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [Color(0xFFB8860B), Color(0xFF4A3200)]),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amberAccent),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.lock,
                            color: Colors.white, size: 18),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<bool> _isPremiumUnlocked() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('premium_theme_unlocked') ?? false;
  }

  void _handlePremiumTap(BuildContext dialogContext,
      void Function(void Function()) setDialogState) {
    AdsService.instance.showRewarded(
      onReward: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('premium_theme_unlocked', true);
        setDialogState(() {});
        if (dialogContext.mounted) {
          ScaffoldMessenger.of(dialogContext).showSnackBar(
            SnackBar(content: Text(tr(dialogContext, 'unlocked_now'))),
          );
        }
      },
      onNotReady: () {
        ScaffoldMessenger.of(dialogContext).showSnackBar(
          SnackBar(content: Text(tr(dialogContext, 'ad_not_ready_try_later'))),
        );
      },
    );
  }

  Widget _colorButton(BuildContext context, Color color, String label,
      ValueChanged<Color> onColorChanged) {
    return GestureDetector(
      onTap: () {
        onColorChanged(color);
        Navigator.pop(context);
      },
      child: Container(
        width: 70,
        height: 40,
        decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white38)),
        alignment: Alignment.center,
        child: Text(label,
            style: const TextStyle(color: Colors.white, fontSize: 10),
            textAlign: TextAlign.center),
      ),
    );
  }
}
