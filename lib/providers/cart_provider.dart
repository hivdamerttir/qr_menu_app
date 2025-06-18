import 'package:flutter/foundation.dart';
import '../models/menu_item.dart';
import '../models/order.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, OrderItem> _items = {};
  String? restaurantId;
  String? tableNumber;

  List<OrderItem> get items => _items.values.toList();

  double get totalAmount {
    return _items.values.fold(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );
  }

  void setRestaurantInfo(String restId, String tableNum) {
    restaurantId = restId;
    tableNumber = tableNum;
    notifyListeners();
  }
  void addToCart(MenuItem menuItem) {
    // Create a unique cart item ID combining menu item ID and current timestamp
    final cartItemId = '${menuItem.id}_${DateTime.now().millisecondsSinceEpoch}';
    
    _items[cartItemId] = OrderItem(
      menuItemId: menuItem.id,
      name: menuItem.name,
      quantity: 1,
      price: menuItem.price,
    );
    notifyListeners();
  }

  void removeFromCart(String menuItemId) {
    _items.remove(menuItemId);
    notifyListeners();
  }

  void updateQuantity(String menuItemId, int quantity) {
    if (quantity <= 0) {
      _items.remove(menuItemId);
    } else {
      final item = _items[menuItemId];
      if (item != null) {
        _items[menuItemId] = OrderItem(
          menuItemId: item.menuItemId,
          name: item.name,
          quantity: quantity,
          price: item.price,
          note: item.note,
        );
      }
    }
    notifyListeners();
  }

  void addNote(String menuItemId, String note) {
    final item = _items[menuItemId];
    if (item != null) {
      _items[menuItemId] = OrderItem(
        menuItemId: item.menuItemId,
        name: item.name,
        quantity: item.quantity,
        price: item.price,
        note: note,
      );
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
