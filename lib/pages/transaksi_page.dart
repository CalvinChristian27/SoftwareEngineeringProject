import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:kostmanagement/models/penghuni.dart';
import 'package:kostmanagement/pages/payment_method.dart';

class TransaksiPage extends StatefulWidget {
  @override
  _TransaksiPageState createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage> {
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  String selectedBlok = 'B';
  String filterStatus = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Penghuni Kos'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PaymentMethodPage()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Column(
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
                Row(
                  children: [
                    SizedBox(width: 20),
                    DropdownButton<int>(
                      value: selectedMonth,
                      onChanged: (int? newValue) {
                        setState(() {
                          selectedMonth = newValue!;
                        });
                      },
                      items: List<DropdownMenuItem<int>>.generate(12, (index) {
                        return DropdownMenuItem<int>(
                          value: index + 1,
                          child: Text(
                              DateFormat.MMMM().format(DateTime(0, index + 1))),
                        );
                      }),
                    ),
                    SizedBox(width: 16),
                    DropdownButton<int>(
                      value: selectedYear,
                      items: List.generate(
                        101,
                        (index) => DropdownMenuItem(
                          child: Text((2000 + index).toString()),
                          value: 2000 + index,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          selectedYear = value!;
                        });
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          filterStatus = filterStatus == 'Sudah Bayar'
                              ? 'All'
                              : 'Sudah Bayar';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: filterStatus == 'Sudah Bayar'
                            ? Colors.green
                            : Colors.grey,
                      ),
                      child: Text('Sudah Bayar'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          filterStatus = filterStatus == 'Belum Bayar'
                              ? 'All'
                              : 'Belum Bayar';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: filterStatus == 'Belum Bayar'
                            ? Colors.red
                            : Colors.grey,
                      ),
                      child: Text('Belum Bayar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('penghuni')
                  .where('blok', isEqualTo: selectedBlok)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No data found.'));
                }
                List<DocumentSnapshot> penghuniDocs = snapshot.data!.docs;

                if (filterStatus != 'All') {
                  penghuniDocs = penghuniDocs.where((doc) {
                    final penghuni = Penghuni.fromFirestore(doc);
                    final status = penghuni.paymentHistory
                            .containsKey('$selectedMonth-$selectedYear')
                        ? 'Sudah Bayar'
                        : 'Belum Bayar';
                    return status == filterStatus;
                  }).toList();
                }

                return ListView.builder(
                  itemCount: penghuniDocs.length,
                  itemBuilder: (context, index) {
                    final penghuniDoc = penghuniDocs[index];
                    final penghuni = Penghuni.fromFirestore(penghuniDoc);
                    final status = penghuni.paymentHistory
                            .containsKey('$selectedMonth-$selectedYear')
                        ? 'Sudah Bayar'
                        : 'Belum Bayar';

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
                        child: ListTile(
                          title: Row(
                            children: [
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(penghuni.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color:
                                            const Color.fromARGB(255, 0, 0, 0),
                                      )),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Blok ${penghuni.blok}${penghuni.noblok} no. ${penghuni.numb}'),
                              Text(
                                  'Harga: Rp${penghuni.price.toStringAsFixed(0)}'),
                              Text('Status: $status'),
                            ],
                          ),
                          trailing: GestureDetector(
                            onTap: () async {
                              if (status == 'Sudah Bayar') {
                                try {
                                  String imageUrl = await FirebaseStorage
                                      .instance
                                      .ref()
                                      .child(
                                          'payment_images/${penghuniDoc.id}/$selectedMonth-$selectedYear.jpg')
                                      .getDownloadURL();

                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) => Dialog(
                                      child: Image.network(imageUrl),
                                    ),
                                  );
                                } catch (e) {
                                  print('Error fetching image: $e');
                                }
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 5),
                              decoration: BoxDecoration(
                                color: status == 'Sudah Bayar'
                                    ? Colors.green
                                    : Colors.red,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                status,
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
