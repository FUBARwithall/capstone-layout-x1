import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
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
  final String baseUrl = 'http://192.168.56.1:5000/api';

  /// Cegah double async per reminder
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

  // ================= UI =================

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

  // ================= LOGIC =================

  String _typeFromIndex(int index) {
    return index == 0
        ? 'morning'
        : index == 1
            ? 'afternoon'
            : 'night';
  }

  Future<void> _handleEnable(int index) async {
    if (_processingIndex.contains(index)) return;

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (!mounted || picked == null) return;

    /// UI langsung update → TIDAK LAG
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

      await _saveToApi(index, true);

      if (!kIsWeb) {
        await NotificationService.cancel(index + 1);
        await NotificationService.scheduleDaily(
          id: index + 1,
          hour: t.hour,
          minute: t.minute,
          title: 'Reminder Skincare',
          body: 'Waktunya skincare ${reminders[index]['label']} ✨',
        );
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
            content: Text('Error mengaktifkan reminder: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }

      if (mounted) {
        setState(() {
          reminders[index]['enabled'] = false;
          reminders[index]['time'] = null;
        });
      }
    } finally {
      _processingIndex.remove(index);
    }
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

  // ================= API =================

  Future<void> _saveToApi(int index, bool isActive) async {
    final t = reminders[index]['time'] as TimeOfDay?;
    final token = await SecureStorage.getToken();

    if (token == null) {
      debugPrint('No token found, user may not be logged in');
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
      debugPrint('API request timeout');
      throw Exception('Koneksi ke server timeout. Cek koneksi internet Anda');
    } catch (e) {
      debugPrint('API Error: $e');
      rethrow;
    }
  }

  Future<void> _loadRemindersFromApi() async {
    try {
      final token = await SecureStorage.getToken();

      if (token == null) {
        debugPrint('No token found, user may not be logged in');
        return;
      }

      debugPrint('Loading reminders from API...');
      final res = await http
          .get(
            Uri.parse('$baseUrl/reminders'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 10));

      debugPrint('Reminders API Response: ${res.statusCode} - ${res.body}');

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
            reminders[index]['time'] =
                TimeOfDay(hour: item['hour'], minute: item['minute']);
          }
        }
      });

      debugPrint('Reminders loaded successfully');
    } on TimeoutException {
      debugPrint('Load reminders timeout');
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
