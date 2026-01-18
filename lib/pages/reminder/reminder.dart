import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/notification_service.dart';
import '../../services/secure_storage.dart';

class ReminderSkincare extends StatefulWidget {
  const ReminderSkincare({super.key});

  @override
  State<ReminderSkincare> createState() => _ReminderSkincareState();
}

class _ReminderSkincareState extends State<ReminderSkincare> {
  final Color skinTone = const Color(0xFFF5F5DC);
  
  /// GANTI SESUAI SERVER
  final String baseUrl = 'https://nonrelativistic-amalia-unconflictingly.ngrok-free.dev/api';

  final Set<int> _processingIndex = {};

  final List<Map<String, dynamic>> reminders = [
    {
      'label': 'Pagi 🌞',
      'time': null,
      'enabled': false,
      'tasks': [
        'Cuci muka (Face Wash)',
        'Gunakan Moisturizer',
        'Aplikasikan Sunscreen (SPF 30+)',
      ],
    },
    {
      'label': 'Siang 🌞',
      'time': null,
      'enabled': false,
      'tasks': [
        'Re-apply Sunscreen (setiap 2–3 jam)',
        'Minum air putih cukup',
      ],
    },
    {
      'label': 'Malam 🌙',
      'time': null,
      'enabled': false,
      'tasks': [
        'Double Cleansing',
        'Gunakan Moisturizer',
      ],
    },
  ];

  late List<List<bool>> taskStatus;

  @override
  void initState() {
    super.initState();
    taskStatus = reminders
        .map((r) => List<bool>.filled(r['tasks'].length, false))
        .toList();
    _loadRemindersFromApi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengingat Skincare Harian (GlowMate)'),
        backgroundColor: const Color(0xFF0066CC),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reminders.length,
        itemBuilder: (context, index) {
          final r = reminders[index];
          final tasks = r['tasks'] as List<String>;

          return Card(
            color: skinTone,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r['label'],
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (r['time'] != null)
                            Text(
                              _formatTime(r['time']),
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                        ],
                      ),
                      Switch(
                        value: r['enabled'],
                        onChanged: (val) {
                          if (val) {
                            _handleEnable(index);
                          } else {
                            _disableReminder(index);
                          }
                        },
                      ),
                    ],
                  ),
                  const Divider(),

                  /// TASKS
                  for (int i = 0; i < tasks.length; i++)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: IconButton(
                        icon: Icon(
                          Icons.check_circle,
                          color: taskStatus[index][i]
                              ? Colors.green
                              : Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            taskStatus[index][i] = !taskStatus[index][i];
                          });
                        },
                      ),
                      title: Text(
                        tasks[i],
                        style: TextStyle(
                          decoration: taskStatus[index][i]
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _typeFromIndex(int index) {
    return index == 0 ? 'morning' : index == 1 ? 'afternoon' : 'night';
  }

  /// Handle enable dengan pre-check permission
  Future<void> _handleEnable(int index) async {
    if (_processingIndex.contains(index)) return;

    // CEK PERMISSION DULU sebelum timepicker
    final canSchedule = await NotificationService.canScheduleExactAlarms();
    
    if (!canSchedule && !kIsWeb) {
      _showPermissionDialog();
      return;
    }

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (!mounted || picked == null) return;

    setState(() {
      reminders[index]['enabled'] = true;
      reminders[index]['time'] = picked;
    });

    _processEnable(index);
  }

  Future<void> _processEnable(int index) async {
    if (_processingIndex.contains(index)) return;
    _processingIndex.add(index);

    try {
      final t = reminders[index]['time'] as TimeOfDay;

      // Save ke API
      await _saveToApi(index, true);

      // Schedule notifikasi
      if (!kIsWeb) {
        await NotificationService.cancel(index + 1);
        
        try {
          await NotificationService.scheduleDaily(
            id: index + 1,
            hour: t.hour,
            minute: t.minute,
            title: 'Reminder Skincare',
            body: 'Waktunya skincare ${reminders[index]['label']} ✨',
          );
        } on PlatformException catch (e) {
          if (e.code == 'PERMISSION_DENIED') {
            if (mounted) {
              _showPermissionDialog();
            }
            _rollbackState(index);
            return;
          }
          rethrow;
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reminder ${reminders[index]['label']} berhasil diaktifkan'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Enable reminder error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      _rollbackState(index);
    } finally {
      _processingIndex.remove(index);
    }
  }

  void _rollbackState(int index) {
    if (mounted) {
      setState(() {
        reminders[index]['enabled'] = false;
        reminders[index]['time'] = null;
      });
    }
  }

  /// Dialog permission yang lebih clean
  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.alarm, color: Colors.orange),
            SizedBox(width: 10),
            Text('Izin Diperlukan'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Aplikasi memerlukan izin untuk menyetel alarm dan pengingat.\n',
              style: TextStyle(fontSize: 14),
            ),
            const Text(
              'Langkah-langkah:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInstructionStep('1', 'Tap "Buka Pengaturan"'),
            _buildInstructionStep('2', 'Cari "Alarms & reminders"'),
            _buildInstructionStep('3', 'Aktifkan toggle-nya'),
            _buildInstructionStep('4', 'Kembali dan coba lagi'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Aktifkan "Alarms & reminders", lalu kembali dan coba lagi',
                    ),
                    backgroundColor: Colors.blue,
                    duration: Duration(seconds: 4),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0066CC),
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.settings),
            label: const Text('Buka Pengaturan'),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Color(0xFF0066CC),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Future<void> _disableReminder(int index) async {
    if (_processingIndex.contains(index)) return;
    _processingIndex.add(index);

    setState(() {
      reminders[index]['enabled'] = false;
      reminders[index]['time'] = null;
    });

    try {
      if (!kIsWeb) {
        await NotificationService.cancel(index + 1);
      }
      await _saveToApi(index, false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reminder ${reminders[index]['label']} berhasil dinonaktifkan'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Disable reminder error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error menonaktifkan reminder: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      _processingIndex.remove(index);
    }
  }

  Future<void> _saveToApi(int index, bool isActive) async {
    final t = reminders[index]['time'] as TimeOfDay?;
    final token = await SecureStorage.getToken();

    if (token == null) {
      throw Exception('Token tidak ditemukan. Silakan login kembali');
    }

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/reminders'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'type': _typeFromIndex(index),
              'hour': t?.hour ?? 0,
              'minute': t?.minute ?? 0,
              'is_active': isActive,
            }),
          )
          .timeout(const Duration(seconds: 10));

      debugPrint('API Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Server error: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Koneksi ke server timeout. Cek koneksi internet Anda');
    }
  }

  Future<void> _loadRemindersFromApi() async {
    try {
      final token = await SecureStorage.getToken();
      if (token == null) return;

      final res = await http
          .get(
            Uri.parse('$baseUrl/reminders'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 10));

      if (res.statusCode != 200) {
        throw Exception('Failed to load reminders: ${res.statusCode}');
      }

      final List data = jsonDecode(res.body);

      setState(() {
        for (var item in data) {
          final index = item['type'] == 'morning'
              ? 0
              : item['type'] == 'afternoon'
                  ? 1
                  : 2;
          
          reminders[index]['enabled'] = item['is_active'] == 1;
          
          if (item['is_active'] == 1) {
            reminders[index]['time'] = TimeOfDay(
              hour: item['hour'],
              minute: item['minute'],
            );
          }
        }
      });

      debugPrint('Reminders loaded successfully');
    } catch (e) {
      debugPrint('Load reminder error: $e');
    }
  }

  String _formatTime(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return 'Jam $h:$m';
  }
}