import 'package:flutter/material.dart';

import '../widgets/aircraft_list.dart';
import '../widgets/favorites_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final List<Map<String, dynamic>> _favorites = [];

  final List<String> _titles = const [
    'Каталог самолётов',
    'Избранное',
  ];

  String _keyOf(Map<String, dynamic> item) =>
      '${item['manufacturer']}|${item['model']}';

  bool _isFavorite(Map<String, dynamic> item) =>
      _favorites.any((f) => _keyOf(f) == _keyOf(item));

  void _toggleFavorite(Map<String, dynamic> item) {
    final wasFavorite = _isFavorite(item);
    setState(() {
      if (wasFavorite) {
        _favorites.removeWhere((f) => _keyOf(f) == _keyOf(item));
      } else {
        _favorites.add(item);
      }
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            wasFavorite ? 'Удалено из избранного' : 'Добавлено в избранное',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
  }

  void _confirmClearFavorites() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Очистить избранное?'),
        content: Text('Будет удалено самолётов: ${_favorites.length}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              setState(() => _favorites.clear());
              Navigator.pop(ctx);
            },
            child: const Text('Очистить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          if (_currentIndex == 1 && _favorites.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Очистить избранное',
              onPressed: _confirmClearFavorites,
            ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          AircraftList(
            isFavorite: _isFavorite,
            onToggleFavorite: _toggleFavorite,
          ),
          FavoritesList(
            favorites: _favorites,
            onToggleFavorite: _toggleFavorite,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.airplanemode_active),
            label: 'Каталог',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              label: Text('${_favorites.length}'),
              isLabelVisible: _favorites.isNotEmpty,
              child: const Icon(Icons.favorite),
            ),
            label: 'Избранное',
          ),
        ],
      ),
    );
  }
}
