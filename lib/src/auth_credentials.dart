import 'package:http/http.dart';

import 'auth_user.dart';
import 'google.dart';

abstract class AuthCredentials {
  AuthUser get user;

  AuthCredentials();

  Map<String, dynamic> toJson();

  /// Create a new baseClient for the authenticated client.
  ///
  /// Overriding this is useful for example if you want to use a proxy in
  /// development which would could be done like this:
  ///
  /// ```dart
  /// final credentials = AuthCredentials.fromJson(json);
  /// credentials.createBaseClient = () => IOClient(
  ///     HttpClient()
  ///       ..findProxy = (uri) => 'PROXY localhost:8000'
  ///       ..badCertificateCallback = (cert, host, port) => true,
  ///   );
  /// ```
  Client Function() createBaseClient = () => Client();

  /// Create credentials from a JSON map.
  factory AuthCredentials.fromJson(Map map) {
    final provider = map['pv'];
    if (provider == GoogleAuthCredentials.providerId) {
      return GoogleAuthCredentials.fromJson(map);
    } else {
      throw ArgumentError.value(
        provider,
        'provider',
        'Unknown provider: $provider',
      );
    }
  }
}
