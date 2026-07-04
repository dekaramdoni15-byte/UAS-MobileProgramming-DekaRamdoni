  import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

// PENTING: Ganti IP di bawah ini dengan IP Address laptop kamu
// yang menjalankan server Node.js (backend).
// Cara cek IP laptop:
//  - Windows: buka cmd, ketik "ipconfig", lihat "IPv4 Address"
//  - Mac/Linux: buka terminal, ketik "ifconfig" atau "ip addr"
// Pastikan HP/emulator dan laptop terhubung ke WiFi yang SAMA.
class ProductService {
static const String baseUrl = "http://localhost:3000/api/products";
  // GET semua produk
  Future<List<Product>> getProducts() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List data = body['data'];
      return data.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Gagal mengambil data produk');
    }
  }

  // POST tambah produk baru
  Future<Product> addProduct(Product product) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product.toJson()),
    );

    if (response.statusCode == 201) {
      final body = jsonDecode(response.body);
      return Product.fromJson(body['data']);
    } else {
      throw Exception('Gagal menambah produk');
    }
  }

  // PUT update produk
  Future<Product> updateProduct(String id, Product product) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product.toJson()),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return Product.fromJson(body['data']);
    } else {
      throw Exception('Gagal mengupdate produk');
    }
  }

  // DELETE produk
  Future<void> deleteProduct(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));

    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus produk');
    }
  }
}
