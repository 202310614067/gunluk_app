import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/user_model.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _usernameController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _foodAnswerController = TextEditingController();
  bool _obscurePassword = true;

  void _resetPassword() async {
    final username = _usernameController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final answer = _foodAnswerController.text.trim().toLowerCase();

    final usersBox = Hive.box<UserModel>('users');

    final userKey = usersBox.keys.firstWhere(
      (key) => usersBox.get(key)?.username == username,
      orElse: () => null,
    );

    if (userKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kullanıcı bulunamadı.")),
      );
      return;
    }

    final user = usersBox.get(userKey)!;
    if (user.favoriteFood.toLowerCase() != answer) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Güvenlik sorusu cevabı yanlış.")),
      );
      return;
    }

    final updatedUser = UserModel(
      username: username,
      password: newPassword,
      favoriteFood: user.favoriteFood, // ✅ korundu
    );
    usersBox.put(userKey, updatedUser);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Şifre başarıyla güncellendi.")),
    );

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.light().copyWith(
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.black),
          hintStyle: TextStyle(color: Colors.black54),
          prefixIconColor: Colors.black,
          filled: true,
          fillColor: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Colors.black,
          selectionColor: Colors.black12,
          selectionHandleColor: Colors.black,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black),
          titleMedium: TextStyle(color: Colors.black),
          labelLarge: TextStyle(color: Colors.black),
        ),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFD8CFC4),
        appBar: AppBar(
          title: const Text('Şifre Sıfırla',
              style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_reset, size: 80, color: Colors.brown),
                const SizedBox(height: 30),
                TextField(
                  controller: _usernameController,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Kullanıcı Adı',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _foodAnswerController,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    labelText: 'En Sevdiğin Yemek',
                    prefixIcon: const Icon(Icons.fastfood),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _newPasswordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Yeni Şifre',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey[700],
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _resetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[700],
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Şifreyi Güncelle',
                      style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _newPasswordController.dispose();
    _foodAnswerController.dispose();
    super.dispose();
  }
}
