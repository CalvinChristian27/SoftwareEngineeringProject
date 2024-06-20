import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kostmanagement/models/anggaran.dart';
import 'package:kostmanagement/pages/tambah_transaksi.dart';
import 'package:intl/intl.dart';

class AnggaranPage extends StatefulWidget {
  @override
  _AnggaranPageState createState() => _AnggaranPageState();
}

class _AnggaranPageState extends State<AnggaranPage> {
  double totalNaik = 0;
  double totalTurun = 0;
  double profit = 0;
  double lost = 0;
  List<Anggaran> anggaranList = [];
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;

  @override
  void initState() {
    super.initState();
    _getAnggaranData();
  }

  Future<void> _getAnggaranData() async {
    final startOfMonth = DateTime(selectedYear, selectedMonth, 1);
    final endOfMonth = DateTime(selectedYear, selectedMonth + 1, 0);

    final snapshot = await FirebaseFirestore.instance
        .collection('transaksi')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
        .get();

    final data =
        snapshot.docs.map((doc) => Anggaran.fromMap(doc.data())).toList();

    double naik = 0;
    double turun = 0;

    for (var item in data) {
      if (item.status == 'Penghasilan') {
        naik += item.price;
      } else if (item.status == 'Pengeluaran') {
        turun += item.price;
      }
    }

    setState(() {
      anggaranList = data;
      totalNaik = naik;
      totalTurun = turun;

      if (totalNaik > totalTurun) {
        profit = totalNaik - totalTurun;
        lost = 0;
      } else {
        profit = 0;
        lost = totalTurun - totalNaik;
      }
    });

    await FirebaseFirestore.instance
        .collection('anggaran')
        .doc('${selectedYear}_${selectedMonth}')
        .set({
      'profit': profit,
      'lost': lost,
      'date': Timestamp.now(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Anggaran Bulanan'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateSelector(),
            SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: _buildSummaryBox('Penghasilan', totalNaik),
                ),
                SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: _buildSummaryBox('Pengeluaran', totalTurun),
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(child: _buildTransactionList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TambahTransaksiPage()),
          ).then((_) => _getAnggaranData());
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildDateSelector() {
    return Row(
      children: [
        DropdownButton<int>(
          value: selectedMonth,
          items: List.generate(
            12,
            (index) => DropdownMenuItem(
              child: Text(DateFormat.MMMM().format(DateTime(0, index + 1))),
              value: index + 1,
            ),
          ),
          onChanged: (value) {
            setState(() {
              selectedMonth = value!;
              _getAnggaranData();
            });
          },
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
              _getAnggaranData();
            });
          },
        ),
      ],
    );
  }

  Widget _buildSummaryBox(String title, double amount) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Rp${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    return ListView.builder(
      itemCount: anggaranList.length,
      itemBuilder: (context, index) {
        final item = anggaranList[index];
        return ListTile(
          leading: Icon(
            size: 45,
            item.status == 'Penghasilan'
                ? Icons.arrow_circle_up
                : Icons.arrow_circle_down,
            color: item.status == 'Penghasilan' ? Colors.green : Colors.red,
          ),
          title: Text(item.desc),
          subtitle: Text(DateFormat('dd - MM - yyyy').format(item.date)),
          trailing: Text(
            'Rp${item.price.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }
}
