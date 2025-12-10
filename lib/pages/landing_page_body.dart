import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:layout_x1/pages/articles/articlepage.dart';
import '../services/api_service.dart';
import 'package:layout_x1/pages/productspage.dart';
import 'package:layout_x1/pages/articles/articledetailpage.dart';
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
        // fallback to local JSON if API fails
        final jsonString = await rootBundle.loadString('assets/data/articles.json');
        final data = json.decode(jsonString);
        setState(() {
          _articles = data;
        });
      }
    } catch (e) {
      // If anything goes wrong, fallback to bundled JSON
      final jsonString = await rootBundle.loadString('assets/data/articles.json');
      final data = json.decode(jsonString);
      setState(() {
        _articles = data;
      });
    }
  }

  Future<void> _loadProducts() async {
    final jsonString = await rootBundle.loadString('assets/data/products.json');
    final data = json.decode(jsonString);
    setState(() {
      _products = data;
    });
  }

  void _navigateToArticles() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ArticlesPageBody()),
    );
  }

  void _navigateToProducts() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProductsPage()),
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
                  onTap: () => Navigator.pushNamed(context, '/deteksikulitwajah'),
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
                  onTap: () => Navigator.pushNamed(context, '/deteksikulittubuh'),
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
                    onPressed: _navigateToArticles,
                    child: const Text(
                      'Lihat Semua',
                      style: TextStyle(color: Color(0xFF0066CC)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // === Daftar Artikel (max 3) ===
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _articles.length > 3 ? 3 : _articles.length,
                itemBuilder: (context, index) {
                  final article = _articles[index];
                  return Card(
                    child: ListTile(
                      leading: Text(
                        article['image'] ?? '📄',
                        style: const TextStyle(fontSize: 28),
                      ),
                      title: Text(article['title'] ?? ''),
                      subtitle: Text(
                        getFirstSentence(article['description']),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ArticleDetailPage(article: article),
                        ),
                      ),
                    ),
                  );
                },
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
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _products.take(5).map((p) {
                          return _buildProductCard(
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

  Widget _buildProductCard(String? image, String title, String price) {
    return Container(
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
          // Gambar atau emoji produk
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Center(
              child: Text(image ?? '🧴', style: const TextStyle(fontSize: 40)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: TextStyle(color: Colors.redAccent, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
