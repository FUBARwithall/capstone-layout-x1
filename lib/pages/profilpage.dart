import 'package:flutter/material.dart';
import 'user_preferences.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  String _userName = '';
  String _userEmail = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    print('=== DEBUG PROFIL PAGE ===');

    try {
      final userData = await UserPreferences.getUser();
      print('User data loaded: $userData');

      if (userData != null) {
        setState(() {
          _userName = userData['name'];
          _userEmail = userData['email'];
          _isLoading = false;
        });
        print('State updated with: $_userName, $_userEmail');
      } else {
        print('User data is NULL');
        setState(() {
          _userName = 'Guest User';
          _userEmail = 'guest@example.com';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user: $e');
      setState(() {
        _userName = 'Error loading user';
        _isLoading = false;
      });
    }

    print('=========================');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0066CC),
        foregroundColor: Colors.white,
        title: const Text('Profil Saya', style: TextStyle(color: Colors.white)),
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Bagian atas kartu profil
                  Container(
                    width: double.infinity,
                    color: const Color(0xFF0066CC),
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Nama dan tombol ubah
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      _userName,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0066CC),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // Implementasi edit profile
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Fitur edit profil coming soon!',
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Ubah',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _userEmail,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bagian menu Kesehatan
                  // Bagian menu Kesehatan
                  buildSectionTitle('Tingkatkan Kesehatanmu'),
                  buildMenuItem(
                    icon: Icons.alarm,
                    title: 'Pengingat Skincare Harian',
                    subtitle: 'Pengingat untuk perawatan kulit tepat waktu.',
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/reminder',
                    ), // ⬅️ ini yang menavigasi
                  ),
                ],
              ),
            ),
    );
  }

  // Widget pembantu untuk judul bagian
  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Widget pembantu untuk item menu
  Widget buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.red[50],
        child: Icon(icon, color: Colors.red),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
