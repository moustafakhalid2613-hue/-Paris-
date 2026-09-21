class InvoiceItem {
  final int? id;
  final int invoiceId;
  final String itemType; // 'service' or 'product'
  final int itemId;
  final String itemName;
  final double unitPrice;
  final int quantity;

  InvoiceItem({
    this.id,
    required this.invoiceId,
    required this.itemType,
    required this.itemId,
    required this.itemName,
    required this.unitPrice,
    this.quantity = 1,
  });

  double get total => unitPrice * quantity;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoice_id': invoiceId,
      'item_type': itemType,
      'item_id': itemId,
      'item_name': itemName,
      'unit_price': unitPrice,
      'quantity': quantity,
    };
  }

  factory InvoiceItem.fromMap(Map<String, dynamic> map) {
    return InvoiceItem(
      id: map['id'] as int?,
      invoiceId: map['invoice_id'] as int,
      itemType: map['item_type'] as String,
      itemId: map['item_id'] as int,
      itemName: map['item_name'] as String,
      unitPrice: (map['unit_price'] as num).toDouble(),
      quantity: map['quantity'] as int? ?? 1,
    );
  }
}

class Invoice {
  final int? id;
  final int? customerId;
  final String customerName;
  final DateTime dateTime;
  final double discount;
  final String paymentMethod; // cash, card
  final String status; // paid, unpaid

  Invoice({
    this.id,
    this.customerId,
    this.customerName = 'عميل عابر',
    DateTime? dateTime,
    this.discount = 0,
    this.paymentMethod = 'cash',
    this.status = 'paid',
  }) : dateTime = dateTime ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'customer_name': customerName,
      'date_time': dateTime.toIso8601String(),
      'discount': discount,
      'payment_method': paymentMethod,
      'status': status,
    };
  }

  factory Invoice.fromMap(Map<String, dynamic> map) {
    return Invoice(
      id: map['id'] as int?,
      customerId: map['customer_id'] as int?,
      customerName: map['customer_name'] as String? ?? 'عميل عابر',
      dateTime: DateTime.parse(map['date_time'] as String),
      discount: (map['discount'] as num?)?.toDouble() ?? 0,
      paymentMethod: map['payment_method'] as String? ?? 'cash',
      status: map['status'] as String? ?? 'paid',
    );
  }
}
