import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'models/user_model.dart';
import 'models/diary_entry.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart' as home;
import 'screens/auth_screen.dart';
import 'screens/diary_screen.dart';
import 'screens/settings_screen.dart' as settings;
import 'screens/reset_password_screen.dart';
import 'screens/login_screen.dart';     // 🔑 Giriş ekranı
import 'screens/register_screen.dart';  // 📝 Kayıt ekranı

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR', null);
  await Hive.initFlutter();

  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(DiaryEntryAdapter());

  await Hive.openBox('auth');
  await Hive.openBox<UserModel>('users');
  await Hive.openBox<DiaryEntry>('entries');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Günlük App',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            theme: ThemeData.light(useMaterial3: true),
            darkTheme: ThemeData.dark(useMaterial3: true),
            locale: const Locale('tr', 'TR'),
            supportedLocales: const [
              Locale('tr', 'TR'),
              Locale('en', 'US'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            initialRoute: Hive.box('auth').get('isLoggedIn', defaultValue: false)
                ? '/home'
                : '/auth',
            routes: {
              '/home': (_) => const home.HomeScreen(),
              '/auth': (_) => const AuthScreen(),
              '/diary': (_) => const DiaryScreen(),
              '/settings': (_) => const settings.SettingsScreen(),
              '/reset': (_) => const ResetPasswordScreen(),
              '/login': (_) => const LoginScreen(),       // ✅ Giriş ekranı
              '/register': (_) => const RegisterScreen(), // ✅ Kayıt ekranı
            },
          );
        },
      ),
    );
  }
}
