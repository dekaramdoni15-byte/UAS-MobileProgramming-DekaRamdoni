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

  @override
  void initState() {
    super.initState();
    _loadProducts();
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
        title: const Text('Hapus Produk'),
        content: Text('Yakin ingin menghapus "${product.nama}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _service.deleteProduct(product.id!);
        _loadProducts();
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Produk dihapus')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Gagal menghapus: $e')));
        }
      }
    }
  }

  void _goToForm({Product? product}) async {
    // Materi: Navigator (dipakai untuk pindah ke form tambah/edit)
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProductFormScreen(product: product)),
    );

    if (result == true) {
      _loadProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => _loadProducts(),
        child: FutureBuilder<List<Product>>(
          future: _futureProducts,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Gagal memuat data.\nPastikan server backend menyala dan IP di product_service.dart sudah benar.\n\nError: ${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final products = snapshot.data ?? [];
            if (products.isEmpty) {
              return const Center(child: Text('Belum ada produk. Tekan + untuk menambah.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(8),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: product.gambar.isNotEmpty
                          ? Image.network(
                              product.gambar,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.image_not_supported, size: 56),
                            )
                          : const Icon(Icons.inventory_2, size: 56),
                    ),
                    title: Text(product.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      '${product.deskripsi}\nRp ${product.harga.toStringAsFixed(0)} • Stok: ${product.stok}',
                    ),
                    isThreeLine: true,
                    // Materi: Context Menu (Pertemuan 12)
                    trailing: PopupMenuButton<String>(
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
                          child: ListTile(leading: Icon(Icons.edit), title: Text('Edit')),
                        ),
                        const PopupMenuItem(
                          value: 'hapus',
                          child: ListTile(leading: Icon(Icons.delete), title: Text('Hapus')),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _goToForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
