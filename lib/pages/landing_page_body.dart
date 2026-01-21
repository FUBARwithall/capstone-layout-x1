import 'package:flutter/material.dart';
import 'package:layout_x1/pages/articles/articlepage.dart';
import 'package:layout_x1/services/api_service.dart';
import 'package:layout_x1/pages/products/productspage.dart';
import 'package:layout_x1/pages/articles/articledetailpage.dart';
import 'package:layout_x1/pages/products/productdetailpage.dart';
import 'package:layout_x1/utils/html_helper.dart';
import '../services/user_preferences.dart';

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

  // Get base URL for uploads (without /api suffix)
  String get baseUrl => ApiService.baseUrl.replaceAll('/api', '');

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
      MaterialPageRoute(builder: (_) => ProductsPage(userId: _userId!)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
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
              const Text(
                "Deteksi Kulit",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

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
                            color: const Color(
                              0xFF0066CC,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.face_retouching_natural_outlined,
                            color: Color(0xFF0066CC),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Deteksi Kulit Wajah',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Analisis kondisi kulit wajah dengan AI.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

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
                            color: const Color(
                              0xFF0066CC,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.accessibility,
                            color: Color(0xFF0066CC),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Deteksi Kulit Tubuh',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Analisis kondisi kulit pada tubuh menggunakan AI.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Artikel & Berita Terkini',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _userId == null ? null : _navigateToArticles,
                    child: const Text(
                      'Lihat Semua',
                      style: TextStyle(color: Color(0xFF0066CC)),
                    ),
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
                                      '$baseUrl/web/uploads/${article['image']}',
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
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          getFirstSentence(
                                            htmlToPlainText(
                                              article['description'] ?? '',
                                            ),
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

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Rekomendasi Produk',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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

              _products.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text('Belum ada produk'),
                      ),
                    )
                  : SizedBox(
                      height: 240, // Fixed height
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        itemCount: _products.length > 5 ? 5 : _products.length,
                        itemBuilder: (context, index) {
                          final p = _products[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: _buildProductCard(
                              context,
                              int.tryParse(p['id'].toString()) ?? 0,
                              p['image'],
                              // p['merek'] ?? '', // Brand
                              p['nama'] ?? '', // Name
                              'Rp ${p['harga']}',
                            ),
                          );
                        },
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
    // String brand,
    String name,
    dynamic price,
  ) {
    String formattedPrice = '-';
    if (price != null) {
      final numPrice = price is num
          ? price
          : double.tryParse(
                  price.toString().replaceAll(RegExp(r'[^0-9.]'), ''),
                ) ??
                0;

      if (numPrice > 0) {
        formattedPrice =
            'Rp${numPrice.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
      }
    }

    return GestureDetector(
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: image != null && image.isNotEmpty
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.network(
                          image.startsWith('http')
                              ? image
                              : '$baseUrl/web/uploads/$image',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                Icons.medical_services,
                                size: 40,
                                color: Colors.grey[400],
                              ),
                            );
                          },
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.medical_services,
                          size: 40,
                          color: Colors.grey[400],
                        ),
                      ),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    name,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.black),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formattedPrice,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
