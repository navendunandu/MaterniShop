import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shop_maternityapp/landingpage.dart';
import 'package:shop_maternityapp/myaccount.dart';
import 'package:shop_maternityapp/orders.dart';
import 'package:shop_maternityapp/products.dart';
import 'package:shop_maternityapp/sales_report.dart';
import 'package:shop_maternityapp/view_complaints.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    DashboardHomeTab(),
    ProductManagementPage(),
    BookingManagementPage(),
    ComplaintsPage(),
    AccountManagementPage(),
    SalesReportPage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          NavigationRail(
            extended: MediaQuery.of(context).size.width > 1200,
            minExtendedWidth: 230,
            backgroundColor: Color.fromARGB(255, 198, 176, 249),
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            leading: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.baby_changing_station,
                      color: Colors.white, size: 24),
                  SizedBox(width: 8),
                  if (MediaQuery.of(context).size.width > 1200)
                    Text(
                      "MaterniShop",
                      style: GoogleFonts.aclonica(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
            trailing: Padding(
              padding: const EdgeInsets.all(16.0),
              child: IconButton(
                icon: Icon(Icons.logout, color: Colors.white),
                onPressed: () {
                  // Logout logic
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LandingPage(),
                    ),
                  );
                },
              ),
            ),
            labelType: NavigationRailLabelType.none,
            destinations: [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard, color: Colors.white70),
                selectedIcon: Icon(Icons.dashboard, color: Colors.white),
                label: Text(
                  'Dashboard',
                  style: GoogleFonts.sanchez(color: Colors.white),
                ),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.inventory_2, color: Colors.white70),
                selectedIcon: Icon(Icons.inventory_2, color: Colors.white),
                label: Text(
                  'Products',
                  style: GoogleFonts.sanchez(color: Colors.white),
                ),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.calendar_month, color: Colors.white70),
                selectedIcon: Icon(Icons.calendar_month, color: Colors.white),
                label: Text(
                  'Bookings',
                  style: GoogleFonts.sanchez(color: Colors.white),
                ),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.comment, color: Colors.white70),
                selectedIcon: Icon(Icons.comment, color: Colors.white),
                label: Text(
                  'Complaints',
                  style: GoogleFonts.sanchez(color: Colors.white),
                ),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person, color: Colors.white70),
                selectedIcon: Icon(Icons.person, color: Colors.white),
                label: Text(
                  'Account',
                  style: GoogleFonts.sanchez(color: Colors.white),
                ),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person, color: Colors.white70),
                selectedIcon: Icon(Icons.person, color: Colors.white),
                label: Text(
                  'Report',
                  style: GoogleFonts.sanchez(color: Colors.white),
                ),
              ),
            ],
          ),

          // Main Content
          Expanded(
            child: _pages[_selectedIndex],
          ),
        ],
      ),
    );
  }
}

class DashboardHomeTab extends StatefulWidget {
  const DashboardHomeTab({super.key});

  @override
  State<DashboardHomeTab> createState() => _DashboardHomeTabState();
}

class _DashboardHomeTabState extends State<DashboardHomeTab> {
  final SupabaseClient supabase = Supabase.instance.client;
  late Future<int> _productCountFuture;
  late Future<int> _bookingCountFuture;
  late Future<int> _complaintCountFuture;
  late Future<double> _totalSalesFuture;
  late Future<List<FlSpot>> _salesChartDataFuture;
  late Future<List<Map<String, dynamic>>> _categoryDataFuture;

  @override
  void initState() {
    super.initState();
    _productCountFuture = fetchProductCount();
    _bookingCountFuture = fetchBookingCount();
    _complaintCountFuture = fetchComplaintCount();
    _totalSalesFuture = fetchTotalSales();
    _salesChartDataFuture = fetchSalesChartData();
    _categoryDataFuture = fetchCategoryData();
  }

  Future<int> fetchProductCount() async {
    try {
      final response = await supabase
          .from('tbl_product')
          .select('product_id')
          .eq('shop_id', supabase.auth.currentUser!.id)
          .count(CountOption.exact);
      return response.count;
    } catch (e) {
      print('Error fetching product count: $e');
      return 0;
    }
  }

  Future<int> fetchBookingCount() async {
    try {
      final cartResponse = await supabase
          .from('tbl_cart')
          .select('booking_id, tbl_product!inner(product_id, shop_id)')
          .eq('tbl_product.shop_id', supabase.auth.currentUser!.id);

      final bookingIds = (cartResponse as List)
          .map((cart) => cart['booking_id'].toString())
          .toSet()
          .toList();

      if (bookingIds.isEmpty) return 0;

      final response = await supabase
          .from('tbl_booking')
          .select('id')
          .eq('booking_status', 1)
          .inFilter('id', bookingIds)
          .count(CountOption.exact);

      return response.count;
    } catch (e) {
      print('Error fetching booking count: $e');
      return 0;
    }
  }

