class ServiceModel {
  final int? id;
  final String name;
  final double price;
  final String category;
  final int durationMinutes;

  ServiceModel({
    this.id,
    required this.name,
    required this.price,
    this.category = 'عام',
    this.durationMinutes = 30,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'category': category,
      'duration_minutes': durationMinutes,
    };
  }

  factory ServiceModel.fromMap(Map<String, dynamic> map) {
    return ServiceModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      price: (map['price'] as num).toDouble(),
      category: map['category'] as String? ?? 'عام',
      durationMinutes: map['duration_minutes'] as int? ?? 30,
    );
  }
}
