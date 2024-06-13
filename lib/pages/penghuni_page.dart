import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:kostmanagement/models/penghuni.dart';
import 'package:kostmanagement/pages/tambah_penghuni.dart';

class PenghuniPage extends StatefulWidget {
  @override
  _PenghuniPageState createState() => _PenghuniPageState();
}

class _PenghuniPageState extends State<PenghuniPage> {
  String selectedBlok = 'B';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Penghuni Kos'),
      ),
      body: Column(
        children: [
          Container(
            color: Color(0xFFFFC397),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['B', 'C'].map((blok) {
                return TextButton(
                  onPressed: () {
                    setState(() {
                      selectedBlok = blok;
                    });
                  },
                  child: Text(
                    'Blok $blok',
                    style: TextStyle(
                      color: selectedBlok == blok ? Colors.blue : Colors.black,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('penghuni').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Terdapat Masalah'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final data = snapshot.requireData;

                final filteredDocs = data.docs.where((doc) {
                  return (doc.data() as Map<String, dynamic>)['blok'] == selectedBlok;
                }).toList();

                return ListView(
                  children: filteredDocs.map((DocumentSnapshot document) {
                    try {
                      final penghuni = Penghuni.fromMap(document.data() as Map<String, dynamic>);
                      return DataPenghuni(penghuni: penghuni, documentId: document.id);
                    } catch (e) {
                      print('Database Error ${document.id}: $e');
                      return ListTile(
                        title: Text('Data Error'),
                        subtitle: Text('ID: ${document.id}'),
                      );
                    }
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TambahPenghuniPage()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

class DataPenghuni extends StatelessWidget {
  final Penghuni penghuni;
  final String documentId;

  DataPenghuni({required this.penghuni, required this.documentId});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(15.0),
      child: Container(
        color: Color(0xFFFFC397),
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: [
            ListTile(
              title: Row(
                children: [
                  Icon(Icons.person),
                  SizedBox(width: 12),
                  Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(penghuni.name, style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  ),
                  Text('${penghuni.blok}${penghuni.noblok} no. ${penghuni.numb}'),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.phone),
                      SizedBox(width: 12),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(penghuni.phone),
                        ),
                      ),
                      Text('AC: ${penghuni.ac ? 'Yes' : 'No'}'),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(penghuni.gender == 'Laki-laki' ? Icons.male : Icons.female),
                      SizedBox(width: 12),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(penghuni.gender),
                        ),
                      ),
                      Text('Heater: ${penghuni.heater ? 'Yes' : 'No'}'),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.calendar_today),
                      SizedBox(width: 12),
                      Text(DateFormat('dd - MM - yyyy').format(penghuni.date)),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.credit_card),
                      SizedBox(width: 12),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Rp${penghuni.price.toStringAsFixed(0)}'),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Hapus Data'),
                                content: Text('Apakah Anda Ingin Menghapus Data Ini?'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('NO'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      FirebaseFirestore.instance.collection('penghuni').doc(documentId).delete();
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('YES'),
                                  )
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}