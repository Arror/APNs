import 'package:flutter/foundation.dart';

class Server with ChangeNotifier {
  String _certificate;
  String _temID;
  String _keyID;

  String get certificate => _certificate;
  String get temID => _temID;
  String get keyID => _keyID;

  Server(this._certificate, this._temID, this._keyID);

  void updateCertificate(String value) {
    _certificate = value;
    notifyListeners();
  }

  void updateTemID(String value) {
    _temID = value;
    notifyListeners();
  }

  void updateKeyID(String value) {
    _keyID = value;
    notifyListeners();
  }
}
