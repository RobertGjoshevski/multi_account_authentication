import 'package:googleapis/oauth2/v2.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as gauth;
import 'package:http/http.dart';
import 'package:http/http.dart' as http;

import 'auth_credentials.dart';
import 'auth_user.dart';
import 'client_id.dart';
import 'oauth.dart';

String _reverseAppId(String appId) {
  final parts = appId.split('.');
  return parts.reversed.join('.');
}

class GoogleAuthCredentials extends AuthCredentials {
  static const providerId = 'google';

  final gauth.AccessCredentials _accessCredentials;
  final Userinfo _userInfo;

  gauth.AuthClient? _client;

  /// Get an authenticated client for making requests to googleapis. The client
  /// automatically refreshes if necessary. You must have set [googleClientId]
  /// before calling this.
  gauth.AuthClient get client => _client ??= gauth.autoRefreshingClient(
        gauth.ClientId(
          _clientId.identifier,
          _clientId.secret,
        ),
        _accessCredentials,
        Client(),
      );

  GoogleAuthCredentials._({
    required gauth.AccessCredentials accessCredentials,
    required Userinfo userInfo,
  })  : _accessCredentials = accessCredentials,
        _userInfo = userInfo;

  static late ClientId _clientId;
  static set clientId(ClientId value) => _clientId = value;

  /// The user's information at the time of login. This may not be up to date.
  ///
  /// Use [currentUser] to get the latest information.
  @override
  AuthUser get user => AuthUser(
        id: _userInfo.id ?? '',
        name: _userInfo.name ?? '',
        email: _userInfo.email ?? '',
      );

  @override
  String toString() => 'GoogleAuthCredentials($user)';

  /************** 
   *
   * LIFETIME
   * 
   **************/

  /// Sign in with Google. You must have set [googleClientId] before calling this.
  ///
  /// The [scopes] parameter is a list of scopes to request from the user. The
  /// `email` and `profile` scopes are always requested.
  static Future<GoogleAuthCredentials> create(List<String> scopes) async {
    final token = await OAuthProvider.google.signIn(
      _clientId.identifier,
      '${_reverseAppId(_clientId.identifier)}:/oauth2callback',
      [
        'email',
        'profile',
        ...scopes,
      ],
    );
    final creds = token.googleAccessCredentials;

    final userInfo =
        await Oauth2Api(gauth.authenticatedClient(http.Client(), creds))
            .userinfo
            .v2
            .me
            .get();

    return GoogleAuthCredentials._(
      accessCredentials: creds,
      userInfo: userInfo,
    );
  }

  /// Get the user's current information.
  ///
  /// This does not update [user].
  Future<AuthUser> get currentUser async {
    final userInfo = await Oauth2Api(client).userinfo.v2.me.get();
    return AuthUser(
      id: userInfo.id ?? '',
      name: userInfo.name ?? '',
      email: userInfo.email ?? '',
    );
  }

  /// Log out of Google. You must have set [googleClientId] before calling this.
  ///
  /// This revokes the access token and refresh token. It may take a second or
  /// so to take effect.
  Future<void> revoke() async {
    await client.post(
      Uri.parse(
        'https://oauth2.googleapis.com/revoke',
      ),
      body: {
        'token': _accessCredentials.accessToken.data,
      },
    );
  }

  /*************
   * 
   * Serialization
   * 
   *************/

  ///
  @override
  Map<String, dynamic> toJson() => {
        'ac': _accessCredentials.toJson(),
        'ui': _userInfo.toJson(),
        'pv': providerId,
      };

  GoogleAuthCredentials.fromJson(Map map)
      : _accessCredentials = gauth.AccessCredentials.fromJson(
          map['ac'],
        ),
        _userInfo = Userinfo.fromJson(
          map['ui'],
        );
}
