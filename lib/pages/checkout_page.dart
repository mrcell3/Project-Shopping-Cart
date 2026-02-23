import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart_model.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey     = GlobalKey<FormState>();
  final _nameCtrl    = TextEditingController();
  final _phoneCtrl   = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _noteCtrl    = TextEditingController();

  String _paymentMethod = '🏦 Transfer Bank';
  bool _isOrdering = false;

  final List<String> _paymentOptions = [
    '🏦 Transfer Bank',
    '💵 COD (Bayar di Tempat)',
    '📱 QRIS',
    '💳 Kartu Kredit',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _placeOrder(CartModel cart) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isOrdering = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    cart.clear();
    setState(() => _isOrdering = false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 12),
            const Text('Pesanan Berhasil!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Halo ${_nameCtrl.text}, pesananmu sedang diproses.\nMetode: $_paymentMethod',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context)
                ..pop()
                ..pop()
                ..pop(),
              child: const Text('Kembali Belanja'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartModel>(
      builder: (context, cart, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Checkout')),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── Order Summary ──────────────────────────────────
                _SectionCard(
                  title: '🛍️ Ringkasan Pesanan',
                  child: Column(
                    children: [
                      ...cart.itemsList.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Text(item.product.emoji, style: const TextStyle(fontSize: 24)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.product.name,
                                      style: const TextStyle(fontWeight: FontWeight.w600)),
                                  Text(
                                    '${item.quantity}x  •  ${CartModel.formatRupiah(item.product.price)}',
                                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Text(CartModel.formatRupiah(item.totalPrice),
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(
                            CartModel.formatRupiah(cart.totalPrice),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('${cart.totalQuantity} item',
                            style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Data Penerima ──────────────────────────────────
                _SectionCard(
                  title: '👤 Data Penerima',
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Nama Lengkap *',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Nomor HP *',
                          prefixIcon: Icon(Icons.phone_outlined),
                          hintText: '08xxxxxxxxxx',
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Nomor HP wajib diisi';
                          if (v.trim().length < 9) return 'Nomor HP tidak valid';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _addressCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Alamat Pengiriman *',
                          prefixIcon: Icon(Icons.location_on_outlined),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 3,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Alamat wajib diisi' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _noteCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Catatan (opsional)',
                          prefixIcon: Icon(Icons.note_outlined),
                          hintText: 'Contoh: Titip di depan pintu',
                          alignLabelWithHint: true,
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Metode Pembayaran ──────────────────────────────
                _SectionCard(
                  title: '💳 Metode Pembayaran',
                  child: Column(
                    children: _paymentOptions.map((option) => RadioListTile<String>(
                      title: Text(option),
                      value: option,
                      groupValue: _paymentMethod,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) => setState(() => _paymentMethod = val!),
                    )).toList(),
                  ),
                ),

                const SizedBox(height: 24),

                // ── Tombol Order ───────────────────────────────────
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isOrdering ? null : () => _placeOrder(cart),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isOrdering
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20, height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              ),
                              SizedBox(width: 12),
                              Text('Memproses...'),
                            ],
                          )
                        : Text(
                            'Pesan Sekarang  •  ${CartModel.formatRupiah(cart.totalPrice)}',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}