import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class ArticlesPageBody extends StatefulWidget {
  @override
  State<ArticlesPageBody> createState() => _ArticlesPageBodyState();
}

class _ArticlesPageBodyState extends State<ArticlesPageBody> {
  List<dynamic> _articles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  Future<void> _loadArticles() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/articles.json');
      final data = json.decode(jsonString);
      setState(() {
        _articles = data;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  void _showArticleDetail(Map<String, dynamic> article) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ArticleDetailPage(article: article)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kabar Terkini'),
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        backgroundColor: Color(0xFF0066CC),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _articles.length,
              itemBuilder: (context, index) {
                final article = _articles[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading: Text(article['image'] ?? '📄', style: const TextStyle(fontSize: 28)),
                    title: Text(article['title'] ?? ''),
                    subtitle: Text(article['description'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
                    onTap: () => _showArticleDetail(article),
                  ),
                );
              },
            ),
    );
  }
}


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
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan judul
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul artikel
                  Text(
                    article['title'] ?? 'Judul Artikel',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Metadata (opsional)
                  if (article['date'] != null || article['views'] != null)
                    Row(
                      children: [
                        if (article['date'] != null) ...[
                          const Icon(Icons.access_time, 
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
                          const Icon(Icons.visibility, 
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
                ],
              ),
            ),
            
            // Gambar Dummy
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.grey[300],
              ),
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
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Konten artikel
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Deskripsi/konten artikel
                  Text(
                    article['description'] ?? 'Deskripsi tidak tersedia',
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}