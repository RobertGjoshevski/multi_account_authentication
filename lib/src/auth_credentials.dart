import 'auth_user.dart';
import 'google.dart';

abstract class AuthCredentials {
  AuthUser get user;

  AuthCredentials();

  Map<String, dynamic> toJson();

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
