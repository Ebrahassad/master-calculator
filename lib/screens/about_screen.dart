import 'package:flutter/material.dart';
import '../l10n/strings.dart';

const String kAppVersion = '1.0.0';
const String kContactEmail = 'ebrahassadi77@gmail.com';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        title: Text(tr(context, 'drawer_about')),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [Colors.blueAccent, Colors.purpleAccent]),
              ),
              child: const Icon(Icons.calculate_rounded, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Text(
              tr(context, 'app_title'),
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '${tr(context, 'drawer_version')} $kAppVersion',
              style: const TextStyle(color: Colors.white60, fontSize: 14),
            ),
            const SizedBox(height: 30),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24),
              ),
              child: Text(
                tr(context, 'about_desc'),
                style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.6),
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
                border: Border.all(color: Colors.white24),
              ),
              child: Text(
                tr(context, 'about_developer'),
                style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.6),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.mail_outline, color: Colors.tealAccent, size: 18),
                const SizedBox(width: 8),
                Text('${tr(context, 'drawer_contact')}: $kContactEmail', style: const TextStyle(color: Colors.white54, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
