// server.js
// REST API sederhana untuk CRUD data produk
// UAS Mobile Programming - Materi: HTTP/API Integration (Pertemuan 11)

const express = require("express");
const cors = require("cors");
const fs = require("fs");
const path = require("path");

const app = express();
const PORT = 3000;
const DB_FILE = path.join(__dirname, "products.json");

app.use(cors()); // supaya bisa diakses dari Flutter (device berbeda dalam satu jaringan)
app.use(express.json()); // parsing body JSON

// ---------- Helper: baca & tulis "database" JSON ----------
function readProducts() {
  if (!fs.existsSync(DB_FILE)) {
    fs.writeFileSync(DB_FILE, JSON.stringify([], null, 2));
  }
  const data = fs.readFileSync(DB_FILE, "utf-8");
  return JSON.parse(data);
}

function writeProducts(products) {
  fs.writeFileSync(DB_FILE, JSON.stringify(products, null, 2));
}

// ---------- ROUTES ----------

// GET /api/products -> ambil semua produk
app.get("/api/products", (req, res) => {
  const products = readProducts();
  res.json({ success: true, data: products });
});

// GET /api/products/:id -> ambil satu produk
app.get("/api/products/:id", (req, res) => {
  const products = readProducts();
  const product = products.find((p) => p.id === req.params.id);
  if (!product) {
    return res.status(404).json({ success: false, message: "Produk tidak ditemukan" });
  }
  res.json({ success: true, data: product });
});

// POST /api/products -> tambah produk baru
app.post("/api/products", (req, res) => {
  const { nama, deskripsi, harga, stok, gambar } = req.body;

  if (!nama || harga === undefined) {
    return res.status(400).json({ success: false, message: "Nama dan harga wajib diisi" });
  }

  const products = readProducts();
  const newProduct = {
    id: Date.now().toString(),
    nama,
    deskripsi: deskripsi || "",
    harga: Number(harga),
    stok: Number(stok) || 0,
    gambar: gambar || "",
  };

  products.push(newProduct);
  writeProducts(products);

  res.status(201).json({ success: true, data: newProduct });
});

// PUT /api/products/:id -> update produk
app.put("/api/products/:id", (req, res) => {
  const products = readProducts();
  const index = products.findIndex((p) => p.id === req.params.id);

  if (index === -1) {
    return res.status(404).json({ success: false, message: "Produk tidak ditemukan" });
  }

  const { nama, deskripsi, harga, stok, gambar } = req.body;
  products[index] = {
    ...products[index],
    nama: nama ?? products[index].nama,
    deskripsi: deskripsi ?? products[index].deskripsi,
    harga: harga !== undefined ? Number(harga) : products[index].harga,
    stok: stok !== undefined ? Number(stok) : products[index].stok,
    gambar: gambar ?? products[index].gambar,
  };

  writeProducts(products);
  res.json({ success: true, data: products[index] });
});

// DELETE /api/products/:id -> hapus produk
app.delete("/api/products/:id", (req, res) => {
  const products = readProducts();
  const index = products.findIndex((p) => p.id === req.params.id);

  if (index === -1) {
    return res.status(404).json({ success: false, message: "Produk tidak ditemukan" });
  }

  const deleted = products.splice(index, 1);
  writeProducts(products);

  res.json({ success: true, data: deleted[0] });
});

// Root endpoint - cek server hidup
app.get("/", (req, res) => {
  res.send("REST API Katalog Produk aktif. Coba akses /api/products");
});

// Listen di semua network interface (0.0.0.0) supaya bisa diakses HP/emulator
// lewat IP address laptop, selama satu jaringan WiFi yang sama.
app.listen(PORT, "0.0.0.0", () => {
  console.log(`Server berjalan di http://0.0.0.0:${PORT}`);
  console.log(`Akses dari HP/emulator: http://<IP_LAPTOP_KAMU>:${PORT}/api/products`);
});
