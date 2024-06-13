import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kostmanagement/pages/penghuni_page.dart';
import 'package:kostmanagement/pages/transaksi_page.dart';
import 'package:kostmanagement/pages/anggaran_page.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}



class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'University Village',  
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: const Color(0xFFFFFCF9),
      ),
      home: DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  int _jumlahPenghuni = 0;
  int _ruanganTersedia = 0;

  @override
  void initState() {
    super.initState();
    _fetchJumlahPenghuni();
  }

  Future<void> _fetchJumlahPenghuni() async {
    final querySnapshot = await FirebaseFirestore.instance.collection('penghuni').get();
    final jumlahPenghuni = querySnapshot.docs.length;
    final ruanganTersedia = 48 - jumlahPenghuni;

    setState(() {
      _jumlahPenghuni = jumlahPenghuni;
      _ruanganTersedia = ruanganTersedia;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetOptions = <Widget>[
      Dashboard(onInfoTap: _onItemTapped, ruanganTersedia: _ruanganTersedia, jumlahPenghuni: _jumlahPenghuni, onRefresh: _fetchJumlahPenghuni),
      PenghuniPage(),
      TransaksiPage(),
      AnggaranPage(),
    ];

    return Scaffold(
      body: widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Penghuni',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Transaksi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Anggaran',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFFF46600),
        unselectedItemColor: Colors.black,
        onTap: _onItemTapped,
      ),
    );
  }
}

class Dashboard extends StatelessWidget {
  final Function(int) onInfoTap;
  final int jumlahPenghuni;
  final int ruanganTersedia;
  final Future<void> Function() onRefresh;

  const Dashboard({super.key, required this.onInfoTap, required this.jumlahPenghuni, required this.ruanganTersedia, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('University Village')),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildDashboardCard(
                context,
                'Kamar Tersedia',
                '$ruanganTersedia',
                Icons.home,
                Color(0xFF86CCFF),
                () => onInfoTap(1),
              ),
              _buildDashboardCard(
                context,
                'Penghuni Kost',
                '$jumlahPenghuni',
                Icons.person,
                Color(0xFFFDFF86),
                () => onInfoTap(1),
              ),
              _buildDashboardCard(
                context,
                'Pembayaran Bulan Ini',
                'Rp. 13.000.000',
                Icons.account_balance_wallet,
                Color(0xFF86FFA1),
                () => onInfoTap(2),
              ),
              _buildDashboardCard(
                context,
                'Anggaran Tahun Ini',
                'Rp. 11.000.000\nRp. 4.000.000',
                Icons.bar_chart,
                Color(0xFF86FFA1),
                () => onInfoTap(3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context, String title, String value, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: color,
        margin: const EdgeInsets.all(10.0),
        child: ListTile(
          leading: Icon(icon, size: 50),
          title: Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          subtitle: Text(title),
          trailing: Text('Info Selengkapnya', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}