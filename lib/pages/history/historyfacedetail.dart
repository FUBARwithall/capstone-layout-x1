import 'package:flutter/material.dart';
import 'package:layout_x1/pages/pantaupage.dart';
import 'package:layout_x1/services/api_service.dart';
import 'package:layout_x1/pages/products/productdetailpage.dart';
import 'package:layout_x1/services/user_preferences.dart';

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
  int? userId;

  // Notes functionality
  final TextEditingController _notesController = TextEditingController();
  bool isEditingNotes = false;
  bool isSavingNotes = false;

  String get rootUrl => ApiService.baseUrl.replaceFirst('/api', '');

  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final id = await UserPreferences.getUserId();
    setState(() {
      userId = id;
    });
    _loadHistoryDetail();
  }

  Future<void> _loadHistoryDetail() async {
    final result = await ApiService.getHistoryDetail(widget.analysisId);

    if (!mounted) return;

    if (result['success'] == true) {
      final data = result['data'];

      // Ambil masalah kulit untuk mencari produk yang relevan
      final skinProblem = data?['skin_problem_analysis']?['result'] ?? '';

      List<dynamic> products = [];
      if (skinProblem != null && skinProblem.isNotEmpty && skinProblem != '-') {
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
        // Load notes from server
        _notesController.text = data?['note'] ?? '';
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

  Future<void> _saveNotes() async {
    setState(() => isSavingNotes = true);

    final result = await ApiService.updateFaceNotes(
      widget.analysisId,
      _notesController.text.trim(),
    );

    if (!mounted) return;
    setState(() => isSavingNotes = false);

    if (result['success'] == true) {
      setState(() {
        isEditingNotes = false;
        if (detectionData != null) {
          detectionData!['note'] = result['note'];
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Catatan berhasil disimpan'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Gagal menyimpan catatan'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteNote() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Catatan'),
        content: const Text('Apakah Anda yakin ingin menghapus catatan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => isSavingNotes = true);

    final result = await ApiService.updateFaceNotes(
      widget.analysisId,
      '', // Empty string to delete
    );

    if (!mounted) return;
    setState(() => isSavingNotes = false);

    if (result['success'] == true) {
      setState(() {
        isEditingNotes = false;
        _notesController.clear();
        if (detectionData != null) {
          detectionData!['note'] = null;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Catatan berhasil dihapus'),
          backgroundColor: Colors.blue,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Gagal menghapus catatan'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _cancelEditNotes() {
    setState(() {
      isEditingNotes = false;
      _notesController.text = detectionData?['note'] ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0066CC),
        foregroundColor: Colors.white,
        title: const Text('Detail Riwayat Analisis'),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF0066CC)),
            )
          : detectionData == null
          ? const Center(child: Text('Data tidak tersedia'))
          : SafeArea(
              child: SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40.0,
                        vertical: 40.0,
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          bool isWide = constraints.maxWidth > 800;
                          return Column(
                            children: [
                              if (isWide)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: _buildInfoText()),
                                    const SizedBox(width: 60),
                                    Expanded(child: _buildAnalysisImage()),
                                  ],
                                )
                              else
                                Column(
                                  children: [
                                    _buildInfoText(),
                                    const SizedBox(height: 32),
                                    _buildAnalysisImage(),
                                  ],
                                ),
                              const SizedBox(height: 40),
                              _buildDetectionResult(constraints),

                              // Notes Section
                              const SizedBox(height: 24),
                              _buildNotesSection(),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildInfoText() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detail riwayat analisis wajah Anda.',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C2C2C),
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Halaman ini menampilkan hasil deteksi jenis kulit dan masalah kulit yang telah Anda lakukan sebelumnya, beserta tips dan rekomendasi produk yang diberikan.',
          style: TextStyle(fontSize: 14, height: 1.6, color: Color(0xFF5C5C5C)),
        ),
      ],
    );
  }

  Widget _buildAnalysisImage() {
    final imageUrl = detectionData!['image_url'];
    final fullUrl = imageUrl != null ? '$rootUrl$imageUrl' : null;

    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: 400,
        height: 300,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black, width: 3),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: fullUrl != null
              ? Image.network(
                  fullUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _imagePlaceholder(),
                )
              : _imagePlaceholder(),
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return const Center(
      child: Icon(
        Icons.image_not_supported_outlined,
        size: 48,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildDetectionResult(BoxConstraints constraints) {
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
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(
                Icons.medical_information,
                color: Color(0xFF0066CC),
                size: 28,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Hasil Deteksi Wajah',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C2C2C),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PantauKulitPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    icon: const Icon(
                      Icons.monitor_heart,
                      size: 20,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Pantau Kulit',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          if (timestamp.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Dianalisis pada: ${_formatTimestamp(timestamp)}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
              ),
            ),

          const Divider(height: 24, thickness: 1),

          // Skin Type Section
          _buildResultSection(
            icon: Icons.face,
            title: 'Jenis Kulit',
            result: skinType?['result']?.toString() ?? '-',
            confidence: skinType?['confidence'] is num
                ? '${(skinType!['confidence'] as num).toStringAsFixed(1)}%'
                : skinType?['confidence']?.toString() ?? '-',
            color: Colors.blue,
          ),

          const SizedBox(height: 20),

          // Skin Problem Section
          _buildResultSection(
            icon: Icons.healing,
            title: 'Masalah Kulit',
            result: skinProblem?['result']?.toString() ?? '-',
            confidence: skinProblem?['confidence'] is num
                ? '${(skinProblem!['confidence'] as num).toStringAsFixed(1)}%'
                : skinProblem?['confidence']?.toString() ?? '-',
            color: Colors.orange,
          ),

          const SizedBox(height: 20),

          // Tips Section
          _buildTipsSection(
            skinType?['result']?.toString(),
            skinProblem?['result']?.toString(),
          ),

          const SizedBox(height: 20),

          // Product Recommendations Section
          if (recommendedProducts.isNotEmpty)
            _buildProductRecommendations(constraints),

          if (recommendedProducts.isNotEmpty) const SizedBox(height: 20),

          // Warning
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.amber.shade700,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Hasil deteksi ini adalah perkiraan berdasarkan AI. Konsultasikan dengan dermatolog untuk diagnosis yang akurat.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.amber.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultSection({
    required IconData icon,
    required String title,
    required String result,
    required String confidence,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      result,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: color.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      confidence,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTipsSection(String? skinType, String? skinProblem) {
    final tips = _getTipsForSkin(skinType, skinProblem);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.lightbulb_outline, color: Colors.green, size: 20),
            SizedBox(width: 8),
            Text(
              'Tips Perawatan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: tips
                .map(
                  (tip) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            tip,
                            textAlign: TextAlign.justify,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF2C2C2C),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  List<String> _getTipsForSkin(String? skinType, String? skinProblem) {
    List<String> tips = [];
    switch (skinType?.toLowerCase()) {
      case 'berminyak':
        tips.addAll([
          'Gunakan facial wash khusus kulit berminyak dua kali sehari.',
          'Gunakan toner bebas alkohol untuk mengontrol minyak berlebih.',
          'Pakai pelembap ringan berbahan dasar air (oil-free).',
        ]);
        break;
      case 'kering':
        tips.addAll([
          'Gunakan pembersih wajah yang lembut dan melembapkan.',
          'Aplikasikan pelembap kaya akan hyaluronic acid.',
          'Hindari air panas saat mencuci wajah.',
        ]);
        break;
      case 'normal':
        tips.addAll([
          'Pertahankan rutinitas skincare sederhana.',
          'Gunakan sunscreen setiap hari.',
          'Jaga hidrasi dengan minum air yang cukup.',
        ]);
        break;
      default:
        tips.add('Jaga kebersihan wajah dan gunakan sunscreen setiap hari.');
    }
    switch (skinProblem?.toLowerCase()) {
      case 'jerawat':
        tips.addAll([
          'Hindari menyentuh wajah terlalu sering.',
          'Gunakan produk dengan kandungan salicylic acid atau benzoyl peroxide.',
          'Ganti sarung bantal secara teratur.',
        ]);
        break;
      case 'kusam':
        tips.addAll([
          'Lakukan eksfoliasi 1-2 kali seminggu.',
          'Gunakan serum Vitamin C untuk mencerahkan kulit.',
          'Pastikan tidur yang cukup setiap malam.',
        ]);
        break;
      case 'penuaan':
        tips.addAll([
          'Gunakan produk dengan retinol atau peptide.',
          'Aplikasikan eye cream untuk area mata.',
          'Lindungi kulit dari paparan sinar matahari.',
        ]);
        break;
    }
    return tips;
  }

  Widget _buildProductRecommendations(BoxConstraints constraints) {
    int crossAxisCount = 3;
    double childAspectRatio = 0.85;
    double spacing = 16.0;

    if (constraints.maxWidth < 900) {
      crossAxisCount = 2;
      childAspectRatio = 0.75;
      spacing = 12.0;
    }
    if (constraints.maxWidth < 600) {
      crossAxisCount = 1;
      childAspectRatio = 0.7;
      spacing = 10.0;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.medication, color: Colors.purple, size: 20),
            SizedBox(width: 8),
            Text(
              'Rekomendasi Produk',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recommendedProducts.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
          ),
          itemBuilder: (context, index) {
            final product = recommendedProducts[index];
            return _buildProductCard(product);
          },
        ),
      ],
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final productId = product['id'];
    final nama = product['nama'] ?? 'Produk';
    final merek = product['merek'] ?? product['brand'] ?? '';
    final harga = product['harga'];
    final image = product['image'];

    String formattedHarga = '-';
    if (harga != null) {
      final numHarga = harga is num
          ? harga
          : double.tryParse(harga.toString()) ?? 0;
      formattedHarga =
          'Rp${numHarga.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
    }

    return GestureDetector(
      onTap: userId != null
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ProductDetailPage(productId: productId, userId: userId!),
                ),
              );
            }
          : null,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
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
            Flexible(
              flex: 5,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: Image.network(
                  '$rootUrl/web/uploads/$image',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.image, size: 35, color: Colors.grey),
                    );
                  },
                ),
              ),
            ),
            Flexible(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (merek.isNotEmpty)
                      Text(
                        merek,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                          height: 1.1,
                        ),
                      ),
                    if (merek.isNotEmpty) const SizedBox(height: 1),
                    Text(
                      nama,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formattedHarga,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFF0066CC), width: 2),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.note_alt, color: Color(0xFF0066CC), size: 24),
                SizedBox(width: 10),
                Text(
                  'Catatan Pribadi',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C2C2C),
                  ),
                ),
              ],
            ),
            if (_notesController.text.isNotEmpty)
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    setState(() => isEditingNotes = true);
                  } else if (value == 'delete') {
                    _deleteNote();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Hapus')),
                ],
              ),
          ],
        ),
        const Divider(height: 24),
        if (isEditingNotes)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _notesController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Tambahkan catatan...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: isSavingNotes ? null : _cancelEditNotes,
                    child: const Text('Batal'),
                  ),
                  ElevatedButton(
                    onPressed: isSavingNotes ? null : _saveNotes,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0066CC),
                    ),
                    child: isSavingNotes
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Simpan',
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ],
              ),
            ],
          )
        else
          GestureDetector(
            onTap: () {
              setState(() {
                isEditingNotes = true;
                _notesController.text = detectionData?['note'] ?? '';
              });
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _notesController.text.isEmpty
                    ? Colors.grey[100]
                    : const Color(0xFF0066CC).withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _notesController.text.isEmpty
                      ? Colors.grey[300]!
                      : const Color(0xFF0066CC).withOpacity(0.2),
                ),
              ),
              child: Text(
                _notesController.text.isEmpty
                    ? 'Belum ada catatan.\nTap di sini untuk menambahkan catatan pribadi.'
                    : _notesController.text,
                style: TextStyle(
                  color: _notesController.text.isEmpty
                      ? Colors.grey
                      : const Color(0xFF2C2C2C),
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ),
          ),
      ],
    ),
  );
}


  String _formatTimestamp(String timestamp) {
    try {
      // Parse timestamp (will include timezone info if provided)
      final dt = DateTime.parse(timestamp);

      // Convert to local time (WIB)
      final localDt = dt.toLocal();

      return '${localDt.day}/${localDt.month}/${localDt.year} ${localDt.hour.toString().padLeft(2, '0')}:${localDt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return timestamp;
    }
  }
}
