import 'package:flutter/material.dart';

import '../models/history_item.dart';
import '../repositories/history_repository.dart';

class HistoryViewModel extends ChangeNotifier {
  final HistoryRepository repository;

  HistoryViewModel({required this.repository}) {
    loadHistory();
  }

  bool isLoading = true;
  String? errorMessage;
  List<HistoryItem> historyItems = [];

  Future<void> loadHistory() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      historyItems = await repository.fetchHistory();
    } catch (error) {
      errorMessage = 'Unable to load history.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addHistoryItem(HistoryItem item) async {
    try {
      await repository.saveHistoryItem(item);
      await loadHistory();
    } catch (error) {
      errorMessage = 'Failed to save history item.';
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(String id) async {
    try {
      await repository.toggleFavorite(id);
      await loadHistory();
    } catch (error) {
      errorMessage = 'Failed to update favorite status.';
      notifyListeners();
    }
  }

  Future<void> deleteHistoryItem(String id) async {
    try {
      await repository.deleteHistoryItem(id);
      historyItems.removeWhere((item) => item.id == id);
      notifyListeners();
    } catch (error) {
      errorMessage = 'Failed to delete history item.';
      notifyListeners();
    }
  }

  Future<void> clearHistory() async {
    try {
      await repository.clearHistory();
      historyItems.clear();
      notifyListeners();
    } catch (error) {
      errorMessage = 'Failed to clear history.';
      notifyListeners();
    }
  }

  bool get hasHistory => historyItems.isNotEmpty;
}
