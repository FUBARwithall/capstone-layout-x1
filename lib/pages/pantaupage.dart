import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:layout_x1/services/api_service.dart';

void main() {
  runApp(const PantauKulitPage());
}

class PantauKulitPage extends StatelessWidget {
  const PantauKulitPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pemantau Kesehatan Kulit',
      home: SkinHealthTracker(),
    );
  }
}

// ================= MODELS =================

class FoodItem {
  final int id;
  final String name;

  FoodItem({required this.id, required this.name});

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(id: json['id'], name: json['name']);
  }
}

class DrinkItem {
  final int id;
  final String name;
  final String drinkType;

  DrinkItem({required this.id, required this.name, required this.drinkType});

  factory DrinkItem.fromJson(Map<String, dynamic> json) {
    return DrinkItem(
      id: json['id'],
      name: json['name'],
      drinkType: json['drink_type'],
    );
  }
}

class FoodLog {
  final int foodId;
  final String foodName;
  final int quantity;

  FoodLog({
    required this.foodId,
    required this.foodName,
    required this.quantity,
  });
}

class DrinkLog {
  final int drinkId;
  final String drinkName;
  final int quantity;

  DrinkLog({
    required this.drinkId,
    required this.drinkName,
    required this.quantity,
  });
}

// ================= MAIN PAGE =================

class SkinHealthTracker extends StatefulWidget {
  const SkinHealthTracker({super.key});

  @override
  State<SkinHealthTracker> createState() => _SkinHealthTrackerState();
}

