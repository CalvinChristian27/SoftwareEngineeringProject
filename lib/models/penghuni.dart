import 'package:cloud_firestore/cloud_firestore.dart';

class Penghuni {
  final String id;
  final String name;
  final String phone;
  final String gender;
  final DateTime date;
  final String blok;
  final int noblok;
  final int numb;
  final double price;
  final bool ac;
  final bool heater;
  final String status;
  Map<String, bool> paymentHistory;

  Penghuni({
    required this.id,
    required this.name,
    required this.phone,
    required this.gender,
    required this.date,
    required this.blok,
    required this.noblok,
    required this.numb,
    required this.price,
    required this.ac,
    required this.heater,
    required this.status,
    required this.paymentHistory,
  });

  factory Penghuni.fromMap(Map<String, dynamic> data, String id) {
    late DateTime date;
    if (data['date'] is Timestamp) {
      date = (data['date'] as Timestamp).toDate();
    } else if (data['date'] is String) {
      date = DateTime.parse(data['date']);
    } else {
      throw Exception('Data Invalid');
    }

    return Penghuni(
      id: id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      gender: data['gender'] ?? '',
      date: date,
      blok: data['blok'] ?? '',
      noblok: data['noblok'] ?? 0,
      numb: data['numb'] ?? 0,
      price: (data['price'] is int ? data['price'].toDouble() : data['price']) ?? 0.0,
      ac: data['ac'] ?? false,
      heater: data['heater'] ?? false,
      status: data['status'] ?? 'Unknown',
      paymentHistory: Map<String, bool>.from(data['paymentHistory'] ?? {}),
    );
  }

  factory Penghuni.fromFirestore(DocumentSnapshot<Object?> doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Penghuni.fromMap(data, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'gender': gender,
      'date': Timestamp.fromDate(date),
      'blok': blok,
      'noblok': noblok,
      'numb': numb,
      'price': price,
      'ac': ac,
      'heater': heater,
      'status': status,
      'paymentHistory': paymentHistory,
    };
  }

  void updatePaymentStatus(int month, int year, bool sudahBayar) {
    String key = '$month-$year';
    paymentHistory[key] = sudahBayar;
  }
}
