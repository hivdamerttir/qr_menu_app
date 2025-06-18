import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../models/order.dart';
import '../models/restaurant.dart';

class CartScreen extends StatefulWidget {
  final Restaurant restaurant;

  const CartScreen({super.key, required this.restaurant});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardHolderController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardHolderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sepetim')),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.items.isEmpty) {
            return const Center(child: Text('Sepetiniz boş'));
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return _buildCartItem(context, cart, item);
                  },
                ),
                _buildPaymentSection(context, cart),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCartItem(
    BuildContext context,
    CartProvider cart,
    OrderItem item,
  ) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        title: Text(item.name),
        subtitle: item.note != null ? Text('Not: ${item.note}') : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () {
                cart.updateQuantity(item.menuItemId, item.quantity - 1);
              },
            ),
            Text('${item.quantity}'),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                cart.updateQuantity(item.menuItemId, item.quantity + 1);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                cart.removeFromCart(item.menuItemId);
              },
            ),
          ],
        ),
        onTap: () => _showNoteDialog(context, cart, item),
      ),
    );
  }

  Widget _buildPaymentSection(BuildContext context, CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Masa Numarası',
              border: OutlineInputBorder(),
              hintText: 'Örn: 5',
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                cart.setRestaurantInfo(widget.restaurant.id, value);
              }
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'Ödeme Bilgileri',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _cardNumberController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Kart Numarası',
              border: OutlineInputBorder(),
              hintText: 'XXXX XXXX XXXX XXXX',
            ),
            maxLength: 16,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _expiryController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Son Kullanma',
                    border: OutlineInputBorder(),
                    hintText: 'AA/YY',
                  ),
                  maxLength: 5,
                  onChanged: _formatExpiryDate,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _cvvController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'CVV',
                    border: OutlineInputBorder(),
                    hintText: '***',
                  ),
                  maxLength: 3,
                  obscureText: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _cardHolderController,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'Kart Üzerindeki İsim',
              border: OutlineInputBorder(),
              hintText: 'AD SOYAD',
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Toplam: ₺${cart.totalAmount.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _submitOrder(context),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
            ),
            child: const Text('Siparişi Onayla'),
          ),
        ],
      ),
    );
  }

  void _formatExpiryDate(String value) {
    if (value.length == 2 && !value.contains('/')) {
      _expiryController.text = '$value/';
      _expiryController.selection = TextSelection.fromPosition(
        TextPosition(offset: _expiryController.text.length),
      );
    }
  }

  void _showNoteDialog(
    BuildContext context,
    CartProvider cart,
    OrderItem item,
  ) {
    final controller = TextEditingController(text: item.note);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sipariş Notu'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Örn: Az pişmiş, acısız vb.',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              cart.addNote(item.menuItemId, controller.text);
              Navigator.pop(context);
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitOrder(BuildContext context) async {
    final cart = context.read<CartProvider>();

    // Masa numarası kontrolü
    if (cart.restaurantId == null ||
        cart.tableNumber == null ||
        cart.tableNumber!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen masa numarasını giriniz')),
      );
      return;
    }

    final expiryDate = _expiryController.text;
    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(expiryDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Geçerli bir son kullanma tarihi giriniz (AA/YY)'),
        ),
      );
      return;
    }

    // Tarih kontrolü
    final parts = expiryDate.split('/');
    final month = int.parse(parts[0]);
    final year = int.parse(parts[1]) + 2000;
    final now = DateTime.now();
    if (year < now.year || (year == now.year && month < now.month)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kartınızın son kullanma tarihi geçmiş')),
      );
      return;
    }

    if (_cvvController.text.length != 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geçerli bir CVV numarası giriniz')),
      );
      return;
    }

    if (_cardHolderController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kart üzerindeki ismi giriniz')),
      );
      return;
    }

    // Önce toplam tutarı al
    final totalAmount = cart.totalAmount;

    // Form alanlarını temizle
    _cardNumberController.clear();
    _expiryController.clear();
    _cvvController.clear();
    _cardHolderController.clear();

    // Sepeti temizle
    cart.clear();

    if (!context.mounted) return;

    // Başarı mesajını dialog olarak göster
    await showDialog(
      context: context,
      barrierDismissible: false, // Dışarı tıklayarak kapanmasın
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 30),
              const SizedBox(width: 10),
              const Text('Başarılı'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Siparişiniz başarıyla alındı.'),
              const SizedBox(height: 8),
              Text(
                'Toplam Tutar: ₺${totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dialog'u kapat
                Navigator.of(context).pop(); // Ana sayfaya dön
              },
              child: const Text('Tamam'),
            ),
          ],
        );
      },
    );
  }
}
