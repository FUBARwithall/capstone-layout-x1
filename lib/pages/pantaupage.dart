import 'package:flutter/material.dart';

void main() {
  runApp(const PantauKulitPage());
}

class PantauKulitPage extends StatefulWidget {
  const PantauKulitPage({super.key});

  @override
  State<PantauKulitPage> createState() => _PantauKulitPageState();
}

class _PantauKulitPageState extends State<PantauKulitPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pemantau Kesehatan Kulit',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
      ),
      home: const SkinHealthTracker(),
    );
  }
}

class SkinHealthTracker extends StatefulWidget {
  const SkinHealthTracker({super.key});

  @override
  State<SkinHealthTracker> createState() => _SkinHealthTrackerState();
}

class _SkinHealthTrackerState extends State<SkinHealthTracker>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  double _skinCondition = 5;
  final List<String> _foods = ['Nasi Goreng', 'Ayam Goreng'];
  final List<String> _drinks = ['Air Putih', 'Kopi'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pemantau Kesehatan Kulit'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.edit), text: 'Input'),
            Tab(icon: Icon(Icons.analytics), text: 'Analisis'),
            Tab(icon: Icon(Icons.photo_library), text: 'Galeri'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInputPage(),
          _buildAnalysisPage(),
          _buildGalleryPage(),
        ],
      ),
    );
  }

  // Halaman Input Data
  Widget _buildInputPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pilih Tanggal
          Card(
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.teal),
              title: const Text('Tanggal'),
              subtitle: const Text('11 November 2025'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 24),

          // Upload Foto Wajah
          const Text(
            'Foto Wajah',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[400]!, width: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, size: 56, color: Colors.grey[600]),
                  const SizedBox(height: 12),
                  Text(
                    'Tambah Foto',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Kondisi Kulit Slider
          const Text(
            'Kondisi Kulit',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Buruk'),
                      Text(
                        _skinCondition.toInt().toString(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      const Text('Baik'),
                    ],
                  ),
                  Slider(
                    value: _skinCondition,
                    min: 1,
                    max: 10,
                    divisions: 9,
                    label: _skinCondition.toInt().toString(),
                    activeColor: Colors.teal,
                    onChanged: (value) {
                      setState(() {
                        _skinCondition = value;
                      });
                    },
                  ),
                  Text(
                    _skinCondition <= 3
                        ? '😔 Buruk'
                        : _skinCondition <= 7
                            ? '😐 Sedang'
                            : '😊 Baik',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _skinCondition <= 3
                          ? Colors.red
                          : _skinCondition <= 7
                              ? Colors.orange
                              : Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Input Makanan
          const Text(
            'Makanan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Contoh: Nasi goreng',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.restaurant),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: const BoxDecoration(
                  color: Colors.teal,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _foods.map((food) {
              return Chip(
                label: Text(food),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () {},
                backgroundColor: Colors.teal[50],
                labelStyle: const TextStyle(color: Colors.teal),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Input Minuman
          const Text(
            'Minuman',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Contoh: Air putih',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.local_drink),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: const BoxDecoration(
                  color: Colors.teal,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _drinks.map((drink) {
              return Chip(
                label: Text(drink),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () {},
                backgroundColor: Colors.blue[50],
                labelStyle: const TextStyle(color: Colors.blue),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Input Jam Tidur
          const Text(
            'Jam Tidur',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          const TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Contoh: 7.5',
              suffixText: 'jam',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.bedtime),
            ),
          ),
          const SizedBox(height: 24),

          // Catatan Tambahan
          const Text(
            'Catatan Tambahan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          const TextField(
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Catatan kondisi kulit atau gejala lainnya...',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 32),

          // Tombol Simpan
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save),
                  SizedBox(width: 8),
                  Text(
                    'Simpan Data',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // Halaman Analisis & Grafik
  Widget _buildAnalysisPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Analisis Kesehatan Kulit',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Lihat hubungan antara gaya hidup dan kondisi kulit',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),

          // Card Grafik Kondisi Kulit
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.trending_up, color: Colors.teal),
                      SizedBox(width: 8),
                      Text(
                        'Tren Kondisi Kulit',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'Grafik Line Chart\n(Kondisi Kulit 7 Hari Terakhir)',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Card Grafik Jam Tidur
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.bedtime, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Tren Jam Tidur',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'Grafik Bar Chart\n(Jam Tidur 7 Hari Terakhir)',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Analisis Hari Ini
          const Text(
            'Analisis Hari Ini',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          
          // Card Analisis Makanan
          Card(
            color: Colors.orange[50],
            child: const ListTile(
              leading: Icon(Icons.warning_amber, color: Colors.orange, size: 32),
              title: Text(
                'Makanan Berminyak',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Gorengan dapat meningkatkan produksi sebum dan risiko jerawat',
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Card Analisis Minuman
          Card(
            color: Colors.green[50],
            child: const ListTile(
              leading: Icon(Icons.check_circle, color: Colors.green, size: 32),
              title: Text(
                'Hidrasi Baik',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Air putih membantu hidrasi kulit dan detoksifikasi',
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Card Analisis Tidur
          Card(
            color: Colors.green[50],
            child: const ListTile(
              leading: Icon(Icons.check_circle, color: Colors.green, size: 32),
              title: Text(
                'Tidur Cukup',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Durasi tidur 7 jam ideal untuk regenerasi kulit',
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Riwayat 7 Hari
          const Text(
            'Riwayat 7 Hari Terakhir',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          // List Riwayat
          _buildHistoryCard('10 November 2025', 8, 7.5),
          _buildHistoryCard('9 November 2025', 6, 6.0),
          _buildHistoryCard('8 November 2025', 7, 8.0),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(String date, int condition, double sleep) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: condition <= 3
              ? Colors.red
              : condition <= 7
                  ? Colors.orange
                  : Colors.green,
          child: Text(
            condition.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          date,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Tidur: $sleep jam'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Makanan:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text('• Nasi goreng'),
                const Text('• Ayam goreng'),
                const SizedBox(height: 8),
                const Text(
                  'Minuman:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text('• Air putih'),
                const Text('• Kopi'),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  '⚠️ Makanan berminyak dapat meningkatkan jerawat',
                  style: TextStyle(color: Colors.orange),
                ),
                const Text(
                  '✅ Hidrasi cukup membantu kesehatan kulit',
                  style: TextStyle(color: Colors.green),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Halaman Galeri Foto
  Widget _buildGalleryPage() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Card(
          clipBehavior: Clip.antiAlias,
          elevation: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  color: Colors.grey[300],
                  child: Icon(
                    Icons.face,
                    size: 64,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${10 - index} Nov 2025',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.circle, size: 8, color: Colors.green),
                        const SizedBox(width: 4),
                        Text(
                          'Kondisi: ${8 - index}/10',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}