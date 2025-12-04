import 'package:flutter/material.dart';

class BodyDetectionpage extends StatefulWidget {
  const BodyDetectionpage({super.key});

  @override
  State<BodyDetectionpage> createState() => _BodyDetectionpageState();
}

class _BodyDetectionpageState extends State<BodyDetectionpage> {
  String? uploadedImagePath;
  bool showResult = false;

  // 🧠 dummy hasil deteksi
  final Map<String, dynamic> detectionResult = {
    'penyakit': 'Cacar (Chickenpox)',
    'deskripsi':
        'Cacar air (Chickenpox) adalah infeksi akibat virus Varicella-zoster yang menyebabkan ruam gatal dan bintik berisi cairan di seluruh tubuh. Umumnya menyerang anak-anak, tetapi juga dapat mengenai orang dewasa.',
    'hal_yang_perlu_dilakukan': [
      'Istirahat cukup dan perbanyak minum air putih.',
      'Hindari menggaruk bintik agar tidak meninggalkan bekas atau infeksi.',
      'Gunakan pakaian longgar dan berbahan lembut.',
      'Kompres dingin pada area gatal untuk mengurangi ketidaknyamanan.',
      'Segera konsultasi ke dokter jika demam tinggi atau luka infeksi.',
    ],
    'obat': [
      'Paracetamol untuk menurunkan demam.',
      'Antihistamin (Cetirizine / Loratadine) untuk mengurangi rasa gatal.',
      'Calamine Lotion untuk menenangkan kulit.',
      'Salep Acyclovir (sesuai resep dokter) untuk membantu penyembuhan.',
    ],
  };

  // 💊 dummy produk
  final List<Map<String, String>> rekomendasiProduk = [
    {'nama': 'Sanmol Paracetamol 500mg Tablet', 'harga': 'Rp25.000'},
    {'nama': 'Loratadine Sanbe 10mg Tablet', 'harga': 'Rp30.000'},
    {'nama': 'Caladine Lotion 60ml', 'harga': 'Rp22.000'},
    {'nama': 'Acyclovir Cream 5%', 'harga': 'Rp40.000'},
    {'nama': 'Cetirizine Kimia Farma 10mg Tablet', 'harga': 'Rp28.000'},
  ];

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
                  // layout responsif (horizontal untuk desktop, vertikal untuk HP)
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
                  if (showResult)
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: _buildDetectionAndProductCombined(constraints),
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
          'Deteksi kondisi kulitmu di sini.',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C2C2C),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Temukan hasil deteksi dan rekomendasi obat serta produk perawatan yang sesuai dengan kondisi kulitmu. '
          'Gunakan fitur upload gambar terlebih dahulu sebelum mendeteksi.',
          style: TextStyle(fontSize: 14, height: 1.6, color: Color(0xFF5C5C5C)),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  uploadedImagePath = 'assets/data/images/cacar.jpeg';
                  showResult = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0066CC),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28.0, vertical: 14.0),
              ),
              child: const Text('Upload'),
            ),
            ElevatedButton(
              onPressed:
                  uploadedImagePath != null ? () => setState(() => showResult = true) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    uploadedImagePath != null ? const Color(0xFF0066CC) : Colors.grey,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28.0, vertical: 14.0),
              ),
              child: const Text('Deteksi'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetectionAndProductCombined(BoxConstraints constraints) {
    final isWide = constraints.maxWidth > 800;
    final crossCount = isWide ? 3 : (constraints.maxWidth > 600 ? 2 : 1);

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
          // button pantau kulit
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
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
            ],
          ),
          const Divider(height: 24, thickness: 1),

          _buildSection(
            icon: Icons.healing,
            title: 'Penyakit Terdeteksi',
            content: detectionResult['penyakit'],
            color: Colors.red,
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
          _buildListSection(
            icon: Icons.checklist,
            title: 'Hal yang Perlu Dilakukan',
            items: detectionResult['hal_yang_perlu_dilakukan'],
            color: Colors.orange,
          ),
          const SizedBox(height: 20),
          _buildListSection(
            icon: Icons.medication,
            title: 'Obat & Produk yang Direkomendasikan',
            items: detectionResult['obat'],
            color: Colors.green,
          ),
          const SizedBox(height: 20),

          // card produk 
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rekomendasiProduk.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossCount,
              childAspectRatio: 0.8,
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
                    Flexible(
                      flex: 6,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius:
                              const BorderRadius.vertical(top: Radius.circular(12)),
                        ),
                        child: const Center(
                          child: Icon(Icons.image, size: 40, color: Colors.grey),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
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
                                  fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            Text(
                              produk['harga']!,
                              style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13),
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

          // disclaimer
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
                          decoration:
                              BoxDecoration(color: color, shape: BoxShape.circle),
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
          child: Image.asset(
            uploadedImagePath ?? 'assets/data/images/deteksitubuh.jpg',
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
