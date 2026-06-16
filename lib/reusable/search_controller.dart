import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GlobalSearchController extends GetxController {
  var query = ''.obs;

  final RxList<GlobalKey> matchKeys = <GlobalKey>[].obs;
  var currentIndex = 0.obs;

  int get totalMatches => matchKeys.length;
  var matchCount = 0.obs;

  int registerMatch(GlobalKey key) {
    if (!matchKeys.contains(key)) {
      matchKeys.add(key);
      matchCount.value = matchKeys.length;
    }
    return matchKeys.indexOf(key);
  }

  void resetMatches() {
    matchKeys.clear();
    matchCount.value = 0;
    currentIndex.value = 0;
  }

  void updateQuery(String value) {
    query.value = value.toLowerCase();
    resetMatches();
  }

  void previousMatch() {
    if (matchKeys.isEmpty) return;

    currentIndex.value = (currentIndex.value - 1 + matchKeys.length) % matchKeys.length;

    scrollToCurrent();
  }

  void nextMatch() {
    if (matchKeys.isEmpty) return;

    currentIndex.value = (currentIndex.value + 1) % matchKeys.length;
    scrollToCurrent();
  }

  void scrollToCurrent() {
    final key = matchKeys[currentIndex.value];
    final context = key.currentContext;

    if (context != null) {
      Scrollable.ensureVisible(context, duration: const Duration(milliseconds: 400), alignment: 0.3);
    }
  }

  void clear() {
    query.value = '';
    resetMatches();
  }
}
