import 'package:flutter/material.dart';
import 'package:layout_x1/pages/articles/articlepage.dart';
import 'package:layout_x1/services/api_service.dart';
import 'package:layout_x1/pages/products/productspage.dart';
import 'package:layout_x1/pages/articles/articledetailpage.dart';
import 'package:layout_x1/pages/products/productdetailpage.dart';
import 'user_preferences.dart';

class LandingPageBody extends StatefulWidget {
  @override
  State<LandingPageBody> createState() => _LandingPageBodyState();
}

class _LandingPageBodyState extends State<LandingPageBody> {
  List<dynamic> _articles = [];
  List<dynamic> _products = [];
  String _userName = 'Beranda';
  bool _isLoadingUser = true;

  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadArticles();
    _loadProducts();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    try {
      final userData = await UserPreferences.getUser();

      if (userData != null) {
        setState(() {
          _userId = userData['id'];
          _userName = userData['name'];
          _isLoadingUser = false;
        });
      } else {
        setState(() {
          _userName = 'Beranda';
          _isLoadingUser = false;
        });
      }
    } catch (e) {
      setState(() {
        _userName = 'Beranda';
        _isLoadingUser = false;
      });
    }
  }

  Future<void> _loadArticles() async {
    try {
      final result = await ApiService.getArticles();
      if (result['success']) {
        setState(() {
          _articles = result['data'] ?? [];
        });
      } else {
        setState(() {
          _articles = [];
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Gagal memuat artikel'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _articles = [];
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadProducts() async {
    try {
      final result = await ApiService.getProducts();
      if (result['success']) {
        setState(() {
          _products = result['data'] ?? [];
        });
      } else {
        setState(() {
          _products = [];
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Gagal memuat produk'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _products = [];
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToArticles() {
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan login terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ArticlesPageBody(userId: _userId!)),
    );
  }

  void _navigateToProducts() {
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan login terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductsPage(
          userId: _userId!, // ✅ KIRIM USER ID
        ),
      ),
    );
  }

  // Helper function untuk ambil kalimat pertama dari deskripsi
  String getFirstSentence(String? text) {
    if (text == null || text.isEmpty) return '';
    final sentences = text.split(RegExp(r'[.!?]'));
    if (sentences.isEmpty) return text;
    String firstSentence = sentences[0].trim();
    if (!firstSentence.endsWith('.') &&
        !firstSentence.endsWith('!') &&
        !firstSentence.endsWith('?')) {
      firstSentence += '.';
    }
    return firstSentence;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: _isLoadingUser
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                children: [
                  const Icon(Icons.person, color: Colors.amber, size: 24),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Halo, $_userName',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==== DETEKSI KULIT ====
              const Text(
                "Deteksi Kulit",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // === Kartu Deteksi Kulit Wajah ===
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFF0066CC), width: 2),
                ),
                child: InkWell(
                  onTap: () =>
                      Navigator.pushNamed(context, '/deteksikulitwajah'),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0066CC).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.face,
                            color: Color(0xFF0066CC),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            'Deteksi Kulit Wajah\nAnalisis kondisi kulit wajah dengan AI.',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // === Kartu Deteksi Kulit Tubuh ===
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFF0066CC), width: 2),
                ),
                child: InkWell(
                  onTap: () =>
                      Navigator.pushNamed(context, '/deteksikulittubuh'),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0066CC).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.accessibility_new,
                            color: Color(0xFF0066CC),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            'Deteksi Kulit Tubuh\nAnalisis kondisi kulit pada tubuh menggunakan AI.',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ==== ARTIKEL TERKINI ====
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Artikel & Berita Terkini',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: _userId == null ? null : _navigateToArticles,
                    child: const Text('Lihat Semua'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              _articles.isEmpty
                  ? const Center(child: Text('Belum ada artikel'))
                  : Column(
                      children: _articles.take(3).map((article) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: () {
                              if (_userId == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Silakan login terlebih dahulu',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ArticleDetailPage(
                                    article: article,
                                    userId: _userId!,
                                  ),
                                ),
                              );
                            },

                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      'http://localhost:5000/uploads/${article['image']}',
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.article,
                                        size: 120,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          article['title'] ?? '',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleMedium,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          getFirstSentence(
                                            article['description'],
                                          ),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
              const SizedBox(height: 20),

              // ==== REKOMENDASI PRODUK ====
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Rekomendasi Produk',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: _navigateToProducts,
                    child: const Text(
                      'Lihat Semua',
                      style: TextStyle(color: Color(0xFF0066CC)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // === Daftar Produk (max 5) ===
              _products.isEmpty
                  ? const Center(child: Text('Belum ada produk'))
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _products.take(5).map((p) {
                          return _buildProductCard(
                            context,
                            p['id'],
                            p['image'],
                            p['merek'] ?? '',
                            'Rp ${p['harga']}',
                          );
                        }).toList(),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    int productId,
    String? image,
    String title,
    String price,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (_userId == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Silakan login terlebih dahulu'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  ProductDetailPage(productId: productId, userId: _userId!),
            ),
          );
        },

        child: Container(
          width: 150,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.network(
                  'http://localhost:5000/uploads/${image ?? ''}',
                  width: 150,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 150,
                    height: 120,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Text('🧴', style: TextStyle(fontSize: 40)),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      price,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 12,
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
