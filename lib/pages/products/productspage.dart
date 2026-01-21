import 'package:flutter/material.dart';
import 'package:layout_x1/services/api_service.dart';
import 'package:layout_x1/pages/products/productdetailpage.dart';
import 'package:layout_x1/pages/products/productcategorypage.dart';

class ProductsPage extends StatefulWidget {
  final int userId;
  const ProductsPage({Key? key, required this.userId}) : super(key: key);
  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List<dynamic> _products = [];

  String get baseUrl => ApiService.baseUrl.replaceAll('/api', '');

  @override
  void initState() {
    super.initState();
    _loadProducts();
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    int crossAxisCount = 2;
    if (screenWidth > 600) crossAxisCount = 3;
    if (screenWidth > 900) crossAxisCount = 4;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Semua Produk'),
        backgroundColor: const Color(0xFF0066CC),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Tombol kategori
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProductCategoryPage(userId: widget.userId),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50), // tombol lebar penuh
                backgroundColor: const Color(0xFF0066CC),
                foregroundColor: Colors.white,
              ),
              child: const Text('Lihat Berdasarkan Kategori Produk'),
            ),
          ),

          // Grid produk
          Expanded(
            child: _products.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : LayoutBuilder(
                    builder: (context, constraints) {
                      return GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.7,
                        ),
                        itemCount: _products.length,
                        itemBuilder: (context, index) {
                          final p = _products[index];
                          return GestureDetector(
                            onTap: () {
                              final productId = int.tryParse(
                                p['id'].toString(),
                              );
                              if (productId == null) return;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProductDetailPage(
                                    productId: productId,
                                    userId: widget.userId,
                                  ),
                                ),
                              );
                            },
                            child: _buildProductCard(
                              p['image'],
                              p['merek'],
                              p['nama'],
                              "Rp ${p['harga']}",
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(
    String? image,
    String brand,
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

    return Container(
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
                Text(
                  brand,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
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
    );
  }
}