  Future<int> fetchComplaintCount() async {
    try {
      final response = await supabase
          .from('tbl_complaint')
          .select('complaint_id, tbl_product!inner(product_id, shop_id)')
          .eq('complaint_status', 0)
          .eq('tbl_product.shop_id', supabase.auth.currentUser!.id)
          .count(CountOption.exact);
      return response.count;
    } catch (e) {
      print('Error fetching complaint count: $e');
      return 0;
    }
  }

  Future<double> fetchTotalSales() async {
    try {
      final response = await supabase
          .from('tbl_booking')
          .select(
              'booking_amount, tbl_cart!inner(cart_qty, product_id, tbl_product!inner(product_price, shop_id))')
          .eq('tbl_cart.tbl_product.shop_id', supabase.auth.currentUser!.id)
          .eq('booking_status', 1);

      double totalSales = 0.0;
      for (var booking in response) {
        if (booking['booking_amount'] != null) {
          totalSales += (booking['booking_amount'] as num?)?.toDouble() ?? 0.0;
        } else {
          for (var cart in booking['tbl_cart']) {
            final price =
                (cart['tbl_product']['product_price'] as num?)?.toDouble() ??
                    0.0;
            final qty = (cart['cart_qty'] as num?)?.toDouble() ?? 0.0;
            totalSales += price * qty;
          }
        }
      }
      return totalSales;
    } catch (e) {
      print('Error fetching total sales: $e');
      return 0.0;
    }
  }

  Future<List<FlSpot>> fetchSalesChartData() async {
    try {
      final response = await supabase
          .from('tbl_booking')
          .select(
              'created_at, booking_amount, tbl_cart!inner(cart_qty, product_id, tbl_product!inner(product_price, shop_id))')
          .eq('tbl_cart.tbl_product.shop_id', supabase.auth.currentUser!.id)
          .eq('booking_status', 1)
          .gte('created_at', '2025-01-01')
          .lte('created_at', '2025-06-30');

      final monthlySales = List<double>.filled(6, 0.0);
      for (var booking in response) {
        final createdAt = DateTime.parse(booking['created_at']);
        final monthIndex = createdAt.month - 1;
        if (monthIndex < 0 || monthIndex > 5) continue;

        double saleAmount = 0.0;
        if (booking['booking_amount'] != null) {
          saleAmount = (booking['booking_amount'] as num?)?.toDouble() ?? 0.0;
        } else {
          for (var cart in booking['tbl_cart']) {
            final price =
                (cart['tbl_product']['product_price'] as num?)?.toDouble() ??
                    0.0;
            final qty = (cart['cart_qty'] as num?)?.toDouble() ?? 0.0;
            saleAmount += price * qty;
          }
        }
        monthlySales[monthIndex] += saleAmount;
      }

      final maxSale = monthlySales.reduce((a, b) => a > b ? a : b);
      final normalizedSales = maxSale > 0
          ? monthlySales.map((sale) => (sale / maxSale) * 5).toList()
          : monthlySales;

      return List.generate(
          6, (index) => FlSpot(index.toDouble(), normalizedSales[index]));
    } catch (e) {
      print('Error fetching sales chart data: $e');
      return List.generate(6, (index) => FlSpot(index.toDouble(), 0.0));
    }
  }

