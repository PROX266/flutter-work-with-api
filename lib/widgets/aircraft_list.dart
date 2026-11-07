import 'package:flutter/material.dart';

import '../services/aircraft_service.dart';
import 'aircraft_details.dart';

enum SortMode { none, speedDesc, speedAsc, model }

class AircraftList extends StatefulWidget {
  final bool Function(Map<String, dynamic> item) isFavorite;
  final void Function(Map<String, dynamic> item) onToggleFavorite;

  const AircraftList({
    super.key,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  @override
  State<AircraftList> createState() => _AircraftListState();
}

class _AircraftListState extends State<AircraftList> {
  final AircraftService _aircraftService = AircraftService();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _aircrafts = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _activeCategory = 'Boeing';
  SortMode _sortMode = SortMode.none;

  final List<String> _quickFilters = [
    'Boeing',
    'Airbus',
    'Cessna',
    'Antonov',
    'Bombardier',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.text = _activeCategory;
    _loadAircraft(manufacturer: _activeCategory);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  double _speed(Map<String, dynamic> a) =>
      double.tryParse('${a['max_speed_knots']}') ?? 0;

  void _applySort() {
    switch (_sortMode) {
      case SortMode.speedDesc:
        _aircrafts.sort((a, b) => _speed(b).compareTo(_speed(a)));
        break;
      case SortMode.speedAsc:
        _aircrafts.sort((a, b) => _speed(a).compareTo(_speed(b)));
        break;
      case SortMode.model:
        _aircrafts.sort((a, b) => '${a['model']}'.compareTo('${b['model']}'));
        break;
      case SortMode.none:
        break;
    }
  }

  Future<void> _loadAircraft({String? manufacturer, String? model}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await _aircraftService.fetchAircraft(
        manufacturer: manufacturer,
        model: model,
      );
      if (!mounted) return;
      setState(() {
        _aircrafts = results;
        _applySort();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
        'Не удалось загрузить данные. Проверьте сеть и API-ключ.';
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при загрузке: $e')),
      );
    }
  }

  void _onSearchSubmitted() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      setState(() {
        _activeCategory = '';
      });
      _loadAircraft(model: query);
    }
  }

  void _selectQuickFilter(String manufacturer) {
    setState(() {
      _activeCategory = manufacturer;
      _searchController.text = manufacturer;
    });
    _loadAircraft(manufacturer: manufacturer);
  }

  void _hideAircraft(int index) {
    final removed = _aircrafts[index];
    setState(() => _aircrafts.removeAt(index));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Скрыто: ${removed['manufacturer']} ${removed['model']}'),
          action: SnackBarAction(
            label: 'Отменить',
            onPressed: () {
              setState(() {
                final at = index > _aircrafts.length ? _aircrafts.length : index;
                _aircrafts.insert(at, removed);
              });
            },
          ),
        ),
      );
  }

  Widget _buildCard(int index) {
    final aircraft = _aircrafts[index];
    final manufacturer = aircraft['manufacturer'] ?? 'Неизвестно';
    final model = aircraft['model'] ?? 'Без модели';
    final engine = aircraft['engine_type'] ?? 'Тип двигателя не указан';
    final speed = aircraft['max_speed_knots'] != null
        ? '${aircraft['max_speed_knots']} узлов'
        : 'Скорость: Н/Д';
    final isFav = widget.isFavorite(aircraft);

    return Dismissible(
      key: ObjectKey(aircraft),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.visibility_off, color: Colors.white),
      ),
      onDismissed: (_) => _hideAircraft(index),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => showAircraftDetails(context, aircraft),
        onLongPress: () => widget.onToggleFavorite(aircraft),
        child: Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: const Icon(Icons.airplanemode_active, color: Colors.blue),
            ),
            title: Text(
              '$manufacturer $model',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('$engine • $speed'),
            trailing: IconButton(
              icon: Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
                color: Colors.red,
              ),
              onPressed: () => widget.onToggleFavorite(aircraft),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12.0),
          color: Colors.blue.shade50,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Поиск по модели (например, 737, A320)...',
                    prefixIcon: const Icon(Icons.flight),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
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
                  onSubmitted: (_) => _onSearchSubmitted(),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _onSearchSubmitted,
                style: ElevatedButton.styleFrom(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Icon(Icons.search),
              ),
            ],
          ),
        ),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _quickFilters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final item = _quickFilters[index];
              final isSelected = _activeCategory == item;
              return ChoiceChip(
                label: Text(item),
                selected: isSelected,
                onSelected: (_) => _selectQuickFilter(item),
                selectedColor: Colors.blue.shade100,
              );
            },
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 4),
          child: Row(
            children: [
              Text(
                'Найдено: ${_aircrafts.length}',
                style: const TextStyle(color: Colors.grey),
              ),
              const Spacer(),
              PopupMenuButton<SortMode>(
                icon: const Icon(Icons.sort),
                tooltip: 'Сортировка',
                onSelected: (mode) {
                  setState(() {
                    _sortMode = mode;
                    _applySort();
                  });
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: SortMode.speedDesc,
                    child: Text('Скорость: по убыванию'),
                  ),
                  PopupMenuItem(
                    value: SortMode.speedAsc,
                    child: Text('Скорость: по возрастанию'),
                  ),
                  PopupMenuItem(
                    value: SortMode.model,
                    child: Text('Модель: А–Я'),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    size: 48, color: Colors.red),
                const SizedBox(height: 12),
                Text(_errorMessage!, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => _loadAircraft(
                    manufacturer: _activeCategory.isNotEmpty
                        ? _activeCategory
                        : null,
                    model: _searchController.text.isNotEmpty
                        ? _searchController.text
                        : null,
                  ),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Повторить'),
                ),
              ],
            ),
          )
              : _aircrafts.isEmpty
              ? const Center(
            child: Text(
              'Самолёты не найдены.\nПопробуйте изменить поисковый запрос.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: _aircrafts.length,
            itemBuilder: (context, index) => _buildCard(index),
          ),
        ),
      ],
    );
  }
}
