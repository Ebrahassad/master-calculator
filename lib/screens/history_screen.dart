import 'package:flutter/material.dart';
import '../l10n/strings.dart';

class HistoryScreen extends StatelessWidget {
  final List<String> history;
  final VoidCallback? onClear;
  const HistoryScreen({super.key, required this.history, this.onClear});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr(context, 'drawer_history')),
        backgroundColor: const Color(0xFF1E1E1E),
        actions: [
          if (history.isNotEmpty && onClear != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: tr(context, 'clear_history'),
              onPressed: () {
                onClear!.call();
                Navigator.pop(context);
              },
            ),
        ],
      ),
      body: history.isEmpty
          ? Center(child: Text(tr(context, 'no_sessions'), style: const TextStyle(color: Colors.white54, fontSize: 16)))
          : ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                return Card(
                  color: const Color(0xFF1E1E1E),
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.history_edu, color: Colors.blueAccent),
                    title: Text(history[index], style: const TextStyle(color: Colors.white)),
                  ),
                );
              },
            ),
    );
  }
}
