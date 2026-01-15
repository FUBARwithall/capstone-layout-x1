import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:layout_x1/services/api_service.dart';

class BodyDetectionpage extends StatefulWidget {
  const BodyDetectionpage({super.key});

  @override
  State<BodyDetectionpage> createState() => _BodyDetectionpageState();
}

class _BodyDetectionpageState extends State<BodyDetectionpage> {
  File? uploadedImage;
  bool showResult = false;
  bool isLoading = false;
  final ImagePicker _picker = ImagePicker();

  // Detection result from API
  Map<String, dynamic>? detectionData;

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
  Future<void> _detectBody() async {
    if (uploadedImage == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      debugPrint('🔍 Starting body detection...');
      debugPrint('📁 Image path: ${uploadedImage!.path}');
      debugPrint('📊 File exists: ${uploadedImage!.existsSync()}');
      debugPrint('📏 File size: ${uploadedImage!.lengthSync()} bytes');

      final result = await ApiService.detectBody(
        imagePath: uploadedImage!.path,
      );

      debugPrint('📡 API Response: $result');

      if (mounted) {
        if (result['success']) {
          final data = result['data'];
          debugPrint('✅ Detection success: $data');

          setState(() {
            detectionData = data;
            showResult = true;
            isLoading = false;
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
      debugPrint('💥 Exception in _detectBody: $e');
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
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0066CC),
        foregroundColor: Colors.white,
        title: const Text('Deteksi Tubuh'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth < 600 ? 20 : screenWidth * 0.1,
            vertical: 30,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              bool isWide = constraints.maxWidth > 800;
              return Column(
                children: [
                  isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildLeftContent()),
                            const SizedBox(width: 40),
                            Expanded(child: _buildRightImage(constraints)),
                          ],
                        )
                      : Column(
                          children: [
                            _buildLeftContent(),
                            const SizedBox(height: 32),
                            _buildRightImage(constraints),
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
                            'Menganalisis kulit tubuh...',
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
    );
  }

  Widget _buildLeftContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Deteksi kondisi kulit tubuhmu di sini.',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C2C2C),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Temukan hasil deteksi penyakit kulit dan rekomendasi obat serta produk perawatan yang sesuai dengan kondisi kulitmu. '
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
                  ? _detectBody
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
    final diseaseAnalysis = detectionData!['disease_analysis'];
    final diseaseInfo = diseaseAnalysis['disease_info'];
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.medical_information,
                      color: Color(0xFF0066CC),
                      size: 28,
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        'Hasil Deteksi & Rekomendasi',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C2C2C),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
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

          // Disease Detected Section
          _buildSection(
            icon: Icons.healing,
            title: 'Penyakit Terdeteksi',
            content: diseaseInfo['nama'] ?? '-',
            confidence: diseaseAnalysis['confidence'] ?? '-',
            color: Colors.red,
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            diseaseInfo['deskripsi'] ?? '',
            textAlign: TextAlign.justify,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF666666),
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),

          // Symptoms Section
          if (diseaseInfo['gejala'] != null &&
              (diseaseInfo['gejala'] as List).isNotEmpty)
            _buildListSection(
              icon: Icons.checklist,
              title: 'Gejala',
              items: List<String>.from(diseaseInfo['gejala']),
              color: Colors.orange,
            ),
          const SizedBox(height: 20),

          // Treatment Section
          if (diseaseInfo['obat'] != null &&
              (diseaseInfo['obat'] as List).isNotEmpty)
            _buildListSection(
              icon: Icons.medication,
              title: 'Pengobatan & Perawatan',
              items: List<String>.from(diseaseInfo['obat']),
              color: Colors.green,
            ),
          const SizedBox(height: 20),

          // All Predictions (Confidence Scores)
          _buildPredictionsSection(diseaseAnalysis['all_predictions']),
          const SizedBox(height: 20),

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
                    'Konsultasikan dengan dokter untuk diagnosis dan pengobatan yang tepat.',
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

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  content,
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
        ),
      ],
    );
  }

  Widget _buildListSection({
    required IconData icon,
    required String title,
    required List<String> items,
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
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item,
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

  Widget _buildPredictionsSection(Map<String, dynamic>? predictions) {
    if (predictions == null || predictions.isEmpty) {
      return const SizedBox.shrink();
    }

    // Sort predictions by confidence (descending)
    final sortedPredictions = predictions.entries.toList()
      ..sort((a, b) => (b.value as num).compareTo(a.value as num));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.analytics, color: Colors.purple, size: 20),
            SizedBox(width: 8),
            Text(
              'Skor Kepercayaan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.purple.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: sortedPredictions.map((entry) {
              final percentage = (entry.value as num).toDouble();
              final isTop = entry == sortedPredictions.first;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 80,
                      child: Text(
                        _capitalizeFirst(entry.key),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isTop ? FontWeight.bold : FontWeight.normal,
                          color: isTop ? Colors.purple : const Color(0xFF666666),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percentage / 100,
                          backgroundColor: Colors.grey.shade300,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isTop ? Colors.purple : Colors.purple.withValues(alpha: 0.5),
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 50,
                      child: Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isTop ? FontWeight.bold : FontWeight.normal,
                          color: isTop ? Colors.purple : const Color(0xFF666666),
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  String _formatTimestamp(String timestamp) {
    try {
      final dt = DateTime.parse(timestamp);
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return timestamp;
    }
  }

  Widget _buildRightImage(BoxConstraints constraints) {
    final isWide = constraints.maxWidth > 800;
    final imageWidth = isWide ? 400.0 : double.infinity;
    final imageHeight = isWide ? 300.0 : 250.0;

    return Center(
      child: Container(
        width: imageWidth,
        height: imageHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
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
                  'assets/data/images/deteksitubuh.jpg',
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
