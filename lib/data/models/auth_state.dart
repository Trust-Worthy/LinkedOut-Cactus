enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthCredentials {
  final String username;
  final String password;

  AuthCredentials({
    required this.username,
    required this.password,
  });
}
