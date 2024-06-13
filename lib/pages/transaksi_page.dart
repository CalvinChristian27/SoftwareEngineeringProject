import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:kostmanagement/models/penghuni.dart';

class TransaksiPage extends StatefulWidget {
  @override
  _TransaksiPageState createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage> {
  String selectedBlok = 'B';
  String selectedMonth = DateFormat('MMMM').format(DateTime.now());
  int selectedYear = DateTime.now().year;
  List<String> months = List<String>.generate(12, (int index) {
    return DateFormat('MMMM').format(DateTime(0, index + 1));
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Transaksi'),
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
          Container(
            padding: EdgeInsets.all(10),
            child: DropdownButton<String>(
              value: '$selectedMonth $selectedYear',
              items: [
                for (int year = 2000; year <= DateTime.now().year + 1; year++)
                  for (String month in months)
                    DropdownMenuItem(
                      value: '$month $year',
                      child: Text('$month $year'),
                    )
              ],
              onChanged: (newValue) {
                setState(() {
                  var parts = newValue!.split(' ');
                  selectedMonth = parts[0];
                  selectedYear = int.parse(parts[1]);
                });
              },
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
                      return DataPenghuni(
                        key: ValueKey(document.id),
                        penghuni: penghuni,
                        documentId: document.id,
                        selectedMonth: selectedMonth,
                        selectedYear: selectedYear,
                      );
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
    );
  }
}

class DataPenghuni extends StatefulWidget {
  final Penghuni penghuni;
  final String documentId;
  final String selectedMonth;
  final int selectedYear;

  DataPenghuni({
    Key? key,
    required this.penghuni,
    required this.documentId,
    required this.selectedMonth,
    required this.selectedYear,
  }) : super(key: key);

  @override
  _DataPenghuniState createState() => _DataPenghuniState();
}

class _DataPenghuniState extends State<DataPenghuni> {
  late Map<String, bool> paymentStatus;
  late double total;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    paymentStatus = {};
    total = 0;
    fetchPaymentStatus();
  }

  Future<void> fetchPaymentStatus() async {
    try {
      DocumentSnapshot snapshot = await _firestore
          .collection('payments')
          .doc('${widget.documentId}/${widget.selectedMonth}/${widget.selectedYear}')
          .get();

      if (snapshot.exists) {
        setState(() {
          paymentStatus = Map<String, bool>.from(snapshot['status']);
          calculateTotal();
        });
      } else {
        setState(() {
          paymentStatus = {widget.penghuni.name: false};
        });
      }
    } catch (e) {
      print('Error Mengambil Data: $e');
    }
  }

  void calculateTotal() {
    double Biaya = widget.penghuni.price;
    total = 0;
    paymentStatus.forEach((name, Bayar) {
      if (Bayar) {
        total += Biaya;
      }
    });
  }

  void togglePaymentStatus(String name, double Biaya) {
    setState(() {
      paymentStatus[name] = !(paymentStatus[name] ?? false);
      calculateTotal();
      savePaymentStatus();
    });
  }

  Future<void> savePaymentStatus() async {
    try {
      await _firestore
          .collection('payments')
          .doc('${widget.documentId}/${widget.selectedMonth}/${widget.selectedYear}')
          .set({'status': paymentStatus});
    } catch (e) {
      print('Error Simpan Data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double semester = widget.penghuni.price * 12;

    return Card(
      margin: EdgeInsets.all(15.0),
      child: Container(
        color: Color(0xFFFFC397),
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.penghuni.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${widget.penghuni.blok}${widget.penghuni.noblok} no. ${widget.penghuni.numb}',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Per Bulan \t\t\t\t\t\t\t: Rp${widget.penghuni.price.toStringAsFixed(0)}',
                                style: TextStyle(fontSize: 12),
                              ),
                              Text(
                                'Per Semester : Rp${semester.toStringAsFixed(0)}',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: ListView(
                            shrinkWrap: true,
                            children: paymentStatus.keys.map((name) {
                              bool Bayar = paymentStatus[name] ?? false;
                              return ListTile(
                                trailing: SizedBox(
                                  height: 25,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Bayar ? Colors.green : Colors.red,
                                    ),
                                    child: Text(
                                      Bayar ? 'Sudah Bayar' : 'Belum Bayar',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Bayar ? Colors.black : Colors.white,
                                      ),
                                    ),
                                    onPressed: () {
                                      togglePaymentStatus(name, widget.penghuni.price);
                                    },
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
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
