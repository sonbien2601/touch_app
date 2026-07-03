class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    required this.name,
    this.avatar,
  });

  final String uid;
  final String? email;
  final String name;
  final String? avatar;
}

