import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home.dart';

class UserLogin extends StatefulWidget {
  @override
  _UserLoginState createState() => _UserLoginState();
}

class _UserLoginState extends State<UserLogin> {
  String? selectedBlok;
  int? selectedNoblok;
  String? selectedNumb;
  int? selectedRoom;
  bool isSelected = false;
  List<DropdownMenuItem<String>> blokItems = [];
  List<DropdownMenuItem<String>> numbItems = [];

  @override
  void initState() {
    super.initState();
    loadBlokItems();
  }

  Future<void> loadBlokItems() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('penghuni').get();
    Set<String> blokNoblokSet = {};
    for (var doc in snapshot.docs) {
      var blok = doc['blok'];
      var noblok = doc['noblok'].toString();
      blokNoblokSet.add('$blok$noblok');
    }
    List<String> blokNoblokList = blokNoblokSet.toList();
    blokNoblokList.sort((a, b) {
      String blokA = a.substring(0, 1);
      int noblokA = int.parse(a.substring(1));
      String blokB = b.substring(0, 1);
      int noblokB = int.parse(b.substring(1));
      int blokComparison = blokA.compareTo(blokB);
      if (blokComparison != 0) {
        return blokComparison;
      }
      return noblokA.compareTo(noblokB);
    });
    setState(() {
      blokItems = blokNoblokList.map((blokNoblok) {
        return DropdownMenuItem(
          value: blokNoblok,
          child: Text(blokNoblok),
        );
      }).toList();
    });
  }

  Future<void> loadNumbItems(String blok, int noblok) async {
    print('Loading numb items for blok: $blok, noblok: $noblok');
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('penghuni')
        .where('blok', isEqualTo: blok)
        .where('noblok', isEqualTo: noblok)
        .get();
    if (snapshot.docs.isEmpty) {
      print('No documents found for blok: $blok, noblok: $noblok');
    }
    List<String> numbs =
        snapshot.docs.map((doc) => doc['numb'].toString()).toList();
    numbs.sort((a, b) => int.parse(a).compareTo(int.parse(b)));
    setState(() {
      numbItems = numbs.map((numb) {
        return DropdownMenuItem(
          value: numb,
          child: Text(numb),
        );
      }).toList();
      print('Loaded numb items: $numbItems');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/image.png',
            fit: BoxFit.cover,
            height: double.infinity,
            color: Colors.black.withOpacity(0.5),
            colorBlendMode: BlendMode.darken,
          ),
          Center(
            child: Container(
              width: 300,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Pilih sesuai nomor kamar anda',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                  SizedBox(height: 20),
                  DropdownButton<String>(
                    hint: Text(
                      'Nomor Blok',
                      style: TextStyle(),
                    ),
                    value: selectedBlok,
                    items: blokItems,
                    onChanged: (value) {
                      setState(() {
                        selectedBlok = value;
                        if (selectedBlok != null) {
                          selectedNoblok =
                              int.parse(selectedBlok!.substring(1));
                          String blok = selectedBlok!.substring(0, 1);
                          loadNumbItems(blok, selectedNoblok!);
                        }
                        selectedNumb = null;
                        isSelected = false;
                      });
                    },
                  ),
                  if (selectedBlok != null && numbItems.isNotEmpty)
                    DropdownButton<String>(
                      hint: Text('Nomor Kamar'),
                      value: selectedNumb,
                      items: numbItems,
                      onChanged: (value) {
                        setState(() {
                          selectedNumb = value;
                          isSelected = selectedNumb != null;
                        });
                      },
                    ),
                  if (selectedBlok != null && numbItems.isEmpty)
                    CircularProgressIndicator(),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: isSelected
                        ? () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.warning,
                                                size: 50, color: Colors.red),
                                            SizedBox(width: 21),
                                            Flexible(
                                              child: Text(
                                                'Pastikan nomor blok dan nomor kamar anda sudah sesuai. Anda tidak bisa kembali ke halaman ini lagi.',
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 20),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Container(
                                              height: 40,
                                              width: 130,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(30.0),
                                                border: Border.all(
                                                    color:
                                                        const Color(0xFF4361FF),
                                                    width: 1.0),
                                              ),
                                              child: TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text(
                                                  'Cek Kembali',
                                                  style: TextStyle(
                                                      color: const Color(
                                                          0xFF4361FF)),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: 130,
                                              child: TextButton(
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pushReplacement(
                                                          MaterialPageRoute(
                                                    builder: (context) => Home(
                                                      blok: selectedBlok!,
                                                      numb: selectedNumb!,
                                                      noblok: selectedNoblok
                                                          .toString(),
                                                    ),
                                                  ));
                                                },
                                                child: Text(
                                                  'Sudah Benar',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                style: TextButton.styleFrom(
                                                  backgroundColor:
                                                      const Color(0xFF4361FF),
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 20),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          }
                        : null,
                    child: Text(
                      'MASUK',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
