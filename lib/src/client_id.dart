/// A universal class to represent an application client for authentication.
class ClientId {
  final String identifier;
  final String? secret;

  const ClientId(
    this.identifier, [
    this.secret,
  ]);

  @override
  String toString() => 'ClientId($identifier)';
}
