import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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

  @override
  void initState() {
    super.initState();
    userId = widget.userId;
    fetchProductDetail();
    fetchFavoriteStatus();
  }

  Future<void> fetchProductDetail() async {
    final url = Uri.parse(
      'http://localhost:5000/api/products/${widget.productId}',
    );

    try {
      final response = await http.get(url);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          product = data['data'];
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Fetch product error: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchFavoriteStatus() async {
    final url = Uri.parse(
      'http://localhost:5000/api/products/${widget.productId}/favorite/status?user_id=$userId',
    );

    try {
      final response = await http.get(url);
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
      'http://localhost:5000/api/products/${widget.productId}/favorite',
    );

    try {
      if (isLoved) {
        await http.delete(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'user_id': userId}),
        );

        setState(() {
          isLoved = false;
          _favoriteChanged = true;
        });
      } else {
        await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
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

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, {'changed': _favoriteChanged});
        return false;
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
                  'http://localhost:5000/uploads/${product!['image']}',
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
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      product!['deskripsi'],
                      textAlign: TextAlign.justify,
                    ),

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
                    Text('Nomor registrasi: ${product!['nomor_registrasi']}')
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
