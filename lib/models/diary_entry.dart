import 'package:hive/hive.dart';

part 'diary_entry.g.dart';

@HiveType(typeId: 1)
class DiaryEntry extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String content;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  String? userId;  // Günlükleri kullanıcıya özel yapmak için

  DiaryEntry({
    required this.title,
    required this.content,
    required this.date,
    this.userId,
  });
}
