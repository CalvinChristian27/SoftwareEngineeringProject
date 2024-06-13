import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TambahPenghuniPage extends StatefulWidget {
  @override
  _TambahPenghuniPageState createState() => _TambahPenghuniPageState();
}

class _TambahPenghuniPageState extends State<TambahPenghuniPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _gender = 'Laki-laki';
  String _blok = 'B';
  int _noblok = 1;
  int _numb = 1;
  bool _ac = false;
  bool _heater = false;

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

  void _savePenghuni() {
    if (_formKey.currentState!.validate()) {
      FirebaseFirestore.instance.collection('penghuni').add({
        'name': _nameController.text,
        'phone': _phoneController.text,
        'gender': _gender,
        'date': Timestamp.fromDate(_selectedDate),
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'blok': _blok,
        'noblok': _noblok,
        'numb': _numb,
        'ac': _ac,
        'heater': _heater,
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
        title: Text('Tambah Penghuni'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nama', icon: Icon(Icons.person)),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'No. Telepon', icon: Icon(Icons.phone)),
                keyboardType: TextInputType.number,
                maxLength: 12,
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 11 || value.length > 12) {
                    return 'Nomor Telepon tidak boleh kosong';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Harga', icon: Icon(Icons.credit_card)),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harga tidak boleh kosong';
                  }
                  return null;
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.date_range),
                  Text('Tanggal Masuk: ${_selectedDate.toLocal().toIso8601String().split('T')[0]}'),
                  TextButton(
                    onPressed: _pickDate,
                    child: Text('Pilih Tanggal'),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: _gender == 'Laki-laki' ? Colors.orange : Colors.grey),
                        onPressed: (){
                          setState(() {
                            _gender = 'Laki-laki';
                          });
                        },
                        child: Text('LAKI-LAKI'),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: _gender == 'Perempuan' ? Colors.orange : Colors.grey,),
                        onPressed: () {
                          setState(() {
                            _gender = 'Perempuan';
                          });
                        },
                        child: Text('PEREMPUAN'),
                      ),
                    ),
                  ],
                ),
              ),
              DropdownButtonFormField<String>(
                value: _blok,
                decoration: InputDecoration(labelText: 'Blok', icon: Icon(Icons.king_bed)),
                items: ['B', 'C'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _blok = newValue!;
                  });
                },
              ),
              TextFormField(
                initialValue: _noblok.toString(),
                decoration: InputDecoration(labelText: 'Nomor Blok', icon: Icon(Icons.home)),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _noblok = int.parse(value);
                },
              ),
              TextFormField(
                initialValue: _numb.toString(),
                decoration: InputDecoration(labelText: 'Nomor Kamar', icon: Icon(Icons.format_list_numbered)),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _numb = int.parse(value);
                },
              ),
              CheckboxListTile(
                title: Text('AC'),
                value: _ac,
                onChanged: (bool? value) {
                  setState(() {
                    _ac = value!;
                  });
                },
              ),
              CheckboxListTile(
                title: Text('Heater'),
                value: _heater,
                onChanged: (bool? value) {
                  setState(() {
                    _heater = value!;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _savePenghuni,
                child: Text('KONFIRMASI'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}