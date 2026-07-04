import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import 'product_form_screen.dart';

// Materi: ListView (Pertemuan 5) + Context Menu (Pertemuan 12) + REST API (Pertemuan 11)
class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _service = ProductService();
  late Future<List<Product>> _futureProducts;
  final _searchController = TextEditingController();
  String _query = '';

  static const _purple = Color(0xFF6D28D9);

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadProducts() {
    setState(() {
      _futureProducts = _service.getProducts();
    });
  }

  Future<void> _deleteProduct(Product product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Produk'),
        content: Text('Yakin ingin menghapus "${product.nama}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _service.deleteProduct(product.id!);
        _loadProducts();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Produk dihapus'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menghapus: $e')),
          );
        }
      }
    }
  }

  void _goToForm({Product? product}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProductFormScreen(product: product)),
    );

    if (result == true) {
      _loadProducts();
    }
  }

  List<Product> _filter(List<Product> products) {
    if (_query.isEmpty) return products;
    final q = _query.toLowerCase();
    return products.where((p) => p.nama.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F5FA),
      body: RefreshIndicator(
        color: _purple,
        onRefresh: () async => _loadProducts(),
        child: FutureBuilder<List<Product>>(
          future: _futureProducts,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: _purple));
            }
            if (snapshot.hasError) {
              return ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
                    child: Column(
                      children: [
                        Icon(Icons.wifi_off_rounded, size: 56, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        const Text(
                          'Gagal memuat data',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Pastikan server backend menyala dan IP di product_service.dart sudah benar.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _loadProducts,
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('Coba Lagi'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _purple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            final allProducts = snapshot.data ?? [];
            final products = _filter(allProducts);

            final totalStok = allProducts.fold<int>(0, (sum, p) => sum + p.stok);
            final totalNilai = allProducts.fold<double>(0, (sum, p) => sum + (p.harga * p.stok));

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Column(
                      children: [
                        // Search bar
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) => setState(() => _query = value),
                            decoration: InputDecoration(
                              hintText: 'Cari produk...',
                              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                              prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                              suffixIcon: _query.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(Icons.close, color: Colors.grey[400], size: 18),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() => _query = '');
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Summary cards
                        Row(
                          children: [
                            Expanded(
                              child: _summaryCard(
                                icon: Icons.inventory_2_outlined,
                                label: 'Total Produk',
                                value: '${allProducts.length}',
                                color: _purple,
                                bg: const Color(0xFFF3E8FF),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _summaryCard(
                                icon: Icons.layers_outlined,
                                label: 'Total Stok',
                                value: '$totalStok',
                                color: const Color(0xFF16A34A),
                                bg: const Color(0xFFF0FDF4),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _summaryCard(
                          icon: Icons.payments_outlined,
                          label: 'Total Nilai Stok',
                          value: 'Rp ${totalNilai.toStringAsFixed(0)}',
                          color: const Color(0xFFEA580C),
                          bg: const Color(0xFFFFF7ED),
                          wide: true,
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
                if (products.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _query.isEmpty ? Icons.inventory_2_outlined : Icons.search_off,
                            size: 64,
                            color: Colors.grey[350],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _query.isEmpty ? 'Belum ada produk' : 'Produk tidak ditemukan',
                            style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _query.isEmpty ? 'Tekan tombol + untuk menambah' : 'Coba kata kunci lain',
                            style: TextStyle(color: Colors.grey[400], fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _AnimatedItem(
                          index: index,
                          child: _buildProductCard(products[index]),
                        ),
                        childCount: products.length,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [_purple, Color(0xFFA855F7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: _purple.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => _goToForm(),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color bg,
    bool wide = false,
  }) {
    return Container(
      width: wide ? double.infinity : null,
      padding: const EdgeInsets.all(14),
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
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    final stok = product.stok;
    final stokColor = stok == 0
        ? Colors.red
        : stok < 5
            ? Colors.orange
            : Colors.green;
    final stokBg = stok == 0
        ? const Color(0xFFFEE2E2)
        : stok < 5
            ? const Color(0xFFFFF7ED)
            : const Color(0xFFF0FDF4);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _goToForm(product: product),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: product.gambar.isNotEmpty
                      ? Image.network(
                          product.gambar,
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholderImage(),
                        )
                      : _placeholderImage(),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.nama,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        product.deskripsi,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            'Rp ${product.harga.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: _purple,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: stokBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Stok: $stok',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: stokColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.grey[400]),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _goToForm(product: product);
                    } else if (value == 'hapus') {
                      _deleteProduct(product);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit_outlined, size: 20),
                        title: Text('Edit'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'hapus',
                      child: ListTile(
                        leading: Icon(Icons.delete_outline, size: 20, color: Colors.red),
                        title: Text('Hapus', style: TextStyle(color: Colors.red)),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      width: 72,
      height: 72,
      color: const Color(0xFFF3E8FF),
      child: const Icon(Icons.inventory_2_outlined, color: _purple),
    );
  }
}

// Widget pembungkus untuk animasi fade + slide saat item muncul
class _AnimatedItem extends StatefulWidget {
  final int index;
  final Widget child;
  const _AnimatedItem({required this.index, required this.child});

  @override
  State<_AnimatedItem> createState() => _AnimatedItemState();
}

class _AnimatedItemState extends State<_AnimatedItem> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: 40 * widget.index), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
