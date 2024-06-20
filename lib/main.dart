import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kostmanagement/pages/penghuni_page.dart';
import 'package:kostmanagement/pages/transaksi_page.dart';
import 'package:kostmanagement/pages/anggaran_page.dart';
import 'package:kostmanagement/pages/payment_method.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'University Village',
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Color.fromARGB(255, 255, 255, 255),
      ),
      home: DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  int _jumlahPenghuni = 0;
  int _ruanganTersedia = 0;
  double profit = 0;
  double lost = 0;
  bool isProfit = true;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    await _fetchJumlahPenghuni();
    await _fetchProfitLostData();
  }

  Future<void> _fetchJumlahPenghuni() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('penghuni').get();
    final jumlahPenghuni = querySnapshot.docs.length;
    final ruanganTersedia = 48 - jumlahPenghuni;

    setState(() {
      _jumlahPenghuni = jumlahPenghuni;
      _ruanganTersedia = ruanganTersedia;
    });
  }

  Future<void> _fetchProfitLostData() async {
    final currentYear = DateTime.now().year;
    final currentMonth = DateTime.now().month;

    final doc = await FirebaseFirestore.instance
        .collection('anggaran')
        .doc('${currentYear}_${currentMonth}')
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        profit = data['profit'];
        lost = data['lost'];
        isProfit = profit > lost;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetOptions = <Widget>[
      RefreshIndicator(
        onRefresh: _refreshData,
        child: Dashboard(
          onInfoTap: _onItemTapped,
          ruanganTersedia: _ruanganTersedia,
          jumlahPenghuni: _jumlahPenghuni,
          profit: profit,
          lost: lost,
          isProfit: isProfit,
          isLoading: isLoading,
        ),
      ),
      PenghuniPage(),
      TransaksiPage(),
      PaymentMethodPage(),
      AnggaranPage(),
    ];

    return Scaffold(
      body: widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: Container(
        height: 70,
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: const Color(0xFFD33A53),
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
                icon: Icon(Icons.credit_card),
                label: 'Metode',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart),
                label: 'Anggaran',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: const Color.fromARGB(255, 255, 255, 255),
            unselectedItemColor:
                const Color.fromARGB(255, 255, 255, 255).withOpacity(0.5),
            onTap: _onItemTapped,
          ),
        ),
      ),
    );
  }
}

class Dashboard extends StatelessWidget {
  final Function(int) onInfoTap;
  final int jumlahPenghuni;
  final int ruanganTersedia;
  final double profit;
  final double lost;
  final bool isProfit;
  final bool isLoading;

  const Dashboard({
    Key? key,
    required this.onInfoTap,
    required this.jumlahPenghuni,
    required this.ruanganTersedia,
    required this.profit,
    required this.lost,
    required this.isProfit,
    required this.isLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _buildDashboardCard(
                    context,
                    'Kamar Tersedia',
                    '$ruanganTersedia',
                    Icons.home,
                    Color.fromARGB(255, 255, 255, 255),
                    () => onInfoTap(1),
                  ),
                  _buildDashboardCard(
                    context,
                    'Penghuni Kost',
                    '$jumlahPenghuni',
                    Icons.person,
                    Color.fromARGB(255, 255, 255, 255),
                    () => onInfoTap(1),
                  ),
                  _buildDashboardCard(
                    context,
                    'Pembayaran Bulan Ini',
                    'Rp1200000',
                    Icons.account_balance_wallet,
                    Color.fromARGB(255, 255, 255, 255),
                    () => onInfoTap(2),
                  ),
                  _buildDashboardCard(
                    context,
                    'Profit Bulan Ini',
                    isProfit
                        ? 'Rp${profit.toStringAsFixed(0)}'
                        : 'Rp${lost.toStringAsFixed(0)}',
                    isProfit ? Icons.arrow_circle_up : Icons.arrow_circle_down,
                    Color.fromARGB(255, 255, 255, 255),
                    () => onInfoTap(4),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDashboardCard(BuildContext context, String title, String value,
      IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(
            color: Color(0xFFD7D7D7),
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2.0,
              blurRadius: 8.0,
              offset: Offset(0, 5),
            ),
          ],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    icon,
                    size: 30,
                    color: const Color(0xFFD33A53),
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    title,
                    style: const TextStyle(fontSize: 14),
                  ),
                  Spacer(),
                  Row(
                    children: [
                      Text(
                        'Info Selengkapnya  ',
                        style: TextStyle(
                            color: Colors.black.withOpacity(0.3),
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                      Icon(
                        Icons.arrow_circle_right,
                        color: Colors.black.withOpacity(0.3),
                        size: 18,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 1),
              Row(
                children: [
                  SizedBox(width: 42),
                  Text(
                    value,
                    style: const TextStyle(
                        fontSize: 34, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