  Future<List<Map<String, dynamic>>> fetchCategoryData() async {
    try {
      final response = await supabase
          .from('tbl_product')
          .select(
              'subcategory_id, tbl_subcategory!inner(subcategory_name, category_id, tbl_category!inner(category_name))')
          .eq('shop_id', supabase.auth.currentUser!.id);

      // Aggregate product counts by category
      final categoryCounts = <String, int>{};
      final categoryNames = <String, String>{};

      for (var product in response) {
        final categoryName =
            product['tbl_subcategory']['tbl_category']['category_name'] as String;
        final categoryId =
            product['tbl_subcategory']['category_id'].toString();
        categoryCounts[categoryId] = (categoryCounts[categoryId] ?? 0) + 1;
        categoryNames[categoryId] = categoryName;
      }

      final totalProducts = categoryCounts.values.reduce((a, b) => a + b);
      final categoryData = categoryCounts.entries.map((entry) {
        final percentage = (entry.value / totalProducts) * 100;
        return {
          'category_id': entry.key,
          'category_name': categoryNames[entry.key]!,
          'count': entry.value,
          'percentage': percentage,
        };
      }).toList();

      return categoryData;
    } catch (e) {
      print('Error fetching category data: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 245, 250),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Dashboard",
                      style: GoogleFonts.sanchez(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      "Welcome back, Shop Owner!",
                      style: GoogleFonts.sanchez(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_none),
                      onPressed: () {},
                    ),
                    const SizedBox(width: 10),
                    const CircleAvatar(
                      backgroundColor: Color.fromARGB(255, 198, 176, 249),
                      child: Text(
                        "SO",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: FutureBuilder<int>(
                    future: _productCountFuture,
                    builder: (context, snapshot) {
                      return _buildStatCard(
                        title: "Total Products",
                        value: snapshot.data?.toString() ?? '0',
                        icon: Icons.inventory_2,
                        color: Colors.blue,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: FutureBuilder<int>(
                    future: _bookingCountFuture,
                    builder: (context, snapshot) {
                      return _buildStatCard(
                        title: "Pending Bookings",
                        value: snapshot.data?.toString() ?? '0',
                        icon: Icons.calendar_month,
                        color: Colors.orange,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: FutureBuilder<int>(
                    future: _complaintCountFuture,
                    builder: (context, snapshot) {
                      return _buildStatCard(
                        title: "New Complaints",
                        value: snapshot.data?.toString() ?? '0',
                        icon: Icons.comment,
                        color: Colors.red,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: FutureBuilder<double>(
                    future: _totalSalesFuture,
                    builder: (context, snapshot) {
                      return _buildStatCard(
                        title: "Total Sales",
                        value: snapshot.data != null
                            ? '\Rs ${snapshot.data!.toStringAsFixed(2)}'
                            : '\$0.00',
                        icon: Icons.attach_money,
                        color: Colors.green,
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 350,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Sales Overview",
                          style: GoogleFonts.sanchez(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: FutureBuilder<List<FlSpot>>(
                            future: _salesChartDataFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              if (snapshot.hasError) {
                                return const Center(
                                    child: Text("Error loading chart"));
                              }
                              final spots = snapshot.data ??
                                  List.generate(6,
                                      (index) => FlSpot(index.toDouble(), 0.0));

                              return LineChart(
                                LineChartData(
                                  gridData: const FlGridData(show: false),
                                  titlesData: FlTitlesData(
                                    leftTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          const titles = [
                                            'Jan',
                                            'Feb',
                                            'Mar',
                                            'Apr',
                                            'May',
                                            'Jun'
                                          ];
                                          if (value.toInt() < 0 ||
                                              value.toInt() >= titles.length) {
                                            return const Text('');
                                          }
                                          return Text(
                                            titles[value.toInt()],
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    rightTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    topTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: spots,
                                      isCurved: true,
                                      color: const Color.fromARGB(
                                          255, 198, 176, 249),
                                      barWidth: 3,
                                      dotData: const FlDotData(show: false),
                                      belowBarData: BarAreaData(
                                        show: true,
                                        color: const Color.fromARGB(
                                                255, 198, 176, 249)
                                            .withOpacity(0.2),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Container(
                    height: 350,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Product Categories",
                          style: GoogleFonts.sanchez(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: FutureBuilder<List<Map<String, dynamic>>>(
                            future: _categoryDataFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                                return const Center(
                                    child: Text("No category data available"));
                              }

                              final categoryData = snapshot.data!;
                              final colors = [
                                Colors.blue,
                                Colors.pink,
                                Colors.green,
                                Colors.orange,
                                Colors.purple,
                                Colors.teal,
                              ];

                              return Column(
                                children: [
                                  Expanded(
                                    child: PieChart(
                                      PieChartData(
                                        sectionsSpace: 2,
                                        centerSpaceRadius: 40,
                                        sections: categoryData
                                            .asMap()
                                            .entries
                                            .map((entry) {
                                          final index = entry.key;
                                          final category = entry.value;
                                          return PieChartSectionData(
                                            color: colors[index % colors.length],
                                            value: category['count'].toDouble(),
                                            title:
                                                '${category['percentage'].toStringAsFixed(1)}%',
                                            radius: 50,
                                            titleStyle: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  ...categoryData.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final category = entry.value;
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 5.0),
                                      child: _buildCategoryLegend(
                                        color: colors[index % colors.length],
                                        label: category['category_name'],
                                        percentage:
                                            '${category['percentage'].toStringAsFixed(1)}%',
                                      ),
                                    );
                                  }).toList(),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 30,
            ),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.sanchez(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 5),
              Text(
                value,
                style: GoogleFonts.sanchez(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryLegend({
    required Color color,
    required String label,
    required String percentage,
  }) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.sanchez(
            fontSize: 12,
            color: Colors.grey[700],
          ),
        ),
        const Spacer(),
        Text(
          percentage,
          style: GoogleFonts.sanchez(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
