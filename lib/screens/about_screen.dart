import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../widgets/developer_link.dart';

const String kAppVersion = '1.0.0';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        title: Text(
          tr(context, 'drawer_about'),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // ===== APP ICON =====
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                'assets/app_icon.png',
                width: 96,
                height: 96,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              tr(context, 'app_title'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            Text(
              '${tr(context, 'drawer_version')} $kAppVersion',
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 30),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white24,
                ),
              ),
              child: Text(
                tr(context, 'about_desc'),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white24,
                ),
              ),
              child: Text(
                tr(context, 'about_developer'),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 24),

            // ===== COPYRIGHT + WEBSITE =====
            const DeveloperLink(
              compact: false,
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
