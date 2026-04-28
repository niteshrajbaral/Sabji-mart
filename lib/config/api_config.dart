class ApiConfig {
  static const String baseUrl =
      "https://api.beta.order.rebuzzpos.com/api/businesses/69ca20396bd358b4da2f8b61";
  static const String authUrl = "https://api.beta.order.rebuzzpos.com/api";

  /// The current business id — the trailing path segment of [baseUrl].
  /// Orders whose `businessId` doesn't match this are from other vendors
  /// and should be hidden in this app.
  static String get businessId => baseUrl.split('/').last;
}
