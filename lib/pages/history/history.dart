import 'package:flutter/material.dart';
import 'package:layout_x1/pages/history/historyfacedetail.dart';
import 'package:layout_x1/pages/history/historybodydetail.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool _loadingFace = true;
  List<dynamic> _historyFace = [];
  String? _errorMessageFace;

  bool _loadingBody = true;
  List<dynamic> _historyBody = [];
  String? _errorMessageBody;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchFaceHistory();
    _fetchBodyHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchFaceHistory() async {
    setState(() {
      _loadingFace = true;
      _errorMessageFace = null;
    });

    final result = await ApiService.getHistory();

    if (!mounted) return;

    setState(() {
      if (result['success']) {
        _historyFace = result['history'] ?? [];
        _errorMessageFace = null;
      } else {
        _historyFace = [];
        _errorMessageFace = result['message'] ?? 'Gagal memuat history';
      }
      _loadingFace = false;
    });
  }

  Future<void> _fetchBodyHistory() async {
    setState(() {
      _loadingBody = true;
      _errorMessageBody = null;
    });

    final result = await ApiService.getBodyHistory();

    if (!mounted) return;

    setState(() {
      if (result['success']) {
        _historyBody = result['history'] ?? [];
        _errorMessageBody = null;
      } else {
        _historyBody = [];
        _errorMessageBody = result['message'] ?? 'Gagal memuat history tubuh';
      }
      _loadingBody = false;
    });
  }

  /// Delete face history
  Future<void> _deleteFaceHistoryItem(String analysisId, int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus History'),
        content: const Text('Yakin ingin menghapus history ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final result = await ApiService.deleteHistory(analysisId);

    if (!mounted) return;

    Navigator.pop(context);

    if (result['success']) {
      setState(() => _historyFace.removeAt(index));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'History berhasil dihapus'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Gagal menghapus history'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Delete body history
  Future<void> _deleteBodyHistoryItem(String analysisId, int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus History'),
        content: const Text('Yakin ingin menghapus history ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final result = await ApiService.deleteBodyHistory(analysisId);

    if (!mounted) return;

    Navigator.pop(context);

    if (result['success']) {
      setState(() => _historyBody.removeAt(index));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'History berhasil dihapus'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Gagal menghapus history'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDate(dynamic raw) {
    if (raw == null) return '-';

    try {
      final safe = raw.toString().replaceFirst(' ', 'T');
      // Parse timestamp (will include timezone info if provided)
      final dt = DateTime.parse(safe);

      // Convert to local time (WIB)
      final localDt = dt.toLocal();

      return DateFormat('dd MMM yyyy, HH:mm').format(localDt);
    } catch (e) {
      return raw.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'History Deteksi',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF0066CC),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF0066CC),
          tabs: const [
            Tab(text: 'History Wajah'),
            Tab(text: 'History Tubuh'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Face History
          RefreshIndicator(
            onRefresh: _fetchFaceHistory,
            child: _loadingFace
                ? const Center(child: CircularProgressIndicator())
                : _errorMessageFace != null
                ? _buildErrorState(_errorMessageFace!, _fetchFaceHistory)
                : _historyFace.isEmpty
                ? _buildEmptyState('Belum ada history deteksi wajah')
                : _buildFaceHistoryList(),
          ),
          // Tab 2: Body History
          RefreshIndicator(
            onRefresh: _fetchBodyHistory,
            child: _loadingBody
                ? const Center(child: CircularProgressIndicator())
                : _errorMessageBody != null
                ? _buildErrorState(_errorMessageBody!, _fetchBodyHistory)
                : _historyBody.isEmpty
                ? _buildEmptyState('Belum ada history deteksi tubuh')
                : _buildBodyHistoryList(),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message, VoidCallback onRetry) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 100),
        Icon(Icons.error_outline, size: 80, color: Colors.red.shade300),
        const SizedBox(height: 16),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
        const SizedBox(height: 24),
        Center(
          child: ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 150),
        const Icon(Icons.history, size: 80, color: Colors.black26),
        const SizedBox(height: 16),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildFaceHistoryList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _historyFace.length,
      itemBuilder: (context, index) {
        final item = _historyFace[index];

        /// ID SELALU STRING
        final String analysisId = item['id'].toString();

        final String? rawUrl = item['image_url']?.toString();
        String? imageUrl;

        if (rawUrl != null && rawUrl.isNotEmpty) {
          if (rawUrl.startsWith('http')) {
            imageUrl = rawUrl;
          } else {
            // ApiService.baseUrl sudah mengandung '/api'
            // rawUrl dari backend juga sudah mengandung '/api/history/...'
            // Kita ambil root URL (tanpa /api di akhir)
            final rootUrl = ApiService.baseUrl.replaceFirst('/api', '');
            imageUrl =
                '$rootUrl${rawUrl.startsWith('/') ? rawUrl : '/$rawUrl'}';
          }
        }

        return Dismissible(
          key: Key('history_$analysisId'),
          direction: DismissDirection.endToStart,
          background: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (_) async {
            await _deleteFaceHistoryItem(analysisId, index);
            return false;
          },
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
             Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HistoryDetailPage(
                    analysisId: item['id'].toString(),
                    categoryId: item['category_id'] ?? 0, // id kategori
                    categoryName: item['category_name'] ?? '', // nama kategori
                  ),
                ),
              );

            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: imageUrl != null
                        ? Image.network(
                            imageUrl,
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _imageError(),
                          )
                        : _imageError(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['skin_type'] ?? '-',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['skin_problem'] ?? '-',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _formatDate(item['timestamp']),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBodyHistoryList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _historyBody.length,
      itemBuilder: (context, index) {
        final item = _historyBody[index];

        final String analysisId = item['analysis_id'].toString();
        final String? rawUrl = item['image_url']?.toString();
        String? imageUrl;

        if (rawUrl != null && rawUrl.isNotEmpty) {
          if (rawUrl.startsWith('http')) {
            imageUrl = rawUrl;
          } else {
            final rootUrl = ApiService.baseUrl.replaceFirst('/api', '');
            imageUrl =
                '$rootUrl${rawUrl.startsWith('/') ? rawUrl : '/$rawUrl'}';
          }
        }

        // Debug logging
        print('🔍 [BodyHistory] Item #$index - Raw URL: $rawUrl');
        print('🔍 [BodyHistory] Item #$index - Constructed URL: $imageUrl');

        return Dismissible(
          key: Key('body_history_$analysisId'),
          direction: DismissDirection.endToStart,
          background: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (_) async {
            await _deleteBodyHistoryItem(analysisId, index);
            return false;
          },
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HistoryBodyDetailPage(
                    analysisId: item['analysis_id'].toString(),
                  ),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: imageUrl != null
                        ? Image.network(
                            imageUrl,
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _imageError(),
                          )
                        : _imageError(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['disease_name'] ?? '-',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Confidence: ${item['confidence']?.toStringAsFixed(1) ?? '-'}%',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _formatDate(item['timestamp']),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _imageError() {
    return Container(
      width: 70,
      height: 70,
      color: Colors.grey.shade200,
      child: const Icon(Icons.broken_image),
    );
  }
}
