import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Ganti dengan IP komputer kamu kalau testing di device fisik
  // Kalau di emulator, gunakan 10.0.2.2
  static const String baseUrl = 'http://192.168.100.1:5000/api';

  // Untuk device fisik, gunakan IP lokal komputer kamu
  // static const String baseUrl = 'http://192.168.1.xxx:5000/api';

  static http.Client? _client;

  // For testing purposes
  static set client(http.Client? client) => _client = client;

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await (_client ?? http.Client()).post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      return {
        'success': response.statusCode == 201,
        'message': data['message'],
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
        headers: {'Content-Type': 'application/json'},
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
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'google_id': googleId,
        }),
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

  // ---------------- Articles API ----------------
  static Future<Map<String, dynamic>> getArticles() async {
    try {
      final response = await (_client ?? http.Client()).get(
        Uri.parse('$baseUrl/articles'),
        headers: {'Content-Type': 'application/json'},
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
      final response = await (_client ?? http.Client()).get(
        Uri.parse('$baseUrl/articles/$articleId'),
        headers: {'Content-Type': 'application/json'},
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

  static Future<Map<String, dynamic>> createArticle({
    required String title,
    required String description,
    String? image,
  }) async {
    try {
      final response = await (_client ?? http.Client()).post(
        Uri.parse('$baseUrl/articles'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'title': title, 'description': description, 'image': image}),
      );

      final data = jsonDecode(response.body);

      return {
        'success': response.statusCode == 201,
        'message': data['message'],
        'data': data['data'],
      };
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateArticle({
    required int id,
    required String title,
    required String description,
    String? image,
  }) async {
    try {
      final response = await (_client ?? http.Client()).put(
        Uri.parse('$baseUrl/articles/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'title': title, 'description': description, 'image': image}),
      );

      final data = jsonDecode(response.body);

      return {
        'success': response.statusCode == 200,
        'message': data['message'],
      };
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server: $e'};
    }
  }

  static Future<Map<String, dynamic>> deleteArticle(int id) async {
    try {
      final response = await (_client ?? http.Client()).delete(
        Uri.parse('$baseUrl/articles/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body);

      return {
        'success': response.statusCode == 200,
        'message': data['message'],
      };
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server: $e'};
    }
  }

  // ---------------- Products API ----------------
  static Future<Map<String, dynamic>> getProducts() async {
    try {
      final response = await (_client ?? http.Client()).get(
        Uri.parse('$baseUrl/products'),
        headers: {'Content-Type': 'application/json'},
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
      final response = await (_client ?? http.Client()).get(
        Uri.parse('$baseUrl/products/$productId'),
        headers: {'Content-Type': 'application/json'},
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

  static Future<Map<String, dynamic>> createProduct({
    required String merek,
    required String nama,
    required int harga,
    required String kategoriPenyakit,
    String? image,
  }) async {
    try {
      final response = await (_client ?? http.Client()).post(
        Uri.parse('$baseUrl/products'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'merek': merek,
          'nama': nama,
          'harga': harga,
          'kategori_penyakit': kategoriPenyakit,
          'image': image
        }),
      );

      final data = jsonDecode(response.body);

      return {
        'success': response.statusCode == 201,
        'message': data['message'],
        'data': data['data'],
      };
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateProduct({
    required int id,
    required String merek,
    required String nama,
    required int harga,
    required String kategoriPenyakit,
    String? image,
  }) async {
    try {
      final response = await (_client ?? http.Client()).put(
        Uri.parse('$baseUrl/products/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'merek': merek,
          'nama': nama,
          'harga': harga,
          'kategori_penyakit': kategoriPenyakit,
          'image': image
        }),
      );

      final data = jsonDecode(response.body);

      return {
        'success': response.statusCode == 200,
        'message': data['message'],
      };
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server: $e'};
    }
  }

  static Future<Map<String, dynamic>> deleteProduct(int id) async {
    try {
      final response = await (_client ?? http.Client()).delete(
        Uri.parse('$baseUrl/products/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body);

      return {
        'success': response.statusCode == 200,
        'message': data['message'],
      };
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server: $e'};
    }
  }

  static Future<Map<String, dynamic>> getUser(int userId) async {
    try {
      final response = await (_client ?? http.Client()).get(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {'Content-Type': 'application/json'},
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

  static Future<bool> checkHealth() async {
    try {
      final response = await (_client ?? http.Client()).get(Uri.parse('$baseUrl/health'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
