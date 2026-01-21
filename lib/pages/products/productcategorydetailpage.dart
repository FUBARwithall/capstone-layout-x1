import 'package:flutter/material.dart';
import 'package:layout_x1/services/api_service.dart';
import 'package:layout_x1/pages/products/productdetailpage.dart';

class ProductCategoryDetailPage extends StatefulWidget {
  final int userId;
  final String jenisObat;
  final int? categoryId;

  const ProductCategoryDetailPage({
    super.key,
    required this.userId,
    required this.jenisObat,
    this.categoryId,
  });

  @override
  State<ProductCategoryDetailPage> createState() =>
      _ProductCategoryDetailPageState();
}

class _ProductCategoryDetailPageState extends State<ProductCategoryDetailPage> {
  List<dynamic> _products = [];
  bool _isLoading = true;

  String get baseUrl => ApiService.baseUrl.replaceAll('/api', '');

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    final result = await ApiService.getProductsByCategory(widget.jenisObat);
    if (result['success']) {
      setState(() {
        _products = result['data'] ?? [];
      });
    } else {
      setState(() => _products = []);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Gagal memuat produk')),
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.jenisObat}'),
        backgroundColor: const Color(0xFF0066CC),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
          ? const Center(child: Text('Tidak ada produk'))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.7,
              ),
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final p = _products[index];
                return GestureDetector(
                  onTap: () {
                    final productId = int.tryParse(p['id'].toString());
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
            color: Colors.black.withOpacity(0.05),
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  maxLines: 2,
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
