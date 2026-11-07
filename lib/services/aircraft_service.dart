import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

final service = GetIt.instance;

class AircraftService {
  Future<List<Map<String, dynamic>>> fetchAircraft({
    String? manufacturer,
    String? model,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (manufacturer != null && manufacturer.trim().isNotEmpty) {
        queryParams['manufacturer'] = manufacturer.trim();
      }
      if (model != null && model.trim().isNotEmpty) {
        queryParams['model'] = model.trim();
      }

      if (queryParams.isEmpty) {
        queryParams['manufacturer'] = 'Boeing';
      }

      final response = await service<Dio>().get(
        'aircraft',
        queryParameters: queryParams,
      );

      final List<dynamic> data = response.data as List<dynamic>;

      return data
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    } on DioException catch (e) {
      print('Ошибка API: ${e.message}');
      if (e.response != null) {
        print('Статус: ${e.response?.statusCode}');
        print('Тело: ${e.response?.data}');
      }
      rethrow;
    } catch (e) {
      print('Неожиданная ошибка: $e');
      rethrow;
    }
  }
}
