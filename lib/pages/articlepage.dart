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
        title: const Text('Artikel Terkini'),
        backgroundColor: const Color(0xFF0066CC),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _articles.length,
              itemBuilder: (context, index) {
                final article = _articles[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
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
        title: Text(article['title'] ?? 'Detail Artikel'),
        backgroundColor: const Color(0xFF0066CC),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(article['description'] ?? 'Deskripsi tidak tersedia'),
      ),
    );
  }
}
