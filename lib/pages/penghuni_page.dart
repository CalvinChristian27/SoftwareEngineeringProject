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
            color: const Color(0xFFD33A53),
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
                      color: selectedBlok == blok
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('penghuni').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Terdapat Masalah'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = snapshot.requireData;

                final filteredDocs = data.docs.where((doc) {
                  return (doc.data() as Map<String, dynamic>)['blok'] ==
                      selectedBlok;
                }).toList();

                return ListView(
                  children: filteredDocs.map((DocumentSnapshot document) {
                    try {
                      final penghuni = Penghuni.fromMap(
                          document.data() as Map<String, dynamic>, document.id);
                      return DataPenghuni(
                          penghuni: penghuni, documentId: document.id);
                    } catch (e) {
                      return ListTile(
                        title: const Text('Data Error'),
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
      margin: EdgeInsets.all(15),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Color(0xFFD7D7D7),
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 8,
              offset: Offset(0, 5),
            ),
          ],
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.all(5),
        child: Column(
          children: [
            ListTile(
              title: Row(
                children: [
                  const Icon(
                    Icons.person,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(penghuni.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 0, 0, 0),
                          )),
                    ),
                  ),
                  Text(
                    '${penghuni.blok}${penghuni.noblok} no. ${penghuni.numb}',
                    style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
                  ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.phone,
                          color: const Color.fromARGB(255, 0, 0, 0)),
                      SizedBox(width: 12),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            penghuni.phone,
                            style: TextStyle(
                                color: const Color.fromARGB(255, 0, 0, 0)),
                          ),
                        ),
                      ),
                      Text(
                        'AC: ${penghuni.ac ? 'Yes' : 'No'}',
                        style: TextStyle(
                            color: const Color.fromARGB(255, 0, 0, 0)),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        penghuni.gender == 'Laki-laki'
                            ? Icons.male
                            : Icons.female,
                        color: penghuni.gender == 'Laki-laki'
                            ? Colors.blue
                            : const Color.fromARGB(255, 236, 65, 122),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            penghuni.gender,
                            style: TextStyle(
                                color: const Color.fromARGB(255, 0, 0, 0)),
                          ),
                        ),
                      ),
                      Text(
                        'Heater: ${penghuni.heater ? 'Yes' : 'No'}',
                        style: TextStyle(
                            color: const Color.fromARGB(255, 0, 0, 0)),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          color: const Color.fromARGB(255, 0, 0, 0)),
                      SizedBox(width: 12),
                      Text(
                        DateFormat('dd - MM - yyyy').format(penghuni.date),
                        style: TextStyle(
                            color: const Color.fromARGB(255, 0, 0, 0)),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.credit_card,
                          color: const Color.fromARGB(255, 0, 0, 0)),
                      SizedBox(width: 12),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Rp${penghuni.price.toStringAsFixed(0)}',
                            style: TextStyle(
                                color: const Color.fromARGB(255, 0, 0, 0)),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete,
                            color: Color.fromARGB(255, 255, 0, 0)),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Hapus Data'),
                                content: Text(
                                    'Apakah Anda Ingin Menghapus Data Ini?'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('NO'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      FirebaseFirestore.instance
                                          .collection('penghuni')
                                          .doc(documentId)
                                          .delete();
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
