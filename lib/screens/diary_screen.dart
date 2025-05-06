import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import '../models/diary_entry.dart';
import '../widgets/menu_popup.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final diaryBox = Hive.box<DiaryEntry>('entries');
    final currentUser = Hive.box('auth').get('username');
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final entriesMap = diaryBox.toMap().cast<int, DiaryEntry>();
    final filteredMap = entriesMap.entries.where((e) =>
      e.value.userId == currentUser &&
      (e.value.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
       DateFormat('yyyy-MM-dd').format(e.value.date).contains(_searchQuery))
    ).toList();

    return Scaffold(
      appBar: AppBar(
        leading: const AppPopupMenu(),
        title: const Text('Günlüklerim'),
      ),
      backgroundColor: isDarkMode ? Colors.grey[900] : const Color(0xFFD8CFC4),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: 'Başlık veya tarih (yyyy-mm-dd)...',
                hintStyle: const TextStyle(color: Colors.black54),
                prefixIcon: const Icon(Icons.search, color: Colors.black87),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.purpleAccent, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _showEntryDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Günlük Ekle'),
              style: ElevatedButton.styleFrom(
                elevation: 6,
                backgroundColor: Colors.amber,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: filteredMap.length,
                itemBuilder: (context, index) {
                  final entry = filteredMap[index].value;
                  final key = filteredMap[index].key;

                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.title,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat.yMMMMd('tr').format(entry.date),
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            entry.content,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 15),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () => _showEntryDialog(entry: entry, key: key),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20),
                                onPressed: () {
                                  diaryBox.delete(key);
                                  setState(() {});
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEntryDialog({DiaryEntry? entry, int? key}) {
    if (entry != null) {
      _titleController.text = entry.title;
      _contentController.text = entry.content;
    } else {
      _titleController.clear();
      _contentController.clear();
    }

    final userId = Hive.box('auth').get('username');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(entry != null ? 'Günlüğü Düzenle' : 'Yeni Günlük'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Başlık'),
            ),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: 'İçerik'),
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              final title = _titleController.text.trim();
              final content = _contentController.text.trim();
              final now = DateTime.now();
              final diaryBox = Hive.box<DiaryEntry>('entries');

              if (title.isEmpty || content.isEmpty) return;

              if (entry == null) {
                final alreadyExistsToday = diaryBox.values.any((e) =>
                  e.userId == userId &&
                  e.date.year == now.year &&
                  e.date.month == now.month &&
                  e.date.day == now.day
                );

                if (alreadyExistsToday) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Bugün zaten bir günlük girdiniz."),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                diaryBox.add(DiaryEntry(
                  title: title,
                  content: content,
                  date: now,
                  userId: userId,
                ));
              } else if (key != null) {
                diaryBox.put(key, DiaryEntry(
                  title: title,
                  content: content,
                  date: entry.date, // tarihi korur
                  userId: userId,
                ));
              }

              Navigator.pop(context);
              setState(() {});
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }
}
