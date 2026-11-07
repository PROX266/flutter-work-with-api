import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'interceptors/auth_interceptor.dart';
import 'pages/home_page.dart';

const String kApiNinjasKey = 'RjxjqgIC6MPtO2tQHruzkjSBEfN05wvVLJG0yGN1';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupService();
  runApp(const AircraftApp());
}

void setupService() {
  GetIt.instance.registerLazySingleton<Dio>(() => Dio(
    BaseOptions(
      baseUrl: 'https://api.api-ninjas.com/v1/',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  )..interceptors.addAll([
    AuthInterceptor(apiKey: kApiNinjasKey),
    PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
    ),
  ]));
}

class AircraftApp extends StatelessWidget {
  const AircraftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aircraft Catalog',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
