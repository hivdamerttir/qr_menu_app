import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String restaurantId;
  final String tableNumber;
  final List<OrderItem> items;
  final DateTime createdAt;
  final String
  status; // 'pending', 'preparing', 'ready', 'delivered', 'cancelled'
  final double totalAmount;
  final Map<String, dynamic>? paymentInfo;

  OrderModel({
    required this.id,
    required this.restaurantId,
    required this.tableNumber,
    required this.items,
    required this.createdAt,
    required this.status,
    required this.totalAmount,
    this.paymentInfo,
  });

  OrderModel copyWith({
    String? id,
    String? restaurantId,
    String? tableNumber,
    List<OrderItem>? items,
    DateTime? createdAt,
    String? status,
    double? totalAmount,
    Map<String, dynamic>? paymentInfo,
  }) {
    return OrderModel(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      tableNumber: tableNumber ?? this.tableNumber,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentInfo: paymentInfo ?? this.paymentInfo,
    );
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      restaurantId: json['restaurantId'] as String,
      tableNumber: json['tableNumber'] as String,
      items: (json['items'] as List<dynamic>)
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      status: json['status'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      paymentInfo: json['paymentInfo'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurantId': restaurantId,
      'tableNumber': tableNumber,
      'items': items.map((item) => item.toJson()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status,
      'totalAmount': totalAmount,
      if (paymentInfo != null) 'paymentInfo': paymentInfo,
    };
  }
}

class OrderItem {
  final String menuItemId;
  final String name;
  final double price;
  final int quantity;
  final String? note;

  OrderItem({
    required this.menuItemId,
    required this.name,
    required this.price,
    required this.quantity,
    this.note,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      menuItemId: json['menuItemId'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'menuItemId': menuItemId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'note': note,
    };
  }

  double get totalPrice => price * quantity;
}
