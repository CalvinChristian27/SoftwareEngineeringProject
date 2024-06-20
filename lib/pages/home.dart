import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class Home extends StatefulWidget {
  final String blok;
  final String noblok;
  final String numb;

  Home({required this.blok, required this.noblok, required this.numb});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late String name;
  late String statusText;
  late IconData statusIcon;
  late String price;
  late String dueDate;
  bool isLoading = true;
  bool isImageSelected = false;
  File? selectedImage;
  String? imageName;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    print('Fetching user data...');
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('penghuni')
          .where('blok', isEqualTo: widget.blok)
          .where('noblok', isEqualTo: widget.noblok)
          .where('numb', isEqualTo: int.parse(widget.numb))
          .get();

      print('Snapshot received: ${snapshot.docs.length} documents found');
      if (snapshot.docs.isEmpty) {
        print('No documents found.');
        setState(() {
          isLoading = false;
          name = 'No data';
          statusText = 'No data';
          statusIcon = Icons.error;
          price = '0';
          dueDate = 'N/A';
        });
        return;
      }

      var data = snapshot.docs.first.data();
      print('Data fetched: $data');
      setState(() {
        name = data['name'] ?? 'Unknown';
        statusText = data['status'] ?? 'Belum Bayar';
        statusIcon = (statusText == 'Sudah Dibayar')
            ? Icons.check_circle
            : Icons.warning;
        price = data['price'].toString();
        DateTime now = DateTime.now();
        dueDate = _getLastDayOfMonth(now);
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        isLoading = false;
        name = 'Error';
        statusText = 'Error';
        statusIcon = Icons.error;
        price = '0';
        dueDate = 'N/A';
      });
    }
  }

  String _getLastDayOfMonth(DateTime dateTime) {
    final beginningNextMonth = (dateTime.month < 12)
        ? DateTime(dateTime.year, dateTime.month + 1, 1)
        : DateTime(dateTime.year + 1, 1, 1);
    final lastDayOfMonth = beginningNextMonth.subtract(Duration(days: 1));
    return DateFormat('dd MMMM yyyy').format(lastDayOfMonth);
  }

  Future<void> uploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File file = File(pickedFile.path);
      String fileName = '${widget.blok}_${widget.noblok}_${widget.numb}.jpg';

      try {
        await FirebaseStorage.instance.ref(fileName).putFile(file);
        String downloadUrl =
            await FirebaseStorage.instance.ref(fileName).getDownloadURL();

        await FirebaseFirestore.instance
            .collection('penghuni')
            .where('blok', isEqualTo: widget.blok)
            .where('noblok', isEqualTo: widget.noblok)
            .where('numb', isEqualTo: int.parse(widget.numb))
            .get()
            .then((snapshot) {
          snapshot.docs.first.reference
              .update({'bukti': downloadUrl, 'status': 'Sudah Dibayar'});
        });

        setState(() {
          selectedImage = file;
          imageName = fileName;
          statusIcon = Icons.check_circle;
          statusText = 'Sudah Dibayar';
          isImageSelected = true;
        });
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Building UI...');
    return Scaffold(
      appBar: AppBar(
        title: isLoading ? Text('Loading...') : Text('Halo, $name'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat.yMMMM().format(DateTime.now()),
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(statusIcon,
                          color: statusIcon == Icons.warning
                              ? Colors.red
                              : Colors.green),
                      SizedBox(width: 10),
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 18,
                          color: statusIcon == Icons.warning
                              ? Colors.red
                              : Colors.green,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Total Tagihan:',
                    style: TextStyle(fontSize: 14, color: Color(0xFF4A4C4B)),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Rp$price',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Jatuh tempo $dueDate',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Pilih Pembayaran:',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  buildPaymentMethod(),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.upload),
                      label: Text(imageName ?? 'Upload Bukti Pembayaran'),
                      onPressed: uploadImage,
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: isImageSelected ? uploadImage : null,
                      child: Text('Kirim'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget buildPaymentMethod() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('metode').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
          return Text('Tidak Ada Metode Pembayaran');
        } else {
          List<Widget> paymentMethods = [];
          snapshot.data!.docs.forEach((doc) {
            var metode = doc.data() as Map<String, dynamic>;
            print('Payment method data: $metode');
            paymentMethods.add(buildPaymentMethodItem(metode));
          });
          return Column(
            children: paymentMethods,
          );
        }
      },
    );
  }

  Widget buildPaymentMethodItem(Map<String, dynamic> metode) {
    if (metode['type'] == null || metode['type'].isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/${metode['type'].toLowerCase()}.png',
            width: 40,
            height: 40,
          ),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Transfer ke rek. ${metode['type']} a.n. ${metode['nama']}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 5),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: metode['nomor']));
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Nomor rekening disalin ke clipboard')));
                },
                child: Text(
                  metode['nomor'],
                  style: TextStyle(fontSize: 16, color: Colors.blue),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
