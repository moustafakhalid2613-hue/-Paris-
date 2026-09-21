class Customer {
  final int? id;
  final String name;
  final String phone;
  final String notes;
  final DateTime createdAt;

  Customer({
    this.id,
    required this.name,
    required this.phone,
    this.notes = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] as int?,
      name: map['name'] as String,
      phone: map['phone'] as String? ?? '',
      notes: map['notes'] as String? ?? '',
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
