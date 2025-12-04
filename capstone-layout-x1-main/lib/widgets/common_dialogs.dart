import 'package:flutter/material.dart';

void showComingSoonDialog(BuildContext context, String feature) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text('Segera Hadir'),
      content: Text('Fitur $feature akan segera tersedia!'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK', style: TextStyle(color: Color(0xFF0066CC))),
        ),
      ],
    ),
  );
}
