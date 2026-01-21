import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ← INI WAJIB
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:layout_x1/services/api_service.dart';
import 'package:layout_x1/services/secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductDetailPage extends StatefulWidget {
  final int productId;
  final int userId;
  final String? returnTo; // 'faceDetection' or null (default to home)

  const ProductDetailPage({
    super.key,
    required this.productId,
    required this.userId,
    this.returnTo,
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
  int? replyingToCommentId;
  String? replyingToUserName;

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
  final FocusNode _commentFocusNode = FocusNode();

  Future<void> cekBPOM(String nomorReg) async {
    await Clipboard.setData(ClipboardData(text: nomorReg));

    final url = Uri.parse('https://cekbpom.pom.go.id');
    await launchUrl(url, mode: LaunchMode.externalApplication);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Nomor BPOM disalin, silakan paste di website BPOM'),
      ),
    );
  }

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
    final result = await ApiService.getProductComments(widget.productId);

    debugPrint('FETCH COMMENTS RESULT: $result');

    if (result['success'] == true && result['data'] != null) {
      setState(() {
        comments = List<Map<String, dynamic>>.from(result['data']);
        debugPrint('Comments loaded: ${comments.length}');
        for (var c in comments) {
          debugPrint('Comment: ${c['user_name']} - Replies: ${c['replies']}');
        }
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
        parentId: replyingToCommentId,
      );

      if (result['success'] == true) {
        debugPrint('Komentar berhasil ditambahkan');
        // Refresh comments list
        await fetchComments();
        _commentController.clear();
        setState(() {
          replyingToCommentId = null;
          replyingToUserName = null;
        });
      } else {
        debugPrint('Gagal tambah komentar: ${result['message']}');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menambah komentar')));
      }
    } catch (e) {
      debugPrint('Error adding comment: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan')));
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${result['message']}')));
      }
    } catch (e) {
      debugPrint('Error deleting comment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan saat menghapus')),
      );
    }
  }

  // Build nested replies recursively
  Widget _buildReplyTree(Map<String, dynamic> comment, int depth) {
    final isOwner = comment['user_id'] == userId;
    final replies = comment['replies'] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(
            left: depth == 0 ? 0 : 16.0, // Only first level indent
            bottom: 12,
          ),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: depth == 0 ? Colors.grey.shade100 : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: depth > 0
                ? Border(
                    left: BorderSide(color: const Color(0xFF0066CC), width: 3),
                  )
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      comment['parent_user_name'] != null
                          ? '${comment['user_name']} ▶ ${comment['parent_user_name']}'
                          : comment['user_name'] ?? '-',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0066CC),
                        fontSize: depth == 0 ? 14 : 12,
                      ),
                    ),
                  ),
                  if (isOwner)
                    IconButton(
                      icon: const Icon(Icons.delete),
                      iconSize: depth == 0 ? 18 : 14,
                      color: Colors.red,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Hapus Komentar'),
                            content: const Text('Apakah Anda yakin?'),
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
                                child: const Text(
                                  'Hapus',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                comment['comment'] ?? '',
                style: TextStyle(fontSize: depth == 0 ? 14 : 12),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      comment['created_at'] ?? '',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  icon: const Icon(Icons.reply, size: 14),
                  label: const Text('Balas', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: () {
                    setState(() {
                      replyingToCommentId = comment['id'];
                      replyingToUserName = comment['user_name'];
                    });
                    _commentFocusNode.requestFocus();
                  },
                ),
              ),
            ],
          ),
        ),
        // Recursively build nested replies - all at same indent level
        if (replies.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(left: depth == 0 ? 16.0 : 0),
            child: Column(
              children: replies
                  .map<Widget>((reply) => _buildReplyTree(reply, depth + 1))
                  .toList(),
            ),
          ),
      ],
    );
  }

  @override
  String _formatHarga(dynamic harga) {
    if (harga == null) return '-';

    final numHarga = harga is num
        ? harga
        : double.tryParse(
                harga.toString().replaceAll(RegExp(r'[^0-9.]'), ''),
              ) ??
              0;

    if (numHarga <= 0) return '-';

    return 'Rp${numHarga.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

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
              // Return to face detection if coming from there, otherwise just pop
              if (widget.returnTo == 'faceDetection') {
                Navigator.of(context).pop({'changed': _favoriteChanged});
              } else {
                Navigator.pop(context, {'changed': _favoriteChanged});
              }
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
                Container(
                  height: 350,
                  width: double.infinity,
                  color: Colors.white,
                  child: Image.network(
                    product!['image'].toString().startsWith('http')
                        ? product!['image'].toString()
                        : '$baseUrl/web/uploads/${product!['image']}',
                    height: 350,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 350,
                        color: Colors.grey[200],
                        child: Center(
                          child: Icon(
                            Icons.medical_services,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                        ),
                      );
                    },
                  ),
                )
              else
                Container(
                  height: 350,
                  color: Colors.grey[200],
                  child: Center(
                    child: Icon(
                      Icons.medical_services,
                      size: 80,
                      color: Colors.grey[400],
                    ),
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
                      _formatHarga(product!['harga']),
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
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
                    Text(
                      'Nomor registrasi (BPOM): ${product!['nomor_registrasi']}',
                    ),

                    ElevatedButton.icon(
                      icon: Icon(Icons.verified),
                      label: Text('Cek BPOM'),
                      onPressed: () {
                        cekBPOM(product!['nomor_registrasi']);
                      },
                    ),

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
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          return _buildReplyTree(comment, 0);
                        },
                      ),

                    const SizedBox(height: 12),

                    // REPLY INDICATOR
                    if (replyingToCommentId != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF0066CC)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Membalas: ',
                                  style: TextStyle(
                                    color: Color(0xFF0066CC),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  replyingToUserName ?? '',
                                  style: const TextStyle(
                                    color: Color(0xFF0066CC),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  replyingToCommentId = null;
                                  replyingToUserName = null;
                                });
                                _commentController.clear();
                              },
                              icon: const Icon(Icons.close, size: 18),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),

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
                              focusNode: _commentFocusNode,
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
