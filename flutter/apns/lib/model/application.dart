import 'package:flutter/foundation.dart';

enum Environment { sandox, production }

class Application {
  Application({this.evnironment, this.bundleID});

  final Environment evnironment;
  final String bundleID;

  bool operator ==(dynamic other) {
    if (other is Application) {
      return other.evnironment == this.evnironment;
    } else {
      return false;
    }
  }

  @override
  int get hashCode => this.evnironment.hashCode;
}

class ApplicationController with ChangeNotifier {
  List<Application> _apps = [
    Application(evnironment: Environment.sandox, bundleID: ''),
    Application(evnironment: Environment.production, bundleID: ''),
  ];
  Application _current;

  ApplicationController() {
    _current = _apps.first;
  }

  List<Application> get apps => _apps;
  Application get current => _current;

  void updateCurrentApp(Application app) {
    _current = app;
    notifyListeners();
  }

  void updateAppBundleID(Environment environment, String value) {
    if (environment == Environment.sandox) {
      _apps[0] = Application(bundleID: value, evnironment: Environment.sandox);
    } else {
      _apps[1] =
          Application(bundleID: value, evnironment: Environment.production);
    }
    notifyListeners();
  }
}
