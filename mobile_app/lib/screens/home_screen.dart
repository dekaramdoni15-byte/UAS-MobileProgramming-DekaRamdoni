import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import '../services/product_service.dart';
import 'product_list_screen.dart';

// Materi: TabLayout dan ViewPage (Pertemuan 10)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F5FA),
        appBar: AppBar(
          toolbarHeight: 80,
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF6D28D9), Color(0xFFA855F7)],
              ),
            ),
          ),
          title: const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Katalog Produk',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Kelola produkmu dengan mudah',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(52),
            child: Container(
              color: const Color(0xFF6D28D9),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TabBar(
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorPadding: const EdgeInsets.all(4),
                  labelColor: const Color(0xFF6D28D9),
                  unselectedLabelColor: Colors.white,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(icon: Icon(Icons.inventory_2_outlined, size: 18), text: 'Produk'),
                    Tab(icon: Icon(Icons.person_outline, size: 18), text: 'Profil'),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            const ProductListScreen(),
            _ProfileTab(user: user),
          ],
        ),
      ),
    );
  }
}

class _ProfileTab extends StatefulWidget {
  final User? user;
  const _ProfileTab({required this.user});

  @override
  State<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab> {
  final _productService = ProductService();
  int? _totalProduk;
  Uint8List? _photoBytes;

  static const _purple = Color(0xFF6D28D9);
  static const _bulan = [
    '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final products = await _productService.getProducts();
      if (mounted) setState(() => _totalProduk = products.length);
    } catch (_) {
      if (mounted) setState(() => _totalProduk = 0);
    }
  }

  Future<void> _pickPhoto() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() => _photoBytes = bytes);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih foto: $e')),
        );
      }
    }
  }

  String _getInitials(String? name, String? email) {
    if (name != null && name.isNotEmpty) {
      final parts = name.trim().split(' ');
      if (parts.length >= 2) {
        return (parts[0][0] + parts[1][0]).toUpperCase();
      }
      return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
    }
    if (email != null && email.isNotEmpty) {
      return email.substring(0, email.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '?';
  }

  String _formatTanggal(DateTime? date) {
    if (date == null) return '-';
    return '${date.day} ${_bulan[date.month]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final displayName = user?.displayName ?? user?.email?.split('@').first ?? 'User';
    final joinDate = user?.metadata.creationTime;

    return Container(
      color: const Color(0xFFF6F5FA),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Header gradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF6D28D9), Color(0xFFA855F7)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6D28D9).withOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 92,
                        height: 92,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.2),
                          border: Border.all(color: Colors.white, width: 3),
                          image: _photoBytes != null
                              ? DecorationImage(
                                  image: MemoryImage(_photoBytes!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _photoBytes == null
                            ? Center(
                                child: Text(
                                  _getInitials(user?.displayName, user?.email),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: -2,
                        right: -2,
                        child: GestureDetector(
                          onTap: _pickPhoto,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.camera_alt, size: 16, color: _purple),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '-',
                    style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.85)),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified, size: 16, color: Colors.white),
                        SizedBox(width: 6),
                        Text(
                          'Akun Terverifikasi',
                          style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Statistik
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    icon: Icons.inventory_2_outlined,
                    label: 'Total Produk',
                    value: _totalProduk == null ? '...' : '$_totalProduk',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _statCard(
                    icon: Icons.calendar_today_outlined,
                    label: 'Bergabung Sejak',
                    value: _formatTanggal(joinDate),
                    small: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Info card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _infoTile(Icons.email_outlined, 'Email', user?.email ?? '-'),
                  Divider(height: 1, indent: 60, color: Colors.grey.shade200),
                  _infoTile(Icons.badge_outlined, 'Nama Pengguna', displayName),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Logout
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Logout', style: TextStyle(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFEE2E2),
                  foregroundColor: const Color(0xFFDC2626),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: () async {
                  await AuthService().logout();
                  // StreamBuilder di main.dart otomatis kembali ke LoginScreen
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard({required IconData icon, required String label, required String value, bool small = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF3E8FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _purple, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(fontSize: small ? 13 : 18, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFF3E8FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: _purple, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}