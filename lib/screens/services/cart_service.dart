// lib/screens/services/cart_service.dart
import 'package:flutter/foundation.dart';

class CartService extends ChangeNotifier {
  final List<Map<String, dynamic>> _selectedTests = [];

  List<Map<String, dynamic>> get selectedTests => List.unmodifiable(_selectedTests);

  int get itemCount => _selectedTests.length;

  bool get isEmpty => _selectedTests.isEmpty;

  double get totalPrice {
    return _selectedTests.fold(
      0.0,
          (sum, test) => sum + (test['price'] as num? ?? 0),
    );
  }

  int get totalDuration {
    return _selectedTests.fold(
      0,
          (sum, test) => sum + (test['avg_duration_minutes'] as int? ?? 0),
    );
  }

  bool isTestSelected(String testId) {
    return _selectedTests.any((test) => test['id'] == testId);
  }

  void addTest(Map<String, dynamic> test) {
    if (!isTestSelected(test['id'])) {
      _selectedTests.add(test);
      notifyListeners();
    }
  }

  void removeTest(String testId) {
    _selectedTests.removeWhere((test) => test['id'] == testId);
    notifyListeners();
  }

  void toggleTest(Map<String, dynamic> test) {
    isTestSelected(test['id'])
        ? removeTest(test['id'])
        : addTest(test);
  }

  void clear() {
    _selectedTests.clear();
    notifyListeners();
  }

  List<String> getTestIds() {
    return _selectedTests
        .map((test) => test['id'] as String)
        .toList();
  }
}
