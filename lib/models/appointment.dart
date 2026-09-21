class Appointment {
  final int? id;
  final int customerId;
  final int serviceId;
  final DateTime dateTime;
  final String status; // pending, confirmed, done, cancelled
  final String notes;

  Appointment({
    this.id,
    required this.customerId,
    required this.serviceId,
    required this.dateTime,
    this.status = 'pending',
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'service_id': serviceId,
      'date_time': dateTime.toIso8601String(),
      'status': status,
      'notes': notes,
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'] as int?,
      customerId: map['customer_id'] as int,
      serviceId: map['service_id'] as int,
      dateTime: DateTime.parse(map['date_time'] as String),
      status: map['status'] as String? ?? 'pending',
      notes: map['notes'] as String? ?? '',
    );
  }
}
