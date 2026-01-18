import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:layout_x1/pages/pantaupage.dart';
import 'package:layout_x1/pages/products/productdetailpage.dart';
import 'package:layout_x1/services/api_service.dart';
import 'package:layout_x1/services/user_preferences.dart';

class FaceDetectionpage extends StatefulWidget {
  const FaceDetectionpage({super.key});

  @override
  State<FaceDetectionpage> createState() => _FaceDetectionpageState();
}

class _FaceDetectionpageState extends State<FaceDetectionpage> {
  File? uploadedImage;
  bool showResult = false;
  bool isLoading = false;
  final ImagePicker _picker = ImagePicker();
  int? userId;

  // Detection result from API
  Map<String, dynamic>? detectionData;
  String? currentAnalysisId; // Store analysis ID from detection

  // Recommended products from database
  List<dynamic> recommendedProducts = [];

  // Notes functionality
  final TextEditingController _notesController = TextEditingController();
  bool isEditingNotes = false;
  bool isSavingNotes = false;

  String get imageBaseUrl => ApiService.baseUrl.replaceFirst('/api', '');

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadUserId() async {
    final id = await UserPreferences.getUserId();
    debugPrint('📱 Loaded userId: $id');
    setState(() {
      userId = id;
    });
  }

  // Function to pick image from gallery
  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          uploadedImage = File(image.path);
          showResult = false;
          detectionData = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  // Function to take photo with camera
  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (photo != null) {
        setState(() {
          uploadedImage = File(photo.path);
          showResult = false;
          detectionData = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error taking photo: $e')));
      }
    }
  }

