import 'package:flutter/material.dart';

class TentangKamiPage extends StatefulWidget {
  const TentangKamiPage({super.key});

  @override
  State<TentangKamiPage> createState() => _TentangKamiPageState();
}

class _TentangKamiPageState extends State<TentangKamiPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tentang Kami'),
        backgroundColor: const Color(0xFF0066CC),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Peduli Kulit adalah aplikasi inovatif yang dirancang untuk membantu masyarakat Indonesia memantau dan merawat kesehatan kulit secara mandiri. Dengan meningkatnya penggunaan kosmetik ilegal dan rendahnya kesadaran masyarakat akan keamanan produk perawatan kulit, kami hadir untuk memberikan solusi berbasis teknologi yang mudah diakses.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            SizedBox(height: 16),
            Text(
              'Mengapa Kulit Perlu Diperhatikan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Penuaan kulit melibatkan faktor intrinsik dan ekstrinsik yang dapat memicu terjadinya penuaan dini. Faktor-faktor tersebut meliputi:\n'
              '• Paparan sinar matahari berlebih\n'
              '• Konsumsi makanan dan minuman tidak sehat\n'
              '• Kurang mengonsumsi air putih\n'
              '• Faktor gaya hidup lainnya seperti kurang tidur atau stres\n\n'
              'Beberapa cara untuk mencegah penuaan dini pada kulit antara lain:\n'
              '• Banyak mengonsumsi antioksidan untuk melindungi kulit dari kerusakan\n'
              '• Menghindari rokok dan alkohol\n'
              '• Memperbanyak konsumsi air putih\n'
              '• Menjaga pola hidup sehat secara keseluruhan',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            SizedBox(height: 16),
            Text(
              'Fitur-fitur Aplikasi:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '• Deteksi Penyakit Kulit: Memantau kondisi kulit tubuh dan wajah, serta membantu mengenali penyakit seperti kurap, panu, atau jerawat.\n'
              '• Rekomendasi Produk dan Obat: Memberikan saran produk dan obat sesuai kondisi kulit pengguna, berdasarkan hasil deteksi.\n'
              '• Pantau Perkembangan Kulit: Menyediakan grafik interaktif yang menunjukkan hubungan antara gaya hidup pengguna dan kondisi kulit dari waktu ke waktu.\n'
              '• Reminder Perawatan Kulit: Mengingatkan pengguna agar rutin merawat kulit sesuai kebutuhan.\n'
              '• Edukasi dan Artikel: Memberikan informasi terkini mengenai kesehatan kulit dan tips perawatan yang aman.\n'
              '• Chatbot Interaktif: Memudahkan pengguna bertanya mengenai penyakit kulit dan produk perawatan dengan cepat.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            SizedBox(height: 16),
            Text(
              'Visi kami adalah meningkatkan kesadaran masyarakat akan pentingnya kesehatan kulit dan penggunaan kosmetik yang aman. Dengan Peduli Kulit, setiap pengguna dapat mengambil langkah awal dalam menjaga kulit yang sehat melalui pemantauan, edukasi, dan rekomendasi yang tepat.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
