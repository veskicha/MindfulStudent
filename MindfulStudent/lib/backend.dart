class Backend {
  static late final Backend instance;

  late final String url;
  late final String anonKey;

  Backend(this.url, this.anonKey);

  static initialize(String url, String anonKey) {
    Backend.instance = Backend(url, anonKey);
  }
}
