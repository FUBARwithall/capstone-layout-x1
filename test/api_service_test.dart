import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:layout_x1/services/api_service.dart';

void main() {
  group('ApiService Unit Tests', () {
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient((request) async {
        if (request.url.path == '/health') {
          return http.Response('', 200);
        }
        return http.Response('Not Found', 404);
      });
      ApiService.client = mockClient;
    });

    tearDown(() {
      ApiService.client = null;
    });

    test('checkHealth returns true for status 200', () async {
      final result = await ApiService.checkHealth();
      expect(result, true);
    });

    test('checkHealth returns false for status 500', () async {
      mockClient = MockClient((request) async {
        return http.Response('', 500);
      });
      ApiService.client = mockClient;

      final result = await ApiService.checkHealth();
      expect(result, false);
    });

    test('checkHealth returns false on exception', () async {
      mockClient = MockClient((request) async {
        throw Exception('Network error');
      });
      ApiService.client = mockClient;

      final result = await ApiService.checkHealth();
      expect(result, false);
    });
  });
}