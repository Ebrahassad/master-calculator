import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/strings.dart';

const String kDeveloperName = 'HASSADI';
const String kDeveloperUrl = 'https://ebrahassad.github.io/Hassadi-Apps/#apps';

Future<void> openDeveloperWebsite(BuildContext context) async {
  final uri = Uri.parse(kDeveloperUrl);

  final opened = await launchUrl(
    uri,
    mode: LaunchMode.externalApplication,
  );

  if (!opened && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          tr(context, 'error_open_link'),
        ),
      ),
    );
  }
}

class DeveloperLink extends StatelessWidget {
  final bool compact;

  const DeveloperLink({
    super.key,
    this.compact = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => openDeveloperWebsite(context),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 10,
          vertical: compact ? 8 : 6,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipOval(
              child: Image.asset(
                'assets/hr_icon.png',
                width: compact ? 26 : 30,
                height: compact ? 26 : 30,
                fit: BoxFit.cover,
                errorBuilder: (
                  context,
                  error,
                  stackTrace,
                ) {
                  return CircleAvatar(
                    radius: compact ? 13 : 15,
                    backgroundColor: Colors.white24,
                    child: const Icon(
                      Icons.public,
                      size: 16,
                      color: Colors.white70,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${tr(context, 'copyright_text')} • $kDeveloperName',
              style: TextStyle(
                color: Colors.white70,
                fontSize: compact ? 12 : 13,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(width: 5),
            const Icon(
              Icons.open_in_new_rounded,
              color: Colors.tealAccent,
              size: 15,
            ),
          ],
        ),
      ),
    );
  }
}
