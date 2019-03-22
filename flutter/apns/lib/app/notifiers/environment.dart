import 'package:flutter/foundation.dart';

class Environment with ChangeNotifier {

  bool _isProduction;
  bool get isProduction => _isProduction;

  Environment() {
    _isProduction = false;
  }

  void changeEnvirnoment(bool isProduction) {
    _isProduction = isProduction;
    notifyListeners();
  }
}