// Model data Produk
class Product {
  final String? id;
  final String nama;
  final String deskripsi;
  final double harga;
  final int stok;
  final String gambar;

  Product({
    this.id,
    required this.nama,
    required this.deskripsi,
    required this.harga,
    required this.stok,
    required this.gambar,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString(),
      nama: json['nama'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      harga: (json['harga'] is num) ? (json['harga'] as num).toDouble() : 0,
      stok: (json['stok'] is num) ? (json['stok'] as num).toInt() : 0,
      gambar: json['gambar'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'deskripsi': deskripsi,
      'harga': harga,
      'stok': stok,
      'gambar': gambar,
    };
  }
}
