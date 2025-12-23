
class BaseAuthUser {
  const BaseAuthUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.phoneNumber,
    this.token,
  });

  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String? phoneNumber;
  final String? token;

  // Legacy compatibility: Alias 'id' to 'uid'
  String get id => uid;

  // Legacy compatibility: Check if logged in
  bool get loggedIn => uid.isNotEmpty;
}

class AuthUserInfo extends BaseAuthUser {
  const AuthUserInfo({
    required super.uid,
    required super.email,
    super.displayName,
    super.photoUrl,
    super.phoneNumber,
  });
}
