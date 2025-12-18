import 'package:flutter/material.dart';

class ReminderSkincare extends StatefulWidget {
  const ReminderSkincare({super.key});

  @override
  State<ReminderSkincare> createState() => _ReminderSkincareState();
}

class _ReminderSkincareState extends State<ReminderSkincare> {
  final List<Map<String, dynamic>> skincareReminders = [
    {
      'time': 'Pagi 🌞',
      'tasks': [
        'Cuci muka (Face Wash)',
        'Gunakan Moisturizer',
        'Aplikasikan Sunscreen (SPF 30+)',
        'Re-apply Sunscreen jika cuaca terik & banyak aktivitas di luar'
      ],
    },
    {
      'time': 'Siang ☀️',
      'tasks': [
        'Re-apply Sunscreen (setiap 2–3 jam)',
        'Minum air putih cukup agar kulit tetap lembap',
      ],
    },
    {
      'time': 'Malam 🌙',
      'tasks': [
        'Double Cleansing (Cleansing Oil + Face Wash)',
        'Gunakan Moisturizer',
        'Istirahat cukup (tidur minimal 7 jam)',
      ],
    },
  ];

  late List<List<bool>> taskStatus;

  @override
  void initState() {
    super.initState();
    taskStatus = skincareReminders
        .map((reminder) => List<bool>.filled(reminder['tasks'].length, false))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final Color skinTone = const Color(0xFFF5F5DC);

    return Scaffold(
      appBar: AppBar(
        title: Text('Pengingat Skincare Harian (GlowMate)'),
        backgroundColor: const Color(0xFF0066CC),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: skincareReminders.length,
        itemBuilder: (context, index) {
          final reminder = skincareReminders[index];
          final tasks = reminder['tasks'] as List<String>;

          return Card(
            color: skinTone,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reminder['time'],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),
                  for (int i = 0; i < tasks.length; i++)
                    ListTile(
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
                          color: taskStatus[index][i]
                              ? Colors.black54
                              : Colors.black,
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
}
