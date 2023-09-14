import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as gauth;

class OAuthProvider {
  final String authEndpoint;
  final String tokenEndpoint;

  const OAuthProvider({
    required this.authEndpoint,
    required this.tokenEndpoint,
  });

  static const google = OAuthProvider(
    authEndpoint: 'https://accounts.google.com/o/oauth2/v2/auth',
    tokenEndpoint: 'https://oauth2.googleapis.com/token',
  );

  /// Sign a user in with an OAuth provider.
  Future<OAuthTokenInfo> signIn(
    String clientId,
    String redirectUrl,
    List<String> scopes,
  ) async {
    final request = AuthorizationTokenRequest(
      clientId,
      redirectUrl,
      serviceConfiguration: AuthorizationServiceConfiguration(
        authorizationEndpoint: authEndpoint,
        tokenEndpoint: tokenEndpoint,
      ),
      scopes: scopes,
    );
    const appAuth = FlutterAppAuth();
    final resp = (await appAuth.authorizeAndExchangeCode(request))!;
    return OAuthTokenInfo(
      type: resp.tokenType!,
      accessToken: resp.accessToken!,
      expiresAt: resp.accessTokenExpirationDateTime!.toUtc(),
      refreshToken: resp.refreshToken!,
      scopes: resp.scopes!,
      idToken: resp.idToken,
    );
  }
}

class OAuthTokenInfo {
  final String type;
  final String accessToken;
  final DateTime expiresAt;
  final String refreshToken;
  final String? idToken;
  final List<String> scopes;

  const OAuthTokenInfo({
    required this.type,
    required this.accessToken,
    required this.expiresAt,
    required this.refreshToken,
    required this.scopes,
    this.idToken,
  });

  gauth.AccessCredentials get googleAccessCredentials =>
      gauth.AccessCredentials(
        gauth.AccessToken(
          type,
          accessToken,
          expiresAt.toUtc(),
        ),
        refreshToken,
        scopes,
        idToken: idToken,
      );
}
