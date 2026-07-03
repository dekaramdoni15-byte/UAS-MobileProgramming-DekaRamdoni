import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';

// Materi: Form & Validasi Input + REST API (POST/PUT)
class ProductFormScreen extends StatefulWidget {
  final Product? product; // null = mode tambah, ada isinya = mode edit

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _deskripsiController;
  late TextEditingController _hargaController;
  late TextEditingController _stokController;
  late TextEditingController _gambarController;

  final _service = ProductService();
  bool _isLoading = false;

  bool get isEditMode => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _namaController = TextEditingController(text: p?.nama ?? '');
    _deskripsiController = TextEditingController(text: p?.deskripsi ?? '');
    _hargaController = TextEditingController(text: p != null ? p.harga.toStringAsFixed(0) : '');
    _stokController = TextEditingController(text: p != null ? p.stok.toString() : '');
    _gambarController = TextEditingController(text: p?.gambar ?? '');
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final product = Product(
      nama: _namaController.text.trim(),
      deskripsi: _deskripsiController.text.trim(),
      harga: double.tryParse(_hargaController.text.trim()) ?? 0,
      stok: int.tryParse(_stokController.text.trim()) ?? 0,
      gambar: _gambarController.text.trim(),
    );

    try {
      if (isEditMode) {
        await _service.updateProduct(widget.product!.id!, product);
      } else {
        await _service.addProduct(product);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEditMode ? 'Edit Produk' : 'Tambah Produk')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: 'Nama Produk', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.isEmpty) ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _deskripsiController,
                decoration: const InputDecoration(labelText: 'Deskripsi', border: OutlineInputBorder()),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _hargaController,
                decoration: const InputDecoration(labelText: 'Harga', border: OutlineInputBorder(), prefixText: 'Rp '),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Harga wajib diisi';
                  if (double.tryParse(v) == null) return 'Harga harus berupa angka';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _stokController,
                decoration: const InputDecoration(labelText: 'Stok', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Stok wajib diisi';
                  if (int.tryParse(v) == null) return 'Stok harus berupa angka bulat';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _gambarController,
                decoration: const InputDecoration(
                  labelText: 'URL Gambar (opsional)',
                  border: OutlineInputBorder(),
                  hintText: 'https://...',
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(isEditMode ? 'Simpan Perubahan' : 'Tambah Produk'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
