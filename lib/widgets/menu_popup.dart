import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class AppPopupMenu extends StatelessWidget {
  const AppPopupMenu({super.key});

  void _handleMenuSelection(BuildContext context, String value) {
    switch (value) {
      case 'home':
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 'diary':
        Navigator.pushReplacementNamed(context, '/diary');
        break;
      case 'settings':
        Navigator.pushReplacementNamed(context, '/settings');
        break;
      case 'logout':
        Hive.box('auth').put('isLoggedIn', false);
        Navigator.pushReplacementNamed(context, '/auth');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? Colors.white : Colors.black54;
    final textStyle = TextStyle(color: iconColor);

    return PopupMenuButton<String>(
      icon: Icon(Icons.menu, size: 28, color: iconColor),
      onSelected: (value) => _handleMenuSelection(context, value),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'home',
          child: Row(
            children: [
              Icon(Icons.home, color: iconColor),
              const SizedBox(width: 8),
              Text('Ana Sayfa', style: textStyle),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'diary',
          child: Row(
            children: [
              Icon(Icons.book, color: iconColor),
              const SizedBox(width: 8),
              Text('Günlüklerim', style: textStyle),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'settings',
          child: Row(
            children: [
              Icon(Icons.settings, color: iconColor),
              const SizedBox(width: 8),
              Text('Ayarlar', style: textStyle),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.exit_to_app, color: iconColor),
              const SizedBox(width: 8),
              Text('Çıkış Yap', style: textStyle),
            ],
          ),
        ),
      ],
    );
  }
}
