import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_html/flutter_html.dart';

class ArticleDetailPage extends StatefulWidget {
  final Map<String, dynamic> article;
  final int userId;

  const ArticleDetailPage({
    super.key,
    required this.article,
    required this.userId,
  });

  @override
  State<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  bool isLoved = false;
  bool _favoriteChanged = false;
  late int userId;

  @override
  void initState() {
    super.initState();
    userId = widget.userId;
    fetchFavoriteStatus();
  }

  Future<void> fetchFavoriteStatus() async {
    final articleId = widget.article['id'];
    final url = Uri.parse(
      'http://localhost:5000/api/articles/$articleId/favorite/status?user_id=$userId',
    );

    try {
      final response = await http.get(url);
      final data = jsonDecode(response.body);

      setState(() {
        isLoved = data['favorite'] ?? false;
      });
    } catch (e) {
      debugPrint('Fetch favorite error: $e');
    }
  }

  Future<void> toggleFavorite() async {
    final articleId = widget.article['id'];
    final url = Uri.parse(
      'http://localhost:5000/api/articles/$articleId/favorite',
    );

    try {
      if (isLoved) {
        await http.delete(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'user_id': userId}),
        );

        setState(() {
          isLoved = false;
          _favoriteChanged = true; 
        });
      } else {
        await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'user_id': userId}),
        );

        setState(() {
          isLoved = true;
          _favoriteChanged = true; 
        });
      }
    } catch (e) {
      debugPrint('Toggle favorite error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, {
          'changed': _favoriteChanged,
          'article_id': widget.article['id'],
          'isLoved': isLoved,
        });
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF0066CC),
          foregroundColor: Colors.white,
          elevation: 0,
          title: Text(
            widget.article['title'] ?? 'Judul Artikel',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: IconButton(
                icon: Icon(
                  isLoved ? Icons.favorite : Icons.favorite_border,
                  color: isLoved ? Colors.red : Colors.white,
                ),
                onPressed: toggleFavorite,
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.article['date'] != null ||
                  widget.article['views'] != null)
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
                      if (widget.article['date'] != null) ...[
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.article['date'],
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                      if (widget.article['views'] != null) ...[
                        const SizedBox(width: 16),
                        const Icon(
                          Icons.visibility,
                          size: 16,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.article['views'],
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ],
                  ),
                ),

              if (widget.article['image'] != null &&
                  widget.article['image'].toString().isNotEmpty)
                Container(
                  width: double.infinity,
                  height: 400,
                  child: Image.network(
                    'http://localhost:5000/uploads/${widget.article['image']}',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
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
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
              else
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
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              Container(
                padding: const EdgeInsets.all(20),
                child: Html(
                  data:
                      widget.article['description'] ??
                      '<p>Deskripsi tidak tersedia</p>',
                  style: {
                    "body": Style(
                      fontSize: FontSize(16),
                      lineHeight: LineHeight.number(1.6),
                      textAlign: TextAlign.justify,
                      margin: Margins.zero,
                    ),
                    "p": Style(margin: Margins.only(bottom: 16)),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
