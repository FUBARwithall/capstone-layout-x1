import 'package:flutter/material.dart';

class ArticleDetailPage extends StatelessWidget {
  final Map<String, dynamic> article;

  const ArticleDetailPage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0066CC),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          article['title'] ?? 'Judul Artikel',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan metadata
            if (article['date'] != null || article['views'] != null)
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF0066CC), Color(0xFF004C99)],
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    if (article['date'] != null) ...[
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        article['date'],
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                    if (article['date'] != null && article['views'] != null)
                      const SizedBox(width: 16),
                    if (article['views'] != null) ...[
                      const Icon(
                        Icons.visibility,
                        size: 16,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        article['views'],
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

            // Gambar dummy
            Container(
              width: double.infinity,
              height: 250,
              color: Colors.grey[300],
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.article_outlined,
                      size: 80,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Gambar Artikel',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

            // Konten artikel
            Container(
              padding: const EdgeInsets.all(20),
              child: Text(
                (article['description'] ?? 'Deskripsi tidak tersedia')
                    .replaceAll(r'\n', '\n\n'),
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.justify,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
