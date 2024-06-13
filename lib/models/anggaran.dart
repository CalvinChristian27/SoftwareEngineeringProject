import 'package:cloud_firestore/cloud_firestore.dart';

class Anggaran {
  final String status;
  final String desc;
  final DateTime date;
  final double price;

  Anggaran({
    required this.status,
    required this.desc,
    required this.date,
    required this.price,
  });

  factory Anggaran.fromMap(Map<String, dynamic> data) {
    late DateTime date;
    if (data['date'] is Timestamp) {
      date = (data['date'] as Timestamp).toDate();
    } else if (data['date'] is String) {
      date = DateTime.parse(data['date']);
    } else {
      throw Exception('Data Invalid');
    }

    return Anggaran(
      status: data['status'] ?? '',
      desc: data['desc'] ?? '',
      date: date,
      price: (data['price'] is int ? data['price'].toDouble() : data['price']) ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'desc': desc,
      'date': Timestamp.fromDate(date),
      'price': price,
    };
  }
}