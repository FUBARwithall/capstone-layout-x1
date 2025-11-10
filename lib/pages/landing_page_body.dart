import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:layout_x1/widgets/common_dialogs.dart';
import 'package:layout_x1/pages/articlepage.dart';
import 'user_preferences.dart'; // Import user preferences

class LandingPageBody extends StatefulWidget {
  @override
  State<LandingPageBody> createState() => _LandingPageBodyState();
}

class _LandingPageBodyState extends State<LandingPageBody> {
  List<dynamic> _articles = [];
  String _userName = 'Beranda'; // Default
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadArticles();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    try {
      final userData = await UserPreferences.getUser();

      if (userData != null) {
        setState(() {
          _userName = userData['name'];
          _isLoadingUser = false;
        });
      } else {
        setState(() {
          _userName = 'Beranda';
          _isLoadingUser = false;
        });
      }
    } catch (e) {
      setState(() {
        _userName = 'Beranda';
        _isLoadingUser = false;
      });
    }
  }

  Future<void> _loadArticles() async {
    final jsonString = await rootBundle.loadString('assets/data/articles.json');
    final data = json.decode(jsonString);
    setState(() {
      _articles = data;
    });
  }

  void _navigateToArticles() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ArticlesPageBody()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: _isLoadingUser
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                children: [
                  const Icon(Icons.person, color: Colors.amber, size: 24),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Halo, $_userName',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
        automaticallyImplyLeading: false,
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==== DETEKSI KULIT ====
              const Text(
                "Deteksi Kulit",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // === Kartu Deteksi Kulit Wajah ===
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFF0066CC), width: 2),
                ),
                child: InkWell(
                  onTap: () =>
                      showComingSoonDialog(context, 'Deteksi Kulit Wajah'),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0066CC).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.face,
                            color: Color(0xFF0066CC),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            'Deteksi Kulit Wajah\nAnalisis kondisi kulit wajah dengan AI.',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // === Kartu Deteksi Kulit Tubuh ===
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFF0066CC), width: 2),
                ),
                child: InkWell(
                  onTap: () =>
                      showComingSoonDialog(context, 'Deteksi Kulit Tubuh'),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0066CC).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.accessibility_new,
                            color: Color(0xFF0066CC),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            'Deteksi Kulit Tubuh\nAnalisis kondisi kulit pada tubuh menggunakan AI.',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ==== ARTIKEL TERKINI ====
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Artikel Terkini',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: _navigateToArticles,
                    child: const Text(
                      'Lihat Semua',
                      style: TextStyle(color: Color(0xFF0066CC)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _articles.length > 3 ? 3 : _articles.length,
                itemBuilder: (context, index) {
                  final article = _articles[index];
                  return Card(
                    child: ListTile(
                      leading: Text(
                        article['image'] ?? '📄',
                        style: const TextStyle(fontSize: 28),
                      ),
                      title: Text(article['title'] ?? ''),
                      subtitle: Text(
                        article['description'] ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: _navigateToArticles,
                    ),
                  );
                },
              ),
              SizedBox(height: 20),


              // ==== REKOMENDASI PRODUK ====
              Text(
                'Rekomendasi Produk',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),

              // Daftar produk dalam bentuk scroll horizontal
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildProductCard(
                      'assets/images/chatbot.png',
                      'Halodoc+',
                      'Rp 49.000/bulan',
                    ),
                    _buildProductCard(
                      'assets/images/paket_hemat.png',
                      'Paket Hemat',
                      'Diskon s.d. 40%',
                    ),
                    _buildProductCard(
                      'assets/images/promo_november.png',
                      'Promo November',
                      'Mulai Rp 15.000',
                    ),
                    _buildProductCard(
                      'assets/images/susu_keluarga.png',
                      'Susu Keluarga',
                      'Rp 120.000',
                    ),
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

Widget _buildProductCard(String imagePath, String name, String price) {
  return Container(
    width: 140,
    margin: const EdgeInsets.only(right: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            imagePath,
            height: 100,
            width: 140,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(price, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    ),
  );
}
