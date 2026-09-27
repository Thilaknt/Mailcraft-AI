import '../models/history_item.dart';
import '../services/history_service.dart';

class HistoryRepository {
  final HistoryService service;

  HistoryRepository({required this.service});

  Future<List<HistoryItem>> fetchHistory() {
    return service.loadHistory();
  }

  Future<void> saveHistoryItem(HistoryItem item) {
    return service.saveHistoryItem(item);
  }

  Future<void> toggleFavorite(String id) {
    return service.toggleFavorite(id);
  }

  Future<void> deleteHistoryItem(String id) {
    return service.deleteHistoryItem(id);
  }

  Future<void> clearHistory() {
    return service.clearHistory();
  }
}
