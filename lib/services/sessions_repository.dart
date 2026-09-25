import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// ملاحظة/جلسة محفوظة واحدة
class SavedNote {
  final String id;
  final DateTime date;
  final String text;

  SavedNote({required this.id, required this.date, required this.text});

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'text': text,
      };

  factory SavedNote.fromJson(Map<String, dynamic> json) => SavedNote(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        text: json['text'] as String,
      );
}

/// يحفظ الملاحظات/الجلسات بشكل دائم على الجهاز (لا تختفي عند إغلاق التطبيق)
class SessionsRepository {
  SessionsRepository._();
  static final SessionsRepository instance = SessionsRepository._();

  static const String _key = 'saved_notes_v1';

  Future<List<SavedNote>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => SavedNote.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveAll(List<SavedNote> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(notes.map((n) => n.toJson()).toList());
    await prefs.setString(_key, raw);
  }

  /// يضيف ملاحظة جديدة في أول القائمة ويحفظها فورًا بشكل دائم
  Future<void> add(String text) async {
    final notes = await loadAll();
    notes.insert(
      0,
      SavedNote(id: DateTime.now().microsecondsSinceEpoch.toString(), date: DateTime.now(), text: text),
    );
    await _saveAll(notes);
  }

  Future<void> delete(String id) async {
    final notes = await loadAll();
    notes.removeWhere((n) => n.id == id);
    await _saveAll(notes);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
