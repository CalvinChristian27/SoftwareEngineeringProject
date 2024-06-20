import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TambahTransaksiPage extends StatefulWidget {
  @override
  _TambahTransaksiPageState createState() => _TambahTransaksiPageState();
}

class _TambahTransaksiPageState extends State<TambahTransaksiPage> {
  final _formKey = GlobalKey<FormState>();
  String _status = 'Penghasilan';
  final TextEditingController _descController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _priceController = TextEditingController();

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _saveTransaksi() {
    if (_formKey.currentState!.validate()) {
      FirebaseFirestore.instance.collection('transaksi').add({
        'status': _status,
        'desc': _descController.text,
        'date': Timestamp.fromDate(_selectedDate),
        'price': double.tryParse(_priceController.text) ?? 0.0,
      }).then((_) {
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Tambah Riwayat Transaksi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                        child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: _status == 'Penghasilan'
                              ? Colors.orange
                              : Colors.grey),
                      onPressed: () {
                        setState(() {
                          _status = 'Penghasilan';
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('PENGHASILAN'),
                        ],
                      ),
                    )),
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _status == 'Pengeluaran'
                              ? Colors.orange
                              : Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _status = 'Pengeluaran';
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('PENGELUARAN'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              TextFormField(
                controller: _descController,
                decoration: InputDecoration(labelText: 'Deskripsi Transaksi'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi Tidak Boleh Kosong';
                  }
                  return null;
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.date_range),
                  Text(
                      'Tanggal Transaksi: ${_selectedDate.toLocal().toIso8601String().split('T')[0]}'),
                  TextButton(
                    onPressed: _pickDate,
                    child: Text('Pilih Tanggal'),
                  ),
                ],
              ),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                    labelText: 'Harga', icon: Icon(Icons.credit_card)),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harga tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveTransaksi,
                child: Text('KONFIRMASI'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
