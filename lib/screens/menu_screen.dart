import 'package:flutter/material.dart';
import '../models/restaurant.dart';
import '../models/menu_item.dart';
import '../services/firebase_service.dart';
import '../providers/cart_provider.dart';
import 'package:provider/provider.dart';
import '../widgets/menu_item_card.dart';
import './cart_screen.dart';

class MenuScreen extends StatefulWidget {
  final Restaurant restaurant;

  const MenuScreen({super.key, required this.restaurant});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  late Stream<List<MenuItem>> _menuItemsStream;

  @override
  void initState() {
    super.initState();
    print('MenuScreen initState - Restaurant ID: ${widget.restaurant.id}');
    _menuItemsStream = FirebaseService().streamMenuItems(widget.restaurant.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: SizedBox(
          child: Image.asset(
            'assets/images/leziz_logo.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Text('Leziz');
            },
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          CartScreen(restaurant: widget.restaurant),
                    ),
                  );
                },
              ),
              Consumer<CartProvider>(
                builder: (context, cart, child) {
                  if (cart.items.isEmpty) return const SizedBox.shrink();
                  return Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        cart.items.length.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<MenuItem>>(
        stream: _menuItemsStream,
        builder: (context, snapshot) {
          print(
            'StreamBuilder update - ConnectionState: ${snapshot.connectionState}',
          );

          if (snapshot.hasError) {
            print('StreamBuilder error: ${snapshot.error}');
            return Center(child: Text('Hata: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            print('StreamBuilder waiting for data...');
            return const Center(child: CircularProgressIndicator());
          }

          final menuItems = snapshot.data ?? [];
          print('Alınan menü öğesi sayısı: ${menuItems.length}');
          menuItems.forEach((item) {
            print(
              'Menü öğesi: ID=${item.id}, Name=${item.name}, Category=${item.category}',
            );
          });

          return DefaultTabController(
            length: widget.restaurant.categories.length,
            child: Column(
              children: [
                TabBar(
                  isScrollable: true,
                  tabs: widget.restaurant.categories
                      .map((category) => Tab(text: category))
                      .toList(),
                ),
                Expanded(
                  child: TabBarView(
                    children: widget.restaurant.categories.map((category) {
                      final categoryItems = menuItems
                          .where((item) => item.category == category)
                          .toList();

                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                        itemCount: categoryItems.length,
                        itemBuilder: (context, index) {
                          final menuItem = categoryItems[index];
                          return MenuItemCard(
                            menuItem: menuItem,
                            onAddToCart: () {
                              context.read<CartProvider>().addToCart(menuItem);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Ürün sepete eklendi'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
