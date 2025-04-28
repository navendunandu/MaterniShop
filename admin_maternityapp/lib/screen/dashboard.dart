import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fl_chart/fl_chart.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final SupabaseClient supabase = Supabase.instance.client;
  late Future<int> _userCountFuture;
  late Future<int> _shopCountFuture;
  late Future<int> _bookingCountFuture;
  late Future<double> _totalSalesFuture;
  late Future<List<FlSpot>> _salesChartDataFuture;

  @override
  void initState() {
    super.initState();
    _userCountFuture = fetchUserCount();
    _shopCountFuture = fetchShopCount();
    _bookingCountFuture = fetchBookingCount();
    _totalSalesFuture = fetchTotalSales();
    _salesChartDataFuture = fetchSalesChartData();
  }

  Future<int> fetchUserCount() async {
    try {
      final response = await supabase
          .from('tbl_user')
          .select('id')
          .count(CountOption.exact);
      return response.count;
    } catch (e) {
      print('Error fetching user count: $e');
      return 0;
    }
  }

  Future<int> fetchShopCount() async {
    try {
      final response = await supabase
          .from('tbl_shop')
          .select('shop_id')
          .count(CountOption.exact);
      return response.count;
    } catch (e) {
      print('Error fetching shop count: $e');
      return 0;
    }
  }

  Future<int> fetchBookingCount() async {
    try {
      final response = await supabase
          .from('tbl_booking')
          .select('id')
          .count(CountOption.exact);
      return response.count;
    } catch (e) {
      print('Error fetching booking count: $e');
      return 0;
    }
  }

  Future<double> fetchTotalSales() async {
    try {
      final response = await supabase
          .from('tbl_booking')
          .select('booking_amount, tbl_cart!inner(cart_qty, product_id, tbl_product!inner(product_price))')
          .eq('booking_status', 1);

      double totalSales = 0.0;
      for (var booking in response) {
        if (booking['booking_amount'] != null) {
          totalSales += (booking['booking_amount'] as num?)?.toDouble() ?? 0.0;
        } else {
          for (var cart in booking['tbl_cart']) {
            final price = (cart['tbl_product']['product_price'] as num?)?.toDouble() ?? 0.0;
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
          .select('created_at, booking_amount, tbl_cart!inner(cart_qty, product_id, tbl_product!inner(product_price))')
          .eq('booking_status', 1)
          .gte('created_at', '2025-01-01')
          .lte('created_at', '2025-12-31');

      final monthlySales = List<double>.filled(12, 0.0);
      for (var booking in response) {
        final createdAt = DateTime.parse(booking['created_at']);
        final monthIndex = createdAt.month - 1;
        if (monthIndex < 0 || monthIndex > 11) continue;

        double saleAmount = 0.0;
        if (booking['booking_amount'] != null) {
          saleAmount = (booking['booking_amount'] as num?)?.toDouble() ?? 0.0;
        } else {
          for (var cart in booking['tbl_cart']) {
            final price = (cart['tbl_product']['product_price'] as num?)?.toDouble() ?? 0.0;
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
          12, (index) => FlSpot(index.toDouble(), normalizedSales[index]));
    } catch (e) {
      print('Error fetching sales chart data: $e');
      return List.generate(12, (index) => FlSpot(index.toDouble(), 0.0));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Admin Dashboard",
            style: GoogleFonts.sanchez(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: FutureBuilder<int>(
                  future: _userCountFuture,
                  builder: (context, snapshot) {
                    return _buildStatCard(
                      title: "Total Users",
                      value: snapshot.data?.toString() ?? '0',
                      icon: Icons.person,
                      color: Colors.blue,
                    );
                  },
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: FutureBuilder<int>(
                  future: _shopCountFuture,
                  builder: (context, snapshot) {
                    return _buildStatCard(
                      title: "Total Shops",
                      value: snapshot.data?.toString() ?? '0',
                      icon: Icons.store,
                      color: Colors.purple,
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
                      title: "Total Bookings",
                      value: snapshot.data?.toString() ?? '0',
                      icon: Icons.calendar_month,
                      color: Colors.orange,
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
          const SizedBox(height: 20),
          Container(
            height: 400,
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
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return const Center(child: Text("Error loading chart"));
                      }
                      final spots = snapshot.data ??
                          List.generate(12, (index) => FlSpot(index.toDouble(), 0.0));

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
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  const titles = [
                                    'Jan',
                                    'Feb',
                                    'Mar',
                                    'Apr',
                                    'May',
                                    'Jun',
                                    'Jul',
                                    'Aug',
                                    'Sep',
                                    'Oct',
                                    'Nov',
                                    'Dec'
                                  ];
                                  int index = value.toInt();
                                  if (index < 0 || index >= titles.length) {
                                    return const Text('');
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      titles[index],
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  );
                                },
                                reservedSize: 30,
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
                              color: const Color.fromARGB(255, 198, 176, 249),
                              barWidth: 3,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: const Color.fromARGB(255, 198, 176, 249)
                                    .withOpacity(0.2),
                              ),
                            ),
                          ],
                          minX: 0,
                          maxX: 11,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
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
}