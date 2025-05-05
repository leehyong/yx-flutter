import 'package:dio/dio.dart';
import 'package:dio_http2_adapter/dio_http2_adapter.dart';

class YooHttpClientAdapter {
  static HttpClientAdapter get adapter => Http2Adapter(
    ConnectionManager(
      idleTimeout: Duration(seconds: 10),
      onClientCreate: (_, config) => config.onBadCertificate = (_) => true,
    ),
  );
}
