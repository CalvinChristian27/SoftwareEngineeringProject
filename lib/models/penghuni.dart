import 'package:cloud_firestore/cloud_firestore.dart';

class Penghuni {
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

  Penghuni({
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
  });

  factory Penghuni.fromMap(Map<String, dynamic> data) {
    late DateTime date;
    if (data['date'] is Timestamp) {
      date = (data['date'] as Timestamp).toDate();
    } else if (data['date'] is String) {
      date = DateTime.parse(data['date']);
    } else {
      throw Exception('Data Invalid');
    }

    return Penghuni(
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      gender: data['gender'] ?? '',
      date: date,
      price: (data['price'] is int ? data['price'].toDouble() : data['price']) ?? 0.0,
      blok: data['blok'] ?? '',
      noblok: data['noblok'] ?? 0,
      numb: data['numb'] ?? 0,
      ac: data['ac'] ?? false,
      heater: data['heater'] ?? false,
    );
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
    };
  }
}
