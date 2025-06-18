import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/menu_item.dart';
import '../models/restaurant.dart';
import '../models/order.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Restaurant operations
  Future<Restaurant> getRestaurantById(String id) async {
    try {
      final doc = await _firestore.collection('restaurants').doc(id).get();
      if (!doc.exists) {
        throw Exception('Restaurant not found');
      }
      return Restaurant.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      print('Error getting restaurant: $e');
      throw Exception('Failed to get restaurant: $e');
    }
  }

  Future<List<MenuItem>> getMenuItems(String restaurantId) async {
    print('GetMenuItems çağrıldı. Restaurant ID: $restaurantId');
    final querySnapshot = await _firestore
        .collection('restaurants')
        .doc(restaurantId)
        .collection('menuItems')
        .orderBy(FieldPath.documentId) // Döküman ID'sine göre sıralama
        .limit(50) // Yüksek bir limit belirliyoruz
        .get();

    print('Toplam döküman sayısı: ${querySnapshot.docs.length}');
    final items = querySnapshot.docs.map((doc) {
      print('Döküman okunuyor - ID: ${doc.id}');
      return MenuItem.fromJson({...doc.data(), 'id': doc.id});
    }).toList();
    print('Dönüştürülen öğe sayısı: ${items.length}');
    return items;
  }

  Stream<List<MenuItem>> streamMenuItems(String restaurantId) {
    print('==================== MENU ITEMS STREAM ====================');
    print('Restaurant ID: $restaurantId');

    final collectionRef = _firestore
        .collection('restaurants')
        .doc(restaurantId)
        .collection('menuItems');

    print('Collection path: ${collectionRef.path}');

    // Tüm dökümanları almak için hiçbir sınırlama olmadan sorgu yapıyoruz
    return collectionRef
        .orderBy('name') // İsme göre sıralayalım
        .snapshots()
        .map((snapshot) {
          print('\n----------------- SNAPSHOT UPDATE -----------------');
          print('Snapshot metadata: ${snapshot.metadata}');
          print('Toplam döküman sayısı: ${snapshot.docs.length}');

          List<MenuItem> items = [];
          for (var doc in snapshot.docs) {
            try {
              print('\nDöküman bilgileri:');
              print('ID: ${doc.id}');
              print('Data: ${doc.data()}');

              // Her bir dökümanın dönüşümünü ayrı try-catch bloğunda yapıyoruz
              final item = MenuItem.fromJson({...doc.data(), 'id': doc.id});
              items.add(item);
            } catch (e) {
              print(
                'Hata: Döküman dönüştürülürken hata oluştu - ${doc.id}: $e',
              );
            }
          }

          print('\nDönüştürülen toplam öğe sayısı: ${items.length}');
          print('Dönüştürülen öğeler:');
          items.forEach((item) {
            print(
              '- ${item.name} (ID: ${item.id}, Kategori: ${item.category})',
            );
          });
          print('====================================================\n');

          return items;
        });
  }

  // Order operations
  Future<OrderModel> createOrder(OrderModel order) async {
    final doc = await _firestore.collection('orders').add(order.toJson());
    return order.copyWith(id: doc.id);
  }

  Future<List<OrderModel>> getOrdersForRestaurant(String restaurantId) async {
    try {
      final QuerySnapshot ordersSnapshot = await _firestore
          .collection('orders')
          .where('restaurantId', isEqualTo: restaurantId)
          .orderBy('createdAt', descending: true)
          .get();

      return ordersSnapshot.docs
          .map((doc) => OrderModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching orders: $e');
      return [];
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': status,
    });
  }
}
