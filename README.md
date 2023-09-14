# Multi Identity Authentication

If you want to authenticate the user with multiple accounts simultaneously like in a calendar app.

## Features

Easily get an authenticated client that you can use for making API requests.

Currently supported identity providers:

- Google

The package should work across all platforms, but is only tested on macOS and iOS.

## Getting started

Before everything you need to register a new client and note down the client ID and secret.

Now you can configure the client id for this package. Make sure to set this function before doing anything with the credentials:

```dart
GoogleAuthCredentials.clientId = ClientId('<CLIENT ID HERE>');
```

NOTE: Most of the time you do not need to set the secret for the client id. That is only necessary if you want to access specific APIs.

## Usage

```dart
// Get credentials for a user
final creds = await GoogleAuthCredentials.create([...]);

// Get up-to-date information on the user
final user = await creds.currentUser;

// Use the client
final apiResponse = Oauth2Api(client).userinfo.v2.me.get();

// Revoke the credentials to log the user out
creds.revoke();
```
