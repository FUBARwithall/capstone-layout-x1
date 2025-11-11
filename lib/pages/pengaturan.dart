import 'package:flutter/material.dart';
import 'package:layout_x1/pages/login_page.dart';
import 'user_preferences.dart'; // Import user preferences

class Pengaturan extends StatefulWidget {
  const Pengaturan({super.key});

  @override
  State<Pengaturan> createState() => _PengaturanState();
}

class _PengaturanState extends State<Pengaturan> {
  String _userName = 'Loading...';
  String _userEmail = 'loading@example.com';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await UserPreferences.getUser();

      if (userData != null) {
        setState(() {
          _userName = userData['name'];
          _userEmail = userData['email'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _userName = 'Guest User';
          _userEmail = 'guest@example.com';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _userName = 'Error';
        _userEmail = 'error@example.com';
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    // Tampilkan dialog konfirmasi
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      // Hapus data user dari SharedPreferences
      await UserPreferences.clearUser();

      if (mounted) {
        // Redirect ke login page dan hapus semua route sebelumnya
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
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
          'Pengaturan',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                // 🔹 Header User Profile
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF0066CC)
                    
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 32,
                    horizontal: 16,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.account_circle,
                        size: 80,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _userName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _userEmail,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // 🔹 Daftar menu pengaturan
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text("Profile"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text("Setting Aplikasi"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.access_alarm_rounded),
                  title: const Text("History"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.favorite_border),
                  title: const Text("Favorites"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {},
                ),
                const Divider(),

                // 🔹 Tombol logout dengan konfirmasi
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    "Logout",
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: _handleLogout,
                ),
              ],
            ),
    );
  }
}
