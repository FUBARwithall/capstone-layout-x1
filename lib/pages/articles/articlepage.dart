import 'package:flutter/material.dart';
import 'package:layout_x1/pages/articles/articledetailpage.dart';
import '../../services/api_service.dart';

class ArticlesPageBody extends StatefulWidget {
  final int userId;

  const ArticlesPageBody({Key? key, required this.userId}) : super(key: key);

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
      final result = await ApiService.getArticles();
      if (result['success']) {
        setState(() {
          _articles = result['data'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _articles = [];
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Gagal memuat artikel'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _articles = [];
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showArticleDetail(Map<String, dynamic> article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ArticleDetailPage(
          article: article,
          userId: widget.userId, // ✅ AMAN
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kabar Terkini'),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
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
                    leading:
                        article['image'] != null &&
                            article['image'].toString().isNotEmpty
                        ? Image.network(
                            'http://localhost:5000/uploads/${article['image']}',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.article,
                                size: 50,
                                color: Colors.grey,
                              );
                            },
                          )
                        : Icon(Icons.article, size: 50, color: Colors.grey),
                    title: Text(article['title'] ?? ''),
                    subtitle: Text(
                      article['description'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => _showArticleDetail(article),
                  ),
                );
              },
            ),
    );
  }
}