class _SkinHealthTrackerState extends State<SkinHealthTracker>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  DateTime _selectedDate = DateTime.now();

  // ---------- FOOD ----------
  List<FoodItem> _availableFoods = [];
  int? _selectedFoodId;
  int _foodQuantity = 1;
  bool _loadingFoods = true;
  final List<FoodLog> _foodLogs = [];

  // ---------- DRINK ----------
  List<DrinkItem> _availableDrinks = [];
  int? _selectedDrinkId;
  int _drinkQuantity = 1;
  bool _loadingDrinks = true;
  final List<DrinkLog> _drinkLogs = [];

  // ---------- SLEEP ----------
  double _sleepHours = 7.0;

  // ---------- SKIN CONDITION ----------
  double _skinCondition = 5;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadFoods();
    _loadDrinks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ================= API =================

  Future<void> _loadFoods() async {
    final res = await ApiService.getFoods();

    if (!mounted) return;

    if (res['success'] == true) {
      setState(() {
        _availableFoods = (res['data'] as List)
            .map((e) => FoodItem.fromJson(e))
            .toList();
        _loadingFoods = false;
      });
    } else {
      setState(() {
        _loadingFoods = false;
      });
      _showError('Gagal memuat daftar makanan');
    }
  }

  Future<void> _loadDrinks() async {
    final res = await ApiService.getDrinks();

    if (!mounted) return;

    if (res['success'] == true && res['data'] is List) {
      setState(() {
        _availableDrinks = (res['data'] as List)
            .map((e) => DrinkItem.fromJson(e))
            .toList();
        _loadingDrinks = false;
      });
    } else {
      _loadingDrinks = false;
      _showError('Format data minuman tidak valid');
    }
  }

  Future<void> _submitDailyLog() async {
    // Validation
    if (_foodLogs.isEmpty) {
      _showError('Tambahkan minimal 1 makanan');
      return;
    }

    if (_drinkLogs.isEmpty) {
      _showError('Tambahkan minimal 1 minuman');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final userId = 1; // TODO: Replace with actual user ID
      final logDate = DateFormat('yyyy-MM-dd').format(_selectedDate);

      // 1. Submit all food logs
      for (var log in _foodLogs) {
        final foodRes = await ApiService.createDailyFoodLog(
          userId: userId,
          foodId: log.foodId,
          quantity: log.quantity,
          logDate: logDate,
        );

        if (foodRes['success'] != true) {
          throw Exception('Gagal menyimpan log makanan');
        }
      }

      // 2. Submit all drink logs
      for (var log in _drinkLogs) {
        final drinkRes = await ApiService.createDailyDrinkLog(
          userId: userId,
          drinkId: log.drinkId,
          quantity: log.quantity,
          logDate: logDate,
        );

        if (drinkRes['success'] != true) {
          throw Exception('Gagal menyimpan log minuman');
        }
      }

      // 3. Submit sleep log
      final sleepRes = await ApiService.createDailySleepLog(
        userId: userId,
        sleepHours: _sleepHours,
        logDate: logDate,
      );

      if (sleepRes['success'] != true) {
        throw Exception('Gagal menyimpan log tidur');
      }

      // 4. Generate analysis
      final analysisRes = await ApiService.generateSkinAnalysis(
        userId: userId,
        logDate: logDate,
      );

      if (analysisRes['success'] == true) {
        _showAnalysisDialog(analysisRes['data']);
        _clearForm();
      } else {
        throw Exception('Gagal menghasilkan analisis');
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _addFoodLog() {
    if (_selectedFoodId == null) {
      _showError('Pilih makanan terlebih dahulu');
      return;
    }

    final selectedFood = _availableFoods.firstWhere(
      (f) => f.id == _selectedFoodId,
    );

    setState(() {
      _foodLogs.add(
        FoodLog(
          foodId: _selectedFoodId!,
          foodName: selectedFood.name,
          quantity: _foodQuantity,
        ),
      );
      _selectedFoodId = null;
      _foodQuantity = 1;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Makanan ditambahkan'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _removeFoodLog(int index) {
    setState(() {
      _foodLogs.removeAt(index);
    });
  }

  void _addDrinkLog() {
    if (_selectedDrinkId == null) {
      _showError('Pilih minuman terlebih dahulu');
      return;
    }

    final selectedDrink = _availableDrinks.firstWhere(
      (d) => d.id == _selectedDrinkId,
    );

    setState(() {
      _drinkLogs.add(
        DrinkLog(
          drinkId: _selectedDrinkId!,
          drinkName: selectedDrink.name,
          quantity: _drinkQuantity,
        ),
      );
      _selectedDrinkId = null;
      _drinkQuantity = 1;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Minuman ditambahkan'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _removeDrinkLog(int index) {
    setState(() {
      _drinkLogs.removeAt(index);
    });
  }

  void _clearForm() {
    setState(() {
      _foodLogs.clear();
      _drinkLogs.clear();
      _sleepHours = 7.0;
      _skinCondition = 5;
      _selectedFoodId = null;
      _selectedDrinkId = null;
      _foodQuantity = 1;
      _drinkQuantity = 1;
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showAnalysisDialog(Map<String, dynamic> analysis) {
    final status = analysis['status'] ?? 'UNKNOWN';
    final score = analysis['skin_load_score'] ?? 0.0;
    final triggers = analysis['main_triggers'] ?? '-';

    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case 'AMAN':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'WASPADA':
        statusColor = Colors.orange;
        statusIcon = Icons.warning;
        break;
      case 'OVER_LIMIT':
        statusColor = Colors.red;
        statusIcon = Icons.error;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(statusIcon, color: statusColor, size: 32),
            const SizedBox(width: 12),
            const Text('Hasil Analisis Kulit'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status: $status',
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Skin Load Score: ${score.toStringAsFixed(1)}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            const Text(
              'Pemicu Utama:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(triggers),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _tabController.animateTo(1);
            },
            child: const Text('Lihat Detail'),
          ),
        ],
      ),
    );
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pemantau Kesehatan Kulit'),
        backgroundColor: const Color(0xFF0066CC),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.edit), text: 'Input'),
            Tab(icon: Icon(Icons.analytics), text: 'Analisis'),
            Tab(icon: Icon(Icons.photo_library), text: 'Galeri'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInputPage(),
          _buildAnalysisPage(),
          _buildGalleryPage(),
        ],
      ),
    );
  }

  Widget _buildInputPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // DATE PICKER
          Card(
            elevation: 2,
            child: ListTile(
              leading: const Icon(
                Icons.calendar_today,
                color: Color(0xFF0066CC),
              ),
              title: const Text('Tanggal'),
              subtitle: Text(
                DateFormat('EEEE, dd MMMM yyyy').format(_selectedDate),
              ),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2024),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() => _selectedDate = picked);
                }
              },
            ),
          ),
          const SizedBox(height: 24),

          // SKIN CONDITION
          _buildSectionTitle('Kondisi Kulit Hari Ini'),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    '${_skinCondition.toInt()}/10',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0066CC),
                    ),
                  ),
                  Slider(
                    value: _skinCondition,
                    min: 1,
                    max: 10,
                    divisions: 9,
                    label: _skinCondition.toInt().toString(),
                    activeColor: const Color(0xFF0066CC),
                    onChanged: (v) => setState(() => _skinCondition = v),
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Buruk', style: TextStyle(fontSize: 12)),
                      Text('Sangat Baik', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // FOOD SECTION
          _buildSectionTitle('Makanan'),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _loadingFoods
                      ? const Center(child: CircularProgressIndicator())
                      : DropdownButtonFormField<int>(
                          value: _selectedFoodId,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Pilih makanan',
                            prefixIcon: Icon(Icons.restaurant),
                          ),
                          items: _availableFoods
                              .map(
                                (f) => DropdownMenuItem(
                                  value: f.id,
                                  child: Text(f.name),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => _selectedFoodId = v),
                        ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: _foodQuantity,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Porsi',
                            prefixIcon: Icon(Icons.add_box),
                          ),
                          items: List.generate(
                            10,
                            (i) => DropdownMenuItem(
                              value: i + 1,
                              child: Text('${i + 1}x porsi'),
                            ),
                          ),
                          onChanged: (v) =>
                              setState(() => _foodQuantity = v ?? 1),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _addFoodLog,
                        icon: const Icon(Icons.add),
                        label: const Text('Tambah'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0066CC),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          if (_foodLogs.isNotEmpty) ...[
            const SizedBox(height: 12),
            Card(
              elevation: 1,
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _foodLogs.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final log = _foodLogs[index];
                  return ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFF0066CC),
                      child: Icon(
                        Icons.restaurant,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(log.foodName),
                    subtitle: Text('${log.quantity}x porsi'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeFoodLog(index),
                    ),
                  );
                },
              ),
            ),
          ],

          const SizedBox(height: 24),

          // DRINK SECTION
          _buildSectionTitle('Minuman'),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _loadingDrinks
                      ? const Center(child: CircularProgressIndicator())
                      : DropdownButtonFormField<int>(
                          value: _selectedDrinkId,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Pilih minuman',
                            prefixIcon: Icon(Icons.local_drink),
                          ),
                          items: _availableDrinks
                              .map(
                                (d) => DropdownMenuItem(
                                  value: d.id,
                                  child: Text(d.name),
                                ),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedDrinkId = v),
                        ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: _drinkQuantity,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Jumlah',
                            prefixIcon: Icon(Icons.format_list_numbered),
                          ),
                          items: List.generate(
                            15,
                            (i) => DropdownMenuItem(
                              value: i + 1,
                              child: Text('${i + 1} gelas'),
                            ),
                          ),
                          onChanged: (v) =>
                              setState(() => _drinkQuantity = v ?? 1),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _addDrinkLog,
                        icon: const Icon(Icons.add),
                        label: const Text('Tambah'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0066CC),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          if (_drinkLogs.isNotEmpty) ...[
            const SizedBox(height: 12),
            Card(
              elevation: 1,
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _drinkLogs.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final log = _drinkLogs[index];
                  return ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFF0066CC),
                      child: Icon(
                        Icons.local_drink,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(log.drinkName),
                    subtitle: Text('${log.quantity} gelas'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeDrinkLog(index),
                    ),
                  );
                },
              ),
            ),
          ],

          const SizedBox(height: 24),

          // SLEEP SECTION
          _buildSectionTitle('Durasi Tidur'),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    '${_sleepHours.toStringAsFixed(1)} jam',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0066CC),
                    ),
                  ),
                  Slider(
                    value: _sleepHours,
                    min: 3,
                    max: 12,
                    divisions: 18,
                    label: '${_sleepHours.toStringAsFixed(1)} jam',
                    activeColor: const Color(0xFF0066CC),
                    onChanged: (v) => setState(() => _sleepHours = v),
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('3 jam', style: TextStyle(fontSize: 12)),
                      Text('12 jam', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // SUBMIT BUTTON
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submitDailyLog,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.analytics),
              label: Text(
                _isSubmitting ? 'Memproses...' : 'Simpan & Analisis',
                style: const TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0066CC),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0066CC),
        ),
      ),
    );
  }

  Widget _buildAnalysisPage() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Analisis (placeholder)',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryPage() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_library, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Galeri (placeholder)',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
