import 'package:flutter/material.dart';

Widget detailRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        Expanded(child: Text(value.isNotEmpty ? value : '—')),
      ],
    ),
  );
}

String _fmt(dynamic value, String unit, [double k = 1.0]) {
  if (value == null || value.toString().isEmpty) return 'Н/Д';
  if (k == 1.0) return '$value $unit';
  final n = double.tryParse(value.toString());
  if (n == null) return 'Н/Д';
  return '${(n * k).toStringAsFixed(0)} $unit';
}

void showAircraftDetails(BuildContext context, Map<String, dynamic> item) {
  bool metric = false;

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) {
        return AlertDialog(
          title: Text('${item['manufacturer'] ?? ''} ${item['model'] ?? ''}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Expanded(child: Text('Метрическая система')),
                    Switch(
                      value: metric,
                      onChanged: (v) => setDialogState(() => metric = v),
                    ),
                  ],
                ),
                const Divider(),
                detailRow('Тип двигателя:', '${item['engine_type'] ?? ''}'),
                detailRow('Тяга двигателей:',
                    _fmt(item['engine_thrust_lb_ft'], 'lb-ft')),
                detailRow(
                    'Крейсерская скорость:',
                    metric
                        ? _fmt(item['cruise_speed_knots'], 'км/ч', 1.852)
                        : _fmt(item['cruise_speed_knots'], 'узлов')),
                detailRow(
                    'Макс. скорость:',
                    metric
                        ? _fmt(item['max_speed_knots'], 'км/ч', 1.852)
                        : _fmt(item['max_speed_knots'], 'узлов')),
                detailRow(
                    'Потолок высоты:',
                    metric
                        ? _fmt(item['ceiling_ft'], 'м', 0.3048)
                        : _fmt(item['ceiling_ft'], 'фут')),
                detailRow(
                    'Дальность полёта:',
                    metric
                        ? _fmt(item['range_nautical_miles'], 'км', 1.852)
                        : _fmt(item['range_nautical_miles'], 'мор. миль')),
                detailRow(
                    'Длина:',
                    metric
                        ? _fmt(item['length_ft'], 'м', 0.3048)
                        : _fmt(item['length_ft'], 'фут')),
                detailRow(
                    'Размах крыльев:',
                    metric
                        ? _fmt(item['wing_span_ft'], 'м', 0.3048)
                        : _fmt(item['wing_span_ft'], 'фут')),
                detailRow(
                    'Взлётная масса:',
                    metric
                        ? _fmt(item['gross_weight_lbs'], 'кг', 0.45359237)
                        : _fmt(item['gross_weight_lbs'], 'фунтов')),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Закрыть'),
            ),
          ],
        );
      },
    ),
  );
}
