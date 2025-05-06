import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../widgets/menu_popup.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _penAnimation;
  late Animation<double> _notebookAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    
    _penAnimation = Tween(begin: -0.1, end: 0.1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _notebookAnimation = Tween(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  String _getUsername() {
    final authBox = Hive.box('auth');
    return authBox.get('username', defaultValue: 'Günlük Dostum');
  }

  @override
  Widget build(BuildContext context) {
    final userName = _getUsername();
    final today = DateFormat.yMMMMd('tr').format(DateTime.now());
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: const AppPopupMenu(),
        title: const Text('Ana Sayfa'),
      ),
      backgroundColor: isDarkMode ? Colors.grey[900] : const Color(0xFFD8CFC4),
      body: Stack(
        children: [
          // Kalem animasyonu (sağ üst köşede)
          Positioned(
            top: 16,
            right: 16,
            child: RotationTransition(
              turns: _penAnimation,
              child: const Icon(
                Icons.edit,
                size: 40,
                color: Colors.brown,
              ),
            ),
          ),
          
          // Ana içerik
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Not defteri ikonu (animasyonlu)
                  ScaleTransition(
                    scale: _notebookAnimation,
                    child: const Icon(
                      Icons.book,
                      size: 80,
                      color: Colors.brown,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  Text(
                    'Hoş geldin, $userName!',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bugün: $today',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.blueGrey,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/diary');
                    },
                    icon: const Icon(Icons.book_outlined),
                    label: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      child: Text(
                        'Günlük Ekle / Görüntüle',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      elevation: 3,
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    '"Her gün bir satır, ruhuna iyi gelir."',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 20,
                      color: Colors.blueGrey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}