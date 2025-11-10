import 'package:flutter/material.dart';

class PantauKulitPage extends StatefulWidget {
  const PantauKulitPage({super.key});

  @override
  State<PantauKulitPage> createState() => _PantauKulitPageState();
}

class _PantauKulitPageState extends State<PantauKulitPage> {
  @override
  Widget build(BuildContext context) {
   return Center(
    
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'Pantau Kulit',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Fitur akan segera tersedia',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}