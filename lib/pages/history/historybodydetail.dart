import 'package:flutter/material.dart';
import 'package:layout_x1/services/api_service.dart';
import 'package:layout_x1/services/user_preferences.dart';

class HistoryBodyDetailPage extends StatefulWidget {
  final String analysisId;
  const HistoryBodyDetailPage({super.key, required this.analysisId});

  @override
  State<HistoryBodyDetailPage> createState() => _HistoryBodyDetailPageState();
}

class _HistoryBodyDetailPageState extends State<HistoryBodyDetailPage> {
  bool isLoading = true;
  Map<String, dynamic>? detectionData;
  int? userId;

  // Notes functionality
  final TextEditingController _notesController = TextEditingController();
  bool isEditingNotes = false;
  bool isSavingNotes = false;

  String get rootUrl => ApiService.baseUrl.replaceFirst('/api', '');

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final id = await UserPreferences.getUserId();
    setState(() {
      userId = id;
    });
    _loadHistoryDetail();
  }

  Future<void> _loadHistoryDetail() async {
    final result = await ApiService.getBodyHistoryDetail(widget.analysisId);

    if (!mounted) return;

    if (result['success'] == true) {
      final data = result['data'];

      setState(() {
        detectionData = data;
        isLoading = false;
        // Load notes from server
        _notesController.text = data?['notes'] ?? '';
      });
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Gagal memuat detail'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveNotes() async {
    setState(() => isSavingNotes = true);

    final result = await ApiService.updateBodyNotes(
      widget.analysisId,
      _notesController.text.trim(),
    );

    if (!mounted) return;
    setState(() => isSavingNotes = false);

    if (result['success'] == true) {
      setState(() {
        isEditingNotes = false;
        if (detectionData != null) {
          detectionData!['notes'] = result['notes'];
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Catatan berhasil disimpan'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Gagal menyimpan catatan'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteNote() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Catatan'),
        content: const Text('Apakah Anda yakin ingin menghapus catatan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => isSavingNotes = true);

    final result = await ApiService.updateBodyNotes(
      widget.analysisId,
      '', // Empty string to delete
    );

    if (!mounted) return;
    setState(() => isSavingNotes = false);

    if (result['success'] == true) {
      setState(() {
        isEditingNotes = false;
        _notesController.clear();
        if (detectionData != null) {
          detectionData!['notes'] = null;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Catatan berhasil dihapus'),
          backgroundColor: Colors.blue,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Gagal menghapus catatan'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _cancelEditNotes() {
    setState(() {
      isEditingNotes = false;
      _notesController.text = detectionData?['notes'] ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0066CC),
        foregroundColor: Colors.white,
        title: const Text('Detail Riwayat Penyakit Tubuh'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF0066CC)),
            )
          : detectionData == null
          ? const Center(child: Text('Data tidak tersedia'))
          : SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth < 600 ? 20 : screenWidth * 0.1,
                  vertical: 30,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    bool isWide = constraints.maxWidth > 800;
                    return Column(
                      children: [
                        isWide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: _buildInfoText()),
                                  const SizedBox(width: 40),
                                  Expanded(child: _buildAnalysisImage()),
                                ],
                              )
                            : Column(
                                children: [
                                  _buildInfoText(),
                                  const SizedBox(height: 32),
                                  _buildAnalysisImage(),
                                ],
                              ),
                        const SizedBox(height: 40),
                        _buildDetectionResult(constraints),
                        const SizedBox(height: 24),
                        _buildNotesSection(),
                      ],
                    );
                  },
                ),
              ),
            ),
    );
  }

  Widget _buildInfoText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detail riwayat analisis penyakit kulit tubuh.',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C2C2C),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Halaman ini menampilkan hasil deteksi penyakit kulit yang telah Anda lakukan sebelumnya, lengkap dengan gejala dan saran pengobatan.',
          style: TextStyle(fontSize: 14, height: 1.6, color: Color(0xFF5C5C5C)),
        ),
      ],
    );
  }

  Widget _buildAnalysisImage() {
    final imageUrl = detectionData!['image_url'];
    final fullUrl = imageUrl != null ? '$rootUrl$imageUrl' : null;

    return Center(
      child: Container(
        width: 400,
        height: 300,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: fullUrl != null
              ? Image.network(
                  fullUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _imagePlaceholder(),
                )
              : _imagePlaceholder(),
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return const Center(
      child: Icon(
        Icons.image_not_supported_outlined,
        size: 48,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildDetectionResult(BoxConstraints constraints) {
    final diseaseAnalysis = detectionData!['disease_analysis'];
    final diseaseInfo = diseaseAnalysis['disease_info'];
    final timestamp = detectionData!['timestamp'] ?? '';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF0066CC), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.medical_services, color: Color(0xFF0066CC), size: 28),
              SizedBox(width: 10),
              Text(
                'Hasil Deteksi',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C2C2C),
                ),
              ),
            ],
          ),
          if (timestamp.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Dianalisis pada: ${_formatTimestamp(timestamp)}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
              ),
            ),
          const Divider(height: 24, thickness: 1),
          _buildResultField(
            icon: Icons.healing,
            title: 'Penyakit Terdeteksi',
            content: diseaseInfo['nama'] ?? '-',
            confidence: diseaseAnalysis['confidence'] is num
                ? '${(diseaseAnalysis['confidence'] as num).toStringAsFixed(1)}%'
                : diseaseAnalysis['confidence']?.toString() ?? '-',
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            diseaseInfo['deskripsi'] ?? '',
            textAlign: TextAlign.justify,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF666666),
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          if (diseaseInfo['gejala'] != null &&
              (diseaseInfo['gejala'] as List).isNotEmpty)
            _buildListSection(
              icon: Icons.checklist,
              title: 'Gejala',
              items: List<String>.from(diseaseInfo['gejala']),
              color: Colors.orange,
            ),
          const SizedBox(height: 20),
          if (diseaseInfo['obat'] != null &&
              (diseaseInfo['obat'] as List).isNotEmpty)
            _buildListSection(
              icon: Icons.medication,
              title: 'Pengobatan',
              items: List<String>.from(diseaseInfo['obat']),
              color: Colors.green,
            ),
        ],
      ),
    );
  }

  Widget _buildResultField({
    required IconData icon,
    required String title,
    required String content,
    required String confidence,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  content,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  confidence,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListSection({
    required IconData icon,
    required String title,
    required List<String> items,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: items
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.circle, size: 8, color: color),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF0066CC), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.note_alt, color: Color(0xFF0066CC), size: 24),
                  SizedBox(width: 10),
                  Text(
                    'Catatan Pribadi',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    setState(() => isEditingNotes = true);
                  } else if (value == 'delete') {
                    _deleteNote();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  if (_notesController.text.isNotEmpty)
                    const PopupMenuItem(value: 'delete', child: Text('Hapus')),
                ],
              ),
            ],
          ),
          const Divider(height: 24),
          if (isEditingNotes)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _notesController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: 'Tambahkan catatan...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: isSavingNotes ? null : _cancelEditNotes,
                      child: const Text('Batal'),
                    ),
                    ElevatedButton(
                      onPressed: isSavingNotes ? null : _saveNotes,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0066CC),
                      ),
                      child: isSavingNotes
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Simpan',
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ],
                ),
              ],
            )
          else
            GestureDetector(
              onTap: () {
                setState(() {
                  isEditingNotes = true;
                  _notesController.text = detectionData?['notes'] ?? '';
                });
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _notesController.text.isEmpty
                      ? Colors.grey[100]
                      : const Color(0xFF0066CC).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _notesController.text.isEmpty
                        ? Colors.grey[300]!
                        : const Color(0xFF0066CC).withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _notesController.text.isEmpty
                            ? 'Belum ada catatan.\nTap di sini untuk menambahkan catatan pribadi.'
                            : _notesController.text,
                        style: TextStyle(
                          color: _notesController.text.isEmpty
                              ? Colors.grey
                              : const Color(0xFF2C2C2C),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    try {
      final dt = DateTime.parse(timestamp).toLocal();
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return timestamp;
    }
  }
}
