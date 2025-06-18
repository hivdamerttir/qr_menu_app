class Restaurant {
  final String id;
  final String name;
  final String description;
  final String address;
  final String qrCode;
  final List<String> categories;

  Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.qrCode,
    required this.categories,
  });
  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      qrCode: json['qrCode']?.toString() ?? '',
      categories:
          (json['categories'] as List?)?.map((e) => e.toString()).toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'qrCode': qrCode,
      'categories': categories,
    };
  }
}
