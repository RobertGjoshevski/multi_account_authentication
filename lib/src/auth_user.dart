class AuthUser {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;

  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
  });

  @override
  String toString() => 'AuthUser($id, $email, $name)';

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'photoUrl': photoUrl,
      };

  factory AuthUser.fromJson(Map map) => AuthUser(
        id: map['id'],
        name: map['name'],
        email: map['email'],
        photoUrl: map['photoUrl'],
      );
}
