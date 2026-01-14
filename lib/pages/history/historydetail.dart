import 'package:flutter/material.dart';
import 'package:layout_x1/services/api_service.dart';
import 'package:layout_x1/pages/products/productdetailpage.dart';

class HistoryDetailPage extends StatefulWidget {
  final String analysisId;
  const HistoryDetailPage({super.key, required this.analysisId});

  @override
  State<HistoryDetailPage> createState() => _HistoryDetailPageState();
}

class _HistoryDetailPageState extends State<HistoryDetailPage> {
  bool isLoading = true;
  Map<String, dynamic>? detectionData;
  List<dynamic> recommendedProducts = [];

  String get imageBaseUrl => ApiService.baseUrl.replaceFirst('/api', '');

  @override
  void initState() {
    super.initState();
    _loadHistoryDetail();
    _loadHistoryDetail(); 
  }

  Future<void> _loadHistoryDetail() async {
  final result = await ApiService.getHistoryDetail(widget.analysisId);

    if (!mounted) return;

    if (result['success'] == true) {
      final data = result['data']; // ✅ FIX UTAMA

      final skinProblem = data?['skin_problem_analysis']?['result'] ?? '';

      List<dynamic> products = [];
      if (skinProblem.isNotEmpty) {
        final productResult = await ApiService.getProductsByCategory(
          skinProblem,
        );
        if (productResult['success'] == true) {
          products = productResult['data'] ?? [];
        }
      }

      setState(() {
        detectionData = data;
        recommendedProducts = products;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Gagal memuat detail'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Riwayat Deteksi'),
        backgroundColor: const Color(0xFF0066CC),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : detectionData == null
          ? const Center(child: Text('Data tidak tersedia'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildDetectionResult(),
            ),
    );
  }

  Widget _buildDetectionResult() {
    final skinType = detectionData!['skin_type_analysis'];
    final skinProblem = detectionData!['skin_problem_analysis'];
    final timestamp = detectionData!['timestamp'] ?? '';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF0066CC), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hasil Deteksi Wajah',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 6),
          Text(
            'Dianalisis pada: $timestamp',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),

          const Divider(height: 24),

          _resultSection(
            title: 'Jenis Kulit',
            result: skinType['result'],
            confidence: skinType['confidence'],
            color: Colors.blue,
          ),

          const SizedBox(height: 20),

          _resultSection(
            title: 'Masalah Kulit',
            result: skinProblem['result'],
            confidence: skinProblem['confidence'],
            color: Colors.orange,
          ),

          if (recommendedProducts.isNotEmpty) ...[
            const SizedBox(height: 30),
            const Text(
              'Rekomendasi Produk',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recommendedProducts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                final p = recommendedProducts[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ProductDetailPage(productId: p['id'], userId: 0),
                      ),
                    );
                  },
                  child: _productCard(p),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _resultSection({
    required String title,
    required String result,
    required String confidence,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            result,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              confidence,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _productCard(Map<String, dynamic> p) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Expanded(
            child: Image.network(
              '$imageBaseUrl/web/uploads/${p['image']}',
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              p['nama'],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
