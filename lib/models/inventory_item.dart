class InventoryItem {
  final int? id;
  final String name;
  final int quantity;
  final int minQuantity; // حد التنبيه لإعادة الطلب
  final double costPrice;
  final double sellPrice;
  final String unit; // قطعة، علبة، لتر...

  InventoryItem({
    this.id,
    required this.name,
    required this.quantity,
    this.minQuantity = 5,
    this.costPrice = 0,
    this.sellPrice = 0,
    this.unit = 'قطعة',
  });

  bool get isLowStock => quantity <= minQuantity;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'min_quantity': minQuantity,
      'cost_price': costPrice,
      'sell_price': sellPrice,
      'unit': unit,
    };
  }

  factory InventoryItem.fromMap(Map<String, dynamic> map) {
    return InventoryItem(
      id: map['id'] as int?,
      name: map['name'] as String,
      quantity: map['quantity'] as int,
      minQuantity: map['min_quantity'] as int? ?? 5,
      costPrice: (map['cost_price'] as num?)?.toDouble() ?? 0,
      sellPrice: (map['sell_price'] as num?)?.toDouble() ?? 0,
      unit: map['unit'] as String? ?? 'قطعة',
    );
  }

  InventoryItem copyWith({int? quantity}) {
    return InventoryItem(
      id: id,
      name: name,
      quantity: quantity ?? this.quantity,
      minQuantity: minQuantity,
      costPrice: costPrice,
      sellPrice: sellPrice,
      unit: unit,
    );
  }
}
