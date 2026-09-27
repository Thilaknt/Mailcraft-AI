import 'package:shared_preferences/shared_preferences.dart';

import '../models/history_item.dart';

class HistoryService {
  static const _historyKey = 'mailcraft_history_items';

  Future<List<HistoryItem>> loadHistory() async {
    final preferences = await SharedPreferences.getInstance();
    final stored = preferences.getStringList(_historyKey) ?? [];
    return stored.map(HistoryItem.fromEncodedJson).toList();
  }

  Future<void> saveHistoryItem(HistoryItem item) async {
    final preferences = await SharedPreferences.getInstance();
    final current = preferences.getStringList(_historyKey) ?? [];
    // Remove if duplicate id exists, then prepend
    final filtered = current.where((entry) {
      final existing = HistoryItem.fromEncodedJson(entry);
      return existing.id != item.id;
    }).toList();
    final updated = [item.toEncodedJson(), ...filtered];
    await preferences.setStringList(_historyKey, updated);
  }

  Future<void> toggleFavorite(String id) async {
    final preferences = await SharedPreferences.getInstance();
    final current = preferences.getStringList(_historyKey) ?? [];
    final updated = current.map((entry) {
      final item = HistoryItem.fromEncodedJson(entry);
      if (item.id == id) {
        return item.copyWith(isFavorite: !item.isFavorite).toEncodedJson();
      }
      return entry;
    }).toList();
    await preferences.setStringList(_historyKey, updated);
  }

  Future<void> deleteHistoryItem(String id) async {
    final preferences = await SharedPreferences.getInstance();
    final current = preferences.getStringList(_historyKey) ?? [];
    final updated = current.where((entry) {
      final item = HistoryItem.fromEncodedJson(entry);
      return item.id != id;
    }).toList();
    await preferences.setStringList(_historyKey, updated);
  }

  Future<void> clearHistory() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_historyKey);
  }
}
