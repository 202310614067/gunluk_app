import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/user_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _foodController = TextEditingController();
  bool _obscurePassword = true;
  bool _isSaving = false;

  void _register() async {
    setState(() => _isSaving = true);

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final food = _foodController.text.trim();

    if (username.isEmpty || password.isEmpty || food.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen tüm alanları doldurun.')),
        );
      }
      setState(() => _isSaving = false);
      return;
    }

    final usersBox = Hive.box<UserModel>('users');
    final exists = usersBox.values.any((user) => user.username == username);

    if (exists) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bu kullanıcı adı zaten alınmış.')),
        );
      }
      setState(() => _isSaving = false);
      return;
    }

    final newUser = UserModel(
      username: username,
      password: password,
      favoriteFood: food,
    );

    await usersBox.add(newUser);

    if (!mounted) return;

    Hive.box('auth')
      ..put('isLoggedIn', true)
      ..put('username', username);

    Navigator.pushReplacementNamed(context, '/home');
    setState(() => _isSaving = false);
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
          title: const Text('Kayıt Ol', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _usernameController,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  labelText: 'Kullanıcı Adı',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'Şifre',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey[700],
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _foodController,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  labelText: 'En Sevdiğin Yemek',
                  prefixIcon: Icon(Icons.fastfood),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isSaving ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B5E57),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Kayıt Ol', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _foodController.dispose();
    super.dispose();
  }
}
