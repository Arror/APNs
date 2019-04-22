class AppService {

  AppService._();

  AppEnvironment _environment;
  AppEnvironment get environemnt => _environment;
  
  static AppService _shared;

  static AppService get current => _sharedInstance();

  static AppService _sharedInstance() {
    if (_shared == null) {
      _shared = AppService._();
      _shared._environment = AppEnvironment(AppEnvironmentIdentifier.production, AppUser());
    }
    return _shared;
  }  
}

enum AppEnvironmentIdentifier {
  production
}

class AppEnvironment {

  static AppEnvironment get current => AppService.current.environemnt;

  AppEnvironmentIdentifier _identifier;
  AppEnvironmentIdentifier get identifier => _identifier;

  AppUser _user;
  AppUser get user => _user;

  AppEnvironment(this._identifier, this._user);
}

class AppUser {
  
  
}