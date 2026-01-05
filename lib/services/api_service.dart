import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'secure_storage.dart';

class ApiService {
  static const String baseUrl =
      'http://192.168.100.1:5000/api';

  static http.Client? _client;

  // For testing purposes
  static set client(http.Client? client) => _client = client;

  /// Helper method to get headers with authentication token
  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await SecureStorage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Helper method to get headers without authentication (for public endpoints)
  static Map<String, String> _getHeaders() {
    return {'Content-Type': 'application/json'};
  }

  // ================= PUBLIC ENDPOINTS (No Auth Required) =================

  /// Kirim OTP ke email
  static Future<Map<String, dynamic>> sendOtp({required String email}) async {
    try {
      final response = await (_client ?? http.Client()).post(
        Uri.parse('$baseUrl/send-otp'),
        headers: _getHeaders(),
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body);

      return {
        'success': response.statusCode == 200,
        'message': data['message'] ?? 'Unknown error',
      };
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server: $e'};
    }
  }

  /// Verifikasi OTP
  static Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await (_client ?? http.Client()).post(
        Uri.parse('$baseUrl/verify-otp'),
        headers: _getHeaders(),
        body: jsonEncode({'email': email, 'otp': otp}),
      );

      final data = jsonDecode(response.body);

      return {
        'success': response.statusCode == 200,
        'message': data['message'] ?? 'Unknown error',
      };
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server: $e'};
    }
  }

  /// Register dengan OTP
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String otp,
  }) async {
    try {
      final response = await (_client ?? http.Client()).post(
        Uri.parse('$baseUrl/register'),
        headers: _getHeaders(),
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'otp': otp,
        }),
      );

      final data = jsonDecode(response.body);

      return {
        'success': response.statusCode == 201,
        'message': data['message'] ?? 'Unknown error',
        'data': data['data'],
      };
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server: $e'};
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await (_client ?? http.Client()).post(
        Uri.parse('$baseUrl/login'),
        headers: _getHeaders(),
        body: jsonEncode({'email': email, 'password': password}),
      );
      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': data['message'],
        'data': data['data'],
      };
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server: $e'};
    }
  }

  static Future<Map<String, dynamic>> googleSignIn({
    required String name,
    required String email,
    required String googleId,
  }) async {
    try {
      final response = await (_client ?? http.Client()).post(
        Uri.parse('$baseUrl/google-signin'),
        headers: _getHeaders(),
        body: jsonEncode({'name': name, 'email': email, 'google_id': googleId}),
      );
      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200 || response.statusCode == 201,
        'message': data['message'],
        'data': data['data'],
      };
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server: $e'};
    }
  }

  static Future<bool> checkHealth() async {
    try {
      final response = await (_client ?? http.Client()).get(
        Uri.parse('$baseUrl/health'),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ================= ARTICLES API =================

  static Future<Map<String, dynamic>> getArticles() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await (_client ?? http.Client()).get(
        Uri.parse('$baseUrl/articles'),
        headers: headers,
      );
      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': data['message'] ?? 'Success',
        'data': data['data'],
      };
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server: $e'};
    }
  }

  static Future<Map<String, dynamic>> getArticle(int articleId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await (_client ?? http.Client()).get(
        Uri.parse('$baseUrl/articles/$articleId'),
        headers: headers,
      );
      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': data['message'] ?? 'Success',
        'data': data['data'],
      };
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server: $e'};
    }
  }

  static Future<Map<String, dynamic>> getFavoriteArticles(int userId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await (_client ?? http.Client()).get(
        Uri.parse('$baseUrl/articles/favorites?user_id=$userId'),
        headers: headers,
      );
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Body: ${response.body}');
      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': data['message'] ?? 'Success',
        'data': data['data'],
      };
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server: $e'};
    }
  }

  // ================= PRODUCTS API =================

  static Future<Map<String, dynamic>> getProducts() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await (_client ?? http.Client()).get(
        Uri.parse('$baseUrl/products'),
        headers: headers,
      );
      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': data['message'] ?? 'Success',
        'data': data['data'],
      };
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server: $e'};
    }
  }

  static Future<Map<String, dynamic>> getProduct(int productId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await (_client ?? http.Client()).get(
        Uri.parse('$baseUrl/products/$productId'),
        headers: headers,
      );
      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': data['message'] ?? 'Success',
        'data': data['data'],
      };
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server: $e'};
    }
  }

  static Future<Map<String, dynamic>> getFavoriteProducts(int userId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await (_client ?? http.Client()).get(
        Uri.parse('$baseUrl/products/favorites?user_id=$userId'),
        headers: headers,
      );
      debugPrint('PRODUCT STATUS: ${response.statusCode}');
      debugPrint('PRODUCT BODY: ${response.body}');
      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': data['message'] ?? 'Success',
        'data': data['data'],
      };
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server: $e'};
    }
  }

  // ================= USER API (Authenticated) =================

  static Future<Map<String, dynamic>> getUser(int userId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await (_client ?? http.Client()).get(
        Uri.parse('$baseUrl/users/$userId'),
        headers: headers,
      );
      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': data['message'] ?? 'Success',
        'data': data['data'],
      };
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server: $e'};
    }
  }

  // ================= DAILY FOOD LOGS (Authenticated) =================

  static Future<Map<String, dynamic>> getFoods() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await (_client ?? http.Client()).get(
        Uri.parse('$baseUrl/foods'),
        headers: headers,
      );

      final data = jsonDecode(response.body);

      return {'success': response.statusCode == 200, 'data': data['data']};
    } catch (e) {
      return {'success': false, 'message': 'Gagal fetch makanan: $e'};
    }
  }

  static Future<Map<String, dynamic>> createDailyFoodLog({
    required int userId,
    required int foodId,
    required int quantity,
    required String logDate,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await (_client ?? http.Client()).post(
        Uri.parse('$baseUrl/daily-food-logs'),
        headers: headers,
        body: jsonEncode({
          'user_id': userId,
          'food_id': foodId,
          'quantity': quantity,
          'log_date': logDate,
        }),
      );

      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 201,
        'message': data['message'],
        'data': data['data'],
      };
    } catch (e) {
      return {'success': false, 'message': 'Gagal log makanan: $e'};
    }
  }

  // ================= DAILY DRINK LOGS (Authenticated) =================

  static Future<Map<String, dynamic>> getDrinks() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await (_client ?? http.Client()).get(
        Uri.parse('$baseUrl/drinks'),
        headers: headers,
      );

      final data = jsonDecode(response.body);

      return {'success': response.statusCode == 200, 'data': data['data']};
    } catch (e) {
      return {'success': false, 'message': 'Gagal fetch minuman: $e'};
    }
  }

  static Future<Map<String, dynamic>> createDailyDrinkLog({
    required int userId,
    required int drinkId,
    required int quantity,
    required String logDate,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await (_client ?? http.Client()).post(
        Uri.parse('$baseUrl/daily-drink-logs'),
        headers: headers,
        body: jsonEncode({
          'user_id': userId,
          'drink_id': drinkId,
          'quantity': quantity,
          'log_date': logDate,
        }),
      );

      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 201,
        'message': data['message'],
        'data': data['data'],
      };
    } catch (e) {
      return {'success': false, 'message': 'Gagal log minuman: $e'};
    }
  }

  // ================= DAILY SLEEP LOGS (Authenticated) =================

  static Future<Map<String, dynamic>> createDailySleepLog({
    required int userId,
    required String logDate,
    required double sleepHours,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await (_client ?? http.Client()).post(
        Uri.parse('$baseUrl/daily-sleep-logs'),
        headers: headers,
        body: jsonEncode({
          'user_id': userId,
          'log_date': logDate,
          'sleep_hours': sleepHours,
        }),
      );

      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 201,
        'message': data['message'],
      };
    } catch (e) {
      return {'success': false, 'message': 'Gagal log tidur: $e'};
    }
  }

  // ================= SKIN ANALYSIS (Authenticated) =================

  static Future<Map<String, dynamic>> generateSkinAnalysis({
    required int userId,
    required String logDate,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await (_client ?? http.Client()).post(
        Uri.parse('$baseUrl/skin-analysis'),
        headers: headers,
        body: jsonEncode({'user_id': userId, 'log_date': logDate}),
      );

      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 201,
        'message': data['message'],
        'data': data['data'],
      };
    } catch (e) {
      return {'success': false, 'message': 'Gagal generate analisis: $e'};
    }
  }

  static Future<Map<String, dynamic>> getSkinAnalysis({
    required int userId,
    required String logDate,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await (_client ?? http.Client()).get(
        Uri.parse('$baseUrl/skin-analysis?user_id=$userId&log_date=$logDate'),
        headers: headers,
      );

      final data = jsonDecode(response.body);
      return {'success': response.statusCode == 200, 'data': data['data']};
    } catch (e) {
      return {'success': false, 'message': 'Gagal ambil analisis: $e'};
    }
  }

  // GET History Analysis
  static Future<Map<String, dynamic>> getAnalysisHistory(int userId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await (_client ?? http.Client()).get(
        Uri.parse('$baseUrl/skin-analysis/history?user_id=$userId'),
        headers: headers,
      );

      // Debugging response
      if (kDebugMode) {
        print('History Response: ${response.body}');
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data['data'], // Ini List of objects
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengambil data',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}