  // Show dialog to choose between camera and gallery
  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pilih Sumber Gambar'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: Color(0xFF0066CC),
                ),
                title: const Text('Galeri'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF0066CC)),
                title: const Text('Kamera'),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Call detection API
  Future<void> _detectFace() async {
    if (uploadedImage == null) return;

    setState(() {
      isLoading = true;
      recommendedProducts = [];
      // Reset notes state for new detection
      currentAnalysisId = null;
      _notesController.clear();
      isEditingNotes = false;
    });

    try {
      debugPrint('🔍 Starting face detection...');
      debugPrint('📁 Image path: ${uploadedImage!.path}');
      debugPrint('📊 File exists: ${uploadedImage!.existsSync()}');
      debugPrint('📏 File size: ${uploadedImage!.lengthSync()} bytes');

      final result = await ApiService.detectFace(
        imagePath: uploadedImage!.path,
      );

      debugPrint('📡 API Response: $result');

      if (mounted) {
        if (result['success']) {
          final data = result['data'];
          debugPrint('✅ Detection success: $data');

          final skinProblem = data['skin_problem_analysis']?['result'] ?? '';

          // Fetch product recommendations based on detected skin problem
          List<dynamic> products = [];
          if (skinProblem.isNotEmpty) {
            debugPrint('🛒 Fetching products for: $skinProblem');
            final productResult = await ApiService.getProductsByCategory(
              skinProblem,
            );
            if (productResult['success']) {
              products = productResult['data'] ?? [];
            }
          }

          setState(() {
            detectionData = data;
            currentAnalysisId = data['analysis_id']?.toString();
            recommendedProducts = products;
            showResult = true;
            isLoading = false;
            _notesController.text = data['notes'] ?? '';
          });
        } else {
          debugPrint('❌ Detection failed: ${result['message']}');
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Deteksi gagal'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      debugPrint('💥 Exception in _detectFace: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0066CC),
        foregroundColor: Colors.white,
        title: const Text('Deteksi Wajah'),
      ),
      body: SafeArea(
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
                              Expanded(child: _buildLeftContent()),
                              const SizedBox(width: 60),
                              Expanded(child: _buildRightImage()),
                            ],
                          )
                        else
                          Column(
                            children: [
                              _buildLeftContent(),
                              const SizedBox(height: 32),
                              _buildRightImage(),
                            ],
                          ),
                        if (isLoading)
                          const Padding(
                            padding: EdgeInsets.only(top: 40),
                            child: Column(
                              children: [
                                CircularProgressIndicator(
                                  color: Color(0xFF0066CC),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Menganalisis wajah...',
                                  style: TextStyle(
                                    color: Color(0xFF5C5C5C),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (showResult && detectionData != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: _buildDetectionResult(constraints),
                          ),
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

  Widget _buildLeftContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Deteksi kondisi wajahmu di sini.',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C2C2C),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Temukan hasil deteksi dan rekomendasi perawatan wajah sesuai dengan jenis kulitmu. '
          'Gunakan fitur upload gambar terlebih dahulu sebelum mendeteksi.',
          style: TextStyle(fontSize: 14, height: 1.6, color: Color(0xFF5C5C5C)),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            ElevatedButton(
              onPressed: isLoading ? null : _showImageSourceDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0066CC),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28.0,
                  vertical: 14.0,
                ),
              ),
              child: const Text('Upload'),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: (uploadedImage != null && !isLoading)
                  ? _detectFace
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: (uploadedImage != null && !isLoading)
                    ? const Color(0xFF0066CC)
                    : Colors.grey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28.0,
                  vertical: 14.0,
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Deteksi'),
            ),
          ],
        ),
      ],
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
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Tombol Pantau Kulit - FULL WIDTH
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PantauKulitPage(fromHistory: true,),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
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
                fontSize: 15,
              ),
            ),
          ),
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
          predictions: skinType?['all_predictions'] ?? {},
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
          predictions: skinProblem?['all_predictions'] ?? {},
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

        const SizedBox(height: 20),

        // Notes Section
        _buildNotesSection(),
      ],
    ),
  );
}
  Widget _buildResultSection({
    required IconData icon,
    required String title,
    required String result,
    required String confidence,
    required Map<String, dynamic> predictions,
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
    final merek = product['merek'] ?? '';
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
                  builder: (context) => ProductDetailPage(
                    productId: productId,
                    userId: userId!,
                    // returnTo: 'faceDetection',
                  ),
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
            // Product Image
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
                  '$imageBaseUrl/web/uploads/$image',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.image, size: 35, color: Colors.grey),
                    );
                  },
                ),
              ),
            ),
            // Product Info
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

  List<String> _getTipsForSkin(String? skinType, String? skinProblem) {
    List<String> tips = [];

    // Tips based on skin type
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
        tips.add('Konsultasikan dengan dermatolog untuk perawatan yang tepat.');
    }

    // Tips based on skin problem
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

    return tips.isEmpty
        ? ['Jaga kebersihan wajah dan gunakan sunscreen setiap hari.']
        : tips;
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

  Future<void> _saveNotes() async {
    if (currentAnalysisId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tidak dapat menyimpan catatan: ID analisis tidak ditemukan',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isSavingNotes = true);

    final result = await ApiService.updateFaceNotes(
      currentAnalysisId!,
      _notesController.text.trim(),
    );

    if (!mounted) return;
    setState(() => isSavingNotes = false);

    if (result['success'] == true) {
      setState(() {
        isEditingNotes = false;
        if (detectionData != null) {
          detectionData!['notes'] = result['notes'];
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

    if (confirm != true || currentAnalysisId == null) return;

    setState(() => isSavingNotes = true);

    final result = await ApiService.updateFaceNotes(currentAnalysisId!, '');

    if (!mounted) return;
    setState(() => isSavingNotes = false);

    if (result['success'] == true) {
      setState(() {
        isEditingNotes = false;
        _notesController.clear();
        if (detectionData != null) {
          detectionData!['notes'] = null;
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
      _notesController.text = detectionData?['notes'] ?? '';
    });
  }

  // Ganti fungsi _buildNotesSection() dengan code ini:

  Widget _buildNotesSection() {
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
          Row(
            children: [
              const Icon(Icons.note_alt, color: Color(0xFF0066CC), size: 24),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Catatan Pribadi',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C2C2C),
                  ),
                ),
              ),
              // Menu edit/hapus hanya muncul kalau ada catatan
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
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 1),
          const SizedBox(height: 16),
          if (isEditingNotes)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _notesController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Tambahkan catatan pribadi Anda di sini...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF0066CC)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xFF0066CC),
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
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
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: isSavingNotes ? null : _saveNotes,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0066CC),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isSavingNotes
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Simpan'),
                    ),
                  ],
                ),
              ],
            )
          else
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                // Langsung masuk edit tanpa snack bar
                setState(() => isEditingNotes = true);
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
                    fontSize: 14,
                    height: 1.6,
                    color: _notesController.text.isEmpty
                        ? Colors.grey
                        : const Color(0xFF2C2C2C),
                    fontStyle: _notesController.text.isEmpty
                        ? FontStyle.italic
                        : FontStyle.normal,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRightImage() {
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
          child: uploadedImage != null
              ? Image.file(
                  uploadedImage!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        size: 48,
                        color: Colors.grey,
                      ),
                    );
                  },
                )
              : Image.asset(
                  'assets/data/images/deteksiwajah.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        size: 48,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
