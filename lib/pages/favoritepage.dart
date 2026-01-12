import 'package:flutter/material.dart';
import 'package:layout_x1/pages/articles/articledetailpage.dart';
import 'package:layout_x1/pages/products/productdetailpage.dart';
import 'package:layout_x1/services/api_service.dart';
import '../services/user_preferences.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  List<dynamic> _favoriteArticles = [];
  List<dynamic> _favoriteProducts = [];
  int? _userId;
  bool _isLoading = true;

  // Get base URL for uploads (without /api suffix)
  String get baseUrl => ApiService.baseUrl.replaceAll('/api', '');

  @override
  void initState() {
    super.initState();
    _loadUserAndFavorites();
  }

  Future<void> _loadUserAndFavorites() async {
    try {
      final user = await UserPreferences.getUser();

      if (user == null) {
        debugPrint('User belum login');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      _userId = user['id'];

      final articles = await ApiService.getFavoriteArticles(_userId!);
      final products = await ApiService.getFavoriteProducts(_userId!);

      setState(() {
        _favoriteArticles = articles['data'] ?? [];
        _favoriteProducts = products['data'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Favorite error: $e');

      setState(() {
        _isLoading = false;
      });
    }
  }

  String getFirstSentence(String? text) {
    if (text == null || text.isEmpty) return '';
    final parts = text.split(RegExp(r'[.!?]'));
    return '${parts.first.trim()}.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite'),
        backgroundColor: const Color(0xFF0066CC),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ===== ARTIKEL FAVORIT =====
                  const Text(
                    'Artikel Favorit',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  _favoriteArticles.isEmpty
                      ? const Text('Belum ada artikel favorit')
                      : Column(
                          children: _favoriteArticles.map((article) {
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: InkWell(
                                onTap: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ArticleDetailPage(
                                        article: article,
                                        userId: _userId!,
                                      ),
                                    ),
                                  );

                                  // 🔁 JIKA ADA PERUBAHAN, RELOAD FAVORITE
                                  if (result != null &&
                                      result['changed'] == true) {
                                    _loadUserAndFavorites();
                                  }
                                },

                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          '$baseUrl/web/uploads/${article['image']}',
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(
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

                  const SizedBox(height: 24),

                  /// ===== PRODUK FAVORIT =====
                  const Text(
                    'Produk Favorit',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  _favoriteProducts.isEmpty
                      ? const Text('Belum ada produk favorit')
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _favoriteProducts.map((p) {
                              return GestureDetector(
                                onTap: () async {
                                  final productId = int.tryParse(
                                    p['id'].toString(),
                                  );

                                  if (productId == null) return;

                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ProductDetailPage(
                                        productId: productId,
                                        userId: _userId!,
                                      ),
                                    ),
                                  );
                                  
                                  if (result != null &&
                                      result['changed'] == true) {
                                    _loadUserAndFavorites();
                                  }
                                },
                                child: _buildProductCard(
                                  p['image'],
                                  p['merek'] ?? '',
                                  'Rp ${p['harga']}',
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                ],
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
          BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 5),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: image == null
                ? Container(
                    height: 120,
                    width: 150,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.shopping_bag, size: 40),
                    ),
                  )
                : Image.network(
                    '$baseUrl/web/uploads/$image',
                    height: 120,
                    width: 150,
                    fit: BoxFit.cover,
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
