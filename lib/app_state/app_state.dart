class AppState {
  static final AppState _instance = AppState._internal();

  AppState._internal();

  factory AppState() => _instance;

  bool isAuthenticated = false;

  set setIsAuthenticated(v) => isAuthenticated = v;

  bool isLogged = false;

  set setLogged(v) => isLogged = v;

  bool? get getIsLogged => isLogged;
}
