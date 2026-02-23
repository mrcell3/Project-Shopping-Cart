import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../models/cart_model.dart';
import 'cart_page.dart';

// StatelessWidget → StatefulWidget
class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  // ── State baru untuk search & filter ──
  String _searchQuery = '';
  String _selectedCategory = 'All';
  final _searchController = TextEditingController();

  // ── Products dipindah jadi field, tambah category ──
  final _products = [
    Product(id: '1', name: 'Laptop Gaming',      price: 15000000, emoji: '💻', description: 'Laptop gaming performa tinggi',    category: 'Komputer'),
    Product(id: '2', name: 'Smartphone Pro',      price: 8000000,  emoji: '📱', description: 'Smartphone flagship terbaru',      category: 'Handphone'),
    Product(id: '3', name: 'Wireless Headphones', price: 1500000,  emoji: '🎧', description: 'Headphones noise-cancelling',      category: 'Audio'),
    Product(id: '4', name: 'Smart Watch',         price: 3000000,  emoji: '⌚', description: 'Smartwatch dengan health tracking', category: 'Wearable'),
    Product(id: '5', name: 'Camera DSLR',         price: 12000000, emoji: '📷', description: 'Kamera DSLR profesional',          category: 'Kamera'),
    Product(id: '6', name: 'Tablet Pro',          price: 7000000,  emoji: '📟', description: 'Tablet untuk produktivitas',       category: 'Komputer'),
  ];

  // ── Getter categories & filtered ──
  List<String> get _categories {
    final cats = _products.map((p) => p.category).toSet().toList()..sort();
    return ['All', ...cats];
  }

  List<Product> get _filtered => _products.where((p) {
    final matchSearch   = p.name.toLowerCase().contains(_searchQuery.toLowerCase());
    final matchCategory = _selectedCategory == 'All' || p.category == _selectedCategory;
    return matchSearch && matchCategory;
  }).toList();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          // Cart badge — TIDAK BERUBAH
          Consumer<CartModel>(
            builder: (context, cart, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CartPage(),
                        ),
                      );
                    },
                  ),
                  if (cart.itemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${cart.itemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      // ── body: bungkus dengan Column, sisipkan Search & Chips ──
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari produk...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
          // Category Chips
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => ChoiceChip(
                label: Text(_categories[i]),
                selected: _selectedCategory == _categories[i],
                onSelected: (_) => setState(() => _selectedCategory = _categories[i]),
              ),
            ),
          ),
          // GridView dibungkus Expanded — isi TIDAK BERUBAH kecuali 2 baris
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _filtered.length,        // ← products.length → _filtered.length
              itemBuilder: (context, index) {
                final product = _filtered[index]; // ← products[index] → _filtered[index]
                return Card(
                  elevation: 3,
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          color: Colors.deepPurple.shade50,
                          child: Center(
                            child: Text(
                              product.emoji,
                              style: const TextStyle(fontSize: 64),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          children: [
                            Text(
                              product.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              CartModel.formatRupiah(product.price),
                              style: TextStyle(
                                color: Colors.green[700],
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  context.read<CartModel>().addItem(product);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${product.name} ditambahkan ke cart!'),
                                      duration: const Duration(seconds: 1),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.add_shopping_cart, size: 16),
                                label: const Text('Add', style: TextStyle(fontSize: 12)),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}