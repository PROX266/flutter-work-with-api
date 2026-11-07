import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  final String apiKey;

  AuthInterceptor({required this.apiKey});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['X-Api-Key'] = apiKey;
    print('REQUEST[${options.method}] => PATH: ${options.path}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('ERROR[${err.message}] => PATH: ${err.requestOptions.path}');
    if (err.response != null) {
      print('STATUS: ${err.response?.statusCode}');
      print('BODY: ${err.response?.data}');
    }
    super.onError(err, handler);
  }
}
