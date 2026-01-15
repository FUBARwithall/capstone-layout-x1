import 'package:flutter/material.dart';
import 'package:layout_x1/pages/history/historydetail.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  bool _loading = true;
  List<dynamic> _history = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    final result = await ApiService.getHistory();

    if (!mounted) return;

    setState(() {
      if (result['success']) {
        _history = result['history'] ?? [];
        _errorMessage = null;
      } else {
        _history = [];
        _errorMessage = result['message'] ?? 'Gagal memuat history';
      }
      _loading = false;
    });
  }

  /// ⬇️ ID SEKARANG STRING (FIX UTAMA)
  Future<void> _deleteHistoryItem(String analysisId, int index) async {
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
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.red),
            ),
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
      setState(() => _history.removeAt(index));

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
      final dt = DateTime.parse(safe);
      return DateFormat('dd MMM yyyy, HH:mm').format(dt);
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
      ),
      body: RefreshIndicator(
        onRefresh: _fetchHistory,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? _buildErrorState()
                : _history.isEmpty
                    ? _buildEmptyState()
                    : _buildHistoryList(),
      ),
    );
  }

  Widget _buildErrorState() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 100),
        Icon(Icons.error_outline, size: 80, color: Colors.red.shade300),
        const SizedBox(height: 16),
        Text(
          _errorMessage ?? 'Terjadi kesalahan',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
        const SizedBox(height: 24),
        Center(
          child: ElevatedButton.icon(
            onPressed: _fetchHistory,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        SizedBox(height: 150),
        Icon(Icons.history, size: 80, color: Colors.black26),
        SizedBox(height: 16),
        Text(
          'Belum ada history deteksi',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final item = _history[index];

        /// ⬇️ ID SELALU STRING
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
            imageUrl = '$rootUrl${rawUrl.startsWith('/') ? rawUrl : '/$rawUrl'}';
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
            await _deleteHistoryItem(analysisId, index);
            return false;
          },
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => HistoryDetailPage(
        analysisId: item['id'].toString(), // 👈 ID DIKIRIM
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

  Widget _imageError() {
    return Container(
      width: 70,
      height: 70,
      color: Colors.grey.shade200,
      child: const Icon(Icons.broken_image),
    );
  }
}
