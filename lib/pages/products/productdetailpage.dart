import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:layout_x1/services/api_service.dart';
import 'package:layout_x1/services/secure_storage.dart';

class ProductDetailPage extends StatefulWidget {
  final int productId;
  final int userId;

  const ProductDetailPage({
    super.key,
    required this.productId,
    required this.userId,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  Map<String, dynamic>? product;
  bool isLoading = true;
  bool isLoved = false;
  bool _favoriteChanged = false;
  late int userId;
  List<Map<String, dynamic>> comments = [];

  // Get base URL for uploads (without /api suffix)
  String get baseUrl => ApiService.baseUrl.replaceAll('/api', '');

  @override
  void initState() {
    super.initState();
    userId = widget.userId;
    fetchProductDetail();
    fetchFavoriteStatus();
      fetchComments();
  }

  final TextEditingController _commentController = TextEditingController();

  Future<void> fetchProductDetail() async {
    final url = Uri.parse('${ApiService.baseUrl}/products/${widget.productId}');
    final token = await SecureStorage.getToken();

    try {
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http.get(url, headers: headers);
      final data = jsonDecode(response.body);

      debugPrint('PRODUCT STATUS: ${response.statusCode}');
      debugPrint('PRODUCT BODY: ${response.body}');

      if (response.statusCode == 200 && data['data'] != null) {
        final productData = data['data'];

        // Handle both array and object response formats
        Map<String, dynamic> productMap;
        if (productData is List) {
          if (productData.isEmpty) {
            setState(() => isLoading = false);
            debugPrint('Product list is empty');
            return;
          }
          productMap = productData[0] as Map<String, dynamic>;
        } else if (productData is Map) {
          productMap = productData as Map<String, dynamic>;
        } else {
          setState(() => isLoading = false);
          debugPrint('Invalid product data format');
          return;
        }

        setState(() {
          product = productMap;
          isLoading = false;
        });
        debugPrint('Product loaded: ${product!['nama']}');
      } else {
        setState(() => isLoading = false);
        debugPrint('Failed to load product: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Fetch product error: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchFavoriteStatus() async {
    final url = Uri.parse(
      '${ApiService.baseUrl}/products/${widget.productId}/favorite/status?user_id=$userId',
    );
    final token = await SecureStorage.getToken();

    try {
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http.get(url, headers: headers);
      final data = jsonDecode(response.body);

      setState(() {
        isLoved = data['favorite'] ?? false;
      });
    } catch (e) {
      debugPrint('Fetch product favorite error: $e');
    }
  }

  Future<void> toggleFavorite() async {
    final url = Uri.parse(
      '${ApiService.baseUrl}/products/${widget.productId}/favorite',
    );
    final token = await SecureStorage.getToken();

    try {
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      if (isLoved) {
        await http.delete(
          url,
          headers: headers,
          body: jsonEncode({'user_id': userId}),
        );

        setState(() {
          isLoved = false;
          _favoriteChanged = true;
        });
      } else {
        await http.post(
          url,
          headers: headers,
          body: jsonEncode({'user_id': userId}),
        );

        setState(() {
          isLoved = true;
          _favoriteChanged = true;
        });
      }
    } catch (e) {
      debugPrint('Toggle product favorite error: $e');
    }
  }

Future<void> fetchComments() async {
  final result =
      await ApiService.getProductComments(widget.productId);

  debugPrint('FETCH COMMENTS RESULT: $result');

  if (result['success'] == true && result['data'] != null) {
    setState(() {
      comments = List<Map<String, dynamic>>.from(result['data']);
      debugPrint('Comments loaded: ${comments.length}');
    });
  } else {
    debugPrint('Gagal ambil komentar: ${result['message']}');
  }
}

Future<void> addComment(String commentText) async {
  if (commentText.trim().isEmpty) return;

  try {
    final result = await ApiService.addProductComment(
      productId: widget.productId,
      comment: commentText,
    );

    if (result['success'] == true) {
      debugPrint('Komentar berhasil ditambahkan');
      // Refresh comments list
      await fetchComments();
      _commentController.clear();
    } else {
      debugPrint('Gagal tambah komentar: ${result['message']}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambah komentar')),
      );
    }
  } catch (e) {
    debugPrint('Error adding comment: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Terjadi kesalahan')),
    );
  }
}

Future<void> deleteComment(int commentId) async {
  try {
    final result = await ApiService.deleteProductComment(
      productId: widget.productId,
      commentId: commentId,
    );

    if (result['success'] == true) {
      debugPrint('Komentar berhasil dihapus');
      // Refresh comments list
      await fetchComments();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Komentar berhasil dihapus')),
      );
    } else {
      debugPrint('Gagal hapus komentar: ${result['message']}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${result['message']}')),
      );
    }
  } catch (e) {
    debugPrint('Error deleting comment: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Terjadi kesalahan saat menghapus')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (product == null) {
      return const Scaffold(
        body: Center(child: Text('Produk tidak ditemukan')),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (!didPop) {
          Navigator.pop(context, {'changed': _favoriteChanged});
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF0066CC),
          foregroundColor: Colors.white,
          title: Text(
            product!['merek'],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context, {'changed': _favoriteChanged});
            },
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: IconButton(
                icon: Icon(
                  isLoved ? Icons.favorite : Icons.favorite_border,
                  color: isLoved ? Colors.red : Colors.white,
                ),
                onPressed: toggleFavorite,
              ),
            ),
          ],
        ),

        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (product!['image'] != null &&
                  product!['image'].toString().isNotEmpty)
                Image.network(
                  '$baseUrl/web/uploads/${product!['image']}',
                  height: 350,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
              else
                Container(
                  height: 250,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.medical_services, size: 80),
                  ),
                ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product!['nama'],
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Rp ${product!['harga']}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        product!['kategori_penyakit'],
                        style: const TextStyle(
                          color: Color(0xFF0066CC),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Deskripsi Produk',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 8),

                    Text(product!['deskripsi'], textAlign: TextAlign.justify),

                    const SizedBox(height: 10),
                    Divider(),
                    const SizedBox(height: 10),

                    Text('Dosis: ${product!['dosis']}'),
                    SizedBox(height: 4),
                    Text('Efek samping: ${product!['efek_samping']}'),
                    SizedBox(height: 4),
                    Text('Komposisi: ${product!['komposisi']}'),
                    SizedBox(height: 4),
                    Text('Manufaktur: ${product!['manufaktur']}'),
                    SizedBox(height: 4),
                    Text('Nomor registrasi: ${product!['nomor_registrasi']}'),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    // ===== KOMENTAR =====
                    const Text(
                      'Komentar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // LIST KOMENTAR
                    if (comments.isEmpty == true)
                      const Text(
                        'Belum ada komentar',
                        style: TextStyle(color: Colors.grey),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: comments.isNotEmpty ? comments.length : 0,
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          final isOwner = comment['user_id'] == userId;
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      comment['user_name'] ?? '-',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0066CC),
                                      ),
                                    ),
                                    if (isOwner)
                                      IconButton(
                                        icon: const Icon(Icons.delete, size: 18),
                                        color: Colors.red,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('Hapus Komentar'),
                                              content: const Text('Apakah Anda yakin ingin menghapus komentar ini?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context),
                                                  child: const Text('Batal'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    deleteComment(comment['id']);
                                                  },
                                                  child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(comment['comment'] ?? ''),
                                const SizedBox(height: 6),
                                Text(
                                  comment['created_at'] ?? '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                    const SizedBox(height: 12),

                    // INPUT KOMENTAR
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _commentController,
                              minLines: 1,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                hintText: 'Tulis komentar...',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.send,
                              color: Color(0xFF0066CC),
                            ),
                            onPressed: () {
                              final text = _commentController.text.trim();
                              if (text.isNotEmpty) {
                                addComment(text);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
