import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentMethodPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Metode Pembayaran'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            PaymentMethodBox(documentId: 'BCA', imagePath: 'assets/bca.png'),
            PaymentMethodBox(documentId: 'Dana', imagePath: 'assets/dana.png'),
            PaymentMethodBox(documentId: 'OVO', imagePath: 'assets/ovo.png'),
            PaymentMethodBox(
                documentId: 'Gopay', imagePath: 'assets/gopay.png'),
          ],
        ),
      ),
    );
  }
}

class PaymentMethodBox extends StatelessWidget {
  final String documentId;
  final String imagePath;

  PaymentMethodBox({required this.documentId, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('metode')
          .doc(documentId)
          .snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return _buildCardWithoutData(context);
        }

        var data = snapshot.data!;
        String nama = data.get('nama') ?? 'Tidak Terhubung';
        String nomor = data.get('nomor') ?? 'Tidak Terhubung';
        bool isConnected = data.exists;

        return _buildCardWithData(context, nama, nomor, isConnected);
      },
    );
  }

  Widget _buildCardWithoutData(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showEditDialog(context, documentId, '', '', false);
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(imagePath),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$documentId',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
                    ),
                    Text('Tidak Terhubung'),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Tidak Terhubung',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardWithData(
      BuildContext context, String nama, String nomor, bool isConnected) {
    return GestureDetector(
      onTap: () {
        _showEditDialog(context, documentId, nama, nomor, isConnected);
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(imagePath),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nama,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(nomor),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  isConnected ? 'Terhubung' : 'Tidak Terhubung',
                  style: TextStyle(
                    color: isConnected ? Colors.blue : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, String documentId,
      String currentNama, String currentNomor, bool isConnected) {
    TextEditingController namaController =
        TextEditingController(text: currentNama);
    TextEditingController nomorController =
        TextEditingController(text: currentNomor);

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Edit $documentId',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: namaController,
                    decoration: InputDecoration(labelText: 'Nama Rekening'),
                  ),
                  TextField(
                    controller: nomorController,
                    decoration: InputDecoration(labelText: 'Nomor Rekening'),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection('metode')
                              .doc(documentId)
                              .get()
                              .then((docSnapshot) {
                            if (docSnapshot.exists) {
                              FirebaseFirestore.instance
                                  .collection('metode')
                                  .doc(documentId)
                                  .update({
                                'nama': namaController.text,
                                'nomor': nomorController.text,
                              }).then((value) => Navigator.pop(context));
                            } else {
                              FirebaseFirestore.instance
                                  .collection('metode')
                                  .doc(documentId)
                                  .set({
                                'nama': namaController.text,
                                'nomor': nomorController.text,
                              }).then((value) => Navigator.pop(context));
                            }
                          });
                        },
                        child: Text('Simpan'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
