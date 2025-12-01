import 'package:isar_community/isar.dart';

part 'user.g.dart';

@collection
class User {
  Id id = Isar.autoIncrement;

  @Index(unique: true, caseSensitive: false)
  late String username;

  late String passwordHash; // Store hashed password, never plain text

  String? displayName;
  String? email;
  
  late DateTime createdAt;
  late DateTime lastLoginAt;

  // Settings and preferences per user
  bool hasCompletedOnboarding;

  User({
    required this.username,
    required this.passwordHash,
    this.displayName,
    this.email,
    this.hasCompletedOnboarding = false,
  }) : createdAt = DateTime.now(),
       lastLoginAt = DateTime.now();
}
