import 'package:flutter/material.dart';

class FaceDetectionpage extends StatefulWidget {
  const FaceDetectionpage({super.key});

  @override
  State<FaceDetectionpage> createState() => _FaceDetectionpageState();
}

class _FaceDetectionpageState extends State<FaceDetectionpage> {
  String? uploadedImagePath;
  bool showResult = false;

  // 🧠 Data dummy hasil deteksi WAJAH BERMINYAK
  final Map<String, dynamic> detectionResult = {
    'penyakit': 'Wajah Berminyak (Oily Skin)',
    'deskripsi':
        'Kulit wajah berminyak disebabkan oleh produksi sebum berlebih dari kelenjar minyak. Hal ini dapat membuat wajah tampak mengkilap, pori-pori tampak besar, dan rentan terhadap jerawat jika tidak dirawat dengan tepat.',
    'hal_yang_perlu_dilakukan': [
      'Gunakan facial wash khusus kulit berminyak dua kali sehari.',
      'Gunakan toner bebas alkohol untuk mengontrol minyak berlebih.',
      'Pakai pelembap ringan berbahan dasar air (oil-free).',
      'Gunakan kertas minyak saat wajah terasa sangat berminyak.',
      'Hindari menyentuh wajah terlalu sering agar tidak memperparah kondisi.',
    ],
    'obat': [
      'Face wash dengan kandungan salicylic acid untuk membersihkan pori-pori.',
      'Toner mengandung niacinamide untuk mengontrol minyak.',
      'Pelembap ringan berbahan dasar gel atau water-based.',
      'Masker clay 1–2 kali seminggu untuk mengurangi minyak berlebih.',
    ],
  };

  // 💊 Produk yang relevan dengan wajah berminyak
  final List<Map<String, String>> rekomendasiProduk = [
    {'nama': 'Wardah Acnederm Pure Foaming Cleanser', 'harga': 'Rp38.000'},
    {'nama': 'Emina Ms. Pimple Acne Solution Toner', 'harga': 'Rp32.000'},
    {'nama': 'Cosrx Oil-Free Ultra Moisturizing Lotion', 'harga': 'Rp280.000'},
    {'nama': 'Innisfree Super Volcanic Pore Clay Mask', 'harga': 'Rp190.000'},
    {'nama': 'Clean & Clear Oil Control Film', 'harga': 'Rp15.000'},
  ];

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
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 80.0, vertical: 40.0),
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
                    if (showResult)
                      Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: _buildDetectionAndProductCombined(),
                      ),
                  ],
                );
              },
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
              onPressed: () {
                setState(() {
                  // saat upload → tampilkan wajah berminyak
                  uploadedImagePath = 'assets/data/images/berminyak.jpeg';
                  showResult = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0066CC),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 28.0, vertical: 14.0),
              ),
              child: const Text('Upload'),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: uploadedImagePath != null
                  ? () => setState(() => showResult = true)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: uploadedImagePath != null
                    ? const Color(0xFF0066CC)
                    : Colors.grey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 28.0, vertical: 14.0),
              ),
              child: const Text('Deteksi'),
            ),
          ],
        ),
      ],
    );
  }

  // 🧾 Hasil deteksi & produk
  Widget _buildDetectionAndProductCombined() {
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
            children: const [
              Icon(Icons.medical_information,
                  color: Color(0xFF0066CC), size: 28),
              SizedBox(width: 10),
              Text(
                'Hasil Deteksi & Rekomendasi',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C2C2C),
                ),
              ),
            ],
          ),
          const Divider(height: 24, thickness: 1),

          // Jenis kulit
          _buildSection(
            icon: Icons.healing,
            title: 'Kondisi Kulit Terdeteksi',
            content: detectionResult['penyakit'],
            color: Colors.orange,
          ),
          const SizedBox(height: 12),
          Text(
            detectionResult['deskripsi'],
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF666666),
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 20),

          // Hal yang perlu dilakukan
          _buildListSection(
            icon: Icons.check_circle_outline,
            title: 'Hal yang Perlu Dilakukan',
            items: detectionResult['hal_yang_perlu_dilakukan'],
            color: Colors.blue,
          ),
          const SizedBox(height: 20),

          // Rekomendasi produk
          _buildListSection(
            icon: Icons.medication,
            title: 'Produk yang Direkomendasikan',
            items: detectionResult['obat'],
            color: Colors.green,
          ),
          const SizedBox(height: 16),

          // Produk berbentuk kartu
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rekomendasiProduk.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.85,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemBuilder: (context, index) {
              final produk = rekomendasiProduk[index];
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
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
                    Container(
                      height: 400,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12)),
                      ),
                      child: Center(
                        child: Icon(Icons.image,
                            size: 50, color: Colors.grey[400]),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              produk['nama']!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            SizedBox(height: 20),
                            Text(
                              produk['harga']!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          // Disclaimer
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: Colors.amber.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Gunakan produk sesuai kebutuhan dan konsultasikan dengan dermatolog jika timbul iritasi.',
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
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(title,
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C2C2C),
            ),
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
            color: color.withOpacity(0.1),
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
                              color: color, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item,
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
          child: Image.asset(
            uploadedImagePath ?? 'assets/data/images/deteksiwajah.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Icon(Icons.image_not_supported_outlined,
                    size: 48, color: Colors.grey),
              );
            },
          ),
        ),
      ),
    );
  }
}
