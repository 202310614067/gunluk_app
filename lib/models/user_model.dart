import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel {
  @HiveField(0)
  String username;

  @HiveField(1)
  String password;

  @HiveField(2)
  String favoriteFood; // ✅ Yeni alan

  UserModel({
    required this.username,
    required this.password,
    required this.favoriteFood,
  });
}
