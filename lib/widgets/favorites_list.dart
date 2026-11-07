import 'package:flutter/material.dart';

import 'aircraft_details.dart';

class FavoritesList extends StatefulWidget {
  final List<Map<String, dynamic>> favorites;
  final void Function(Map<String, dynamic> item) onToggleFavorite;

  const FavoritesList({
    super.key,
    required this.favorites,
    required this.onToggleFavorite,
  });

  @override
  State<FavoritesList> createState() => _FavoritesListState();
}

class _FavoritesListState extends State<FavoritesList> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onQueryChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged() {
    setState(() => _query = _controller.text.trim().toLowerCase());
  }

  List<Map<String, dynamic>> get _filtered => widget.favorites
      .where((a) =>
      '${a['manufacturer']} ${a['model']}'.toLowerCase().contains(_query))
      .toList();

  @override
  Widget build(BuildContext context) {
    if (widget.favorites.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.favorite_border, size: 64, color: Colors.grey),
              SizedBox(height: 12),
              Text(
                'Пока пусто.\nНажмите на сердечко или удерживайте карточку самолёта в каталоге.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    final items = _filtered;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.blue.shade50,
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Поиск в избранном...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: _controller.clear,
              )
                  : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? const Center(
            child: Text(
              'Ничего не найдено',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final aircraft = items[index];
              final speed = aircraft['max_speed_knots'] != null
                  ? '${aircraft['max_speed_knots']} узлов'
                  : 'Скорость: Н/Д';
              return Dismissible(
                key: ObjectKey(aircraft),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  margin: const EdgeInsets.symmetric(
                      vertical: 6, horizontal: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) => widget.onToggleFavorite(aircraft),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => showAircraftDetails(context, aircraft),
                  child: Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(
                        vertical: 6, horizontal: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.red.shade50,
                        child: const Icon(Icons.favorite,
                            color: Colors.red),
                      ),
                      title: Text(
                        '${aircraft['manufacturer'] ?? ''} ${aircraft['model'] ?? ''}',
                        style:
                        const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                          '${aircraft['engine_type'] ?? 'Тип двигателя не указан'} • $speed'),
                      trailing: const Icon(Icons.arrow_forward_ios,
                          size: 16),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
