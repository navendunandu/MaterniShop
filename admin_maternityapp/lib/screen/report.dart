import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class SalesReportPage extends StatefulWidget {
  const SalesReportPage({super.key});

  @override
  State<SalesReportPage> createState() => _SalesReportPageState();
}

class _SalesReportPageState extends State<SalesReportPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> _salesDataFuture;
  DateTime _startDate = DateTime(2025, 1, 1);
  DateTime _endDate = DateTime(2025, 6, 30);

  @override
  void initState() {
    super.initState();
    _salesDataFuture = fetchSalesData();
  }

  Future<List<Map<String, dynamic>>> fetchSalesData() async {
    try {
      final response = await supabase
          .from('tbl_booking')
          .select(
              'id, created_at, booking_amount, tbl_cart!inner(cart_qty, product_id, tbl_product!inner(product_price, product_name, shop_id, tbl_shop!inner(shop_name)))')
          .eq('booking_status', 1) // Assuming 1 = Completed
          .gte('created_at', _startDate.toIso8601String())
          .lte('created_at', _endDate.toIso8601String())
          .order('created_at', ascending: false);

      final salesData = (response as List).map((booking) {
        double totalAmount = 0.0;
        if (booking['booking_amount'] != null) {
          totalAmount = (booking['booking_amount'] as num?)?.toDouble() ?? 0.0;
        } else {
          for (var cart in booking['tbl_cart']) {
            final price =
                (cart['tbl_product']['product_price'] as num?)?.toDouble() ??
                    0.0;
            final qty = (cart['cart_qty'] as num?)?.toDouble() ?? 0.0;
            totalAmount += price * qty;
          }
        }

        // Get the shop name from the first cart item (assuming all items in a booking belong to the same shop)
        final shopName = booking['tbl_cart'].isNotEmpty
            ? booking['tbl_cart'][0]['tbl_product']['tbl_shop']['shop_name'] ??
                'Unknown Shop'
            : 'Unknown Shop';

        return {
          'booking_id': booking['id'].toString(),
          'date': DateTime.parse(booking['created_at']),
          'total_amount': totalAmount,
          'shop_name': shopName,
          'items': (booking['tbl_cart'] as List).map((cart) {
            return {
              'product_name': cart['tbl_product']['product_name'],
              'quantity': cart['cart_qty'],
              'price': cart['tbl_product']['product_price'],
            };
          }).toList(),
        };
      }).toList();

      return salesData;
    } catch (e) {
      print('Error fetching sales data: $e');
      return [];
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: _endDate,
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        _salesDataFuture = fetchSalesData();
      });
    }
  }

 Future<void> _selectEndDate(BuildContext context) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: _endDate,
    firstDate: _startDate, // Restrict to start date to ensure valid range
    lastDate: DateTime(2025, 12, 31), // Allow selecting up to the end of 2025
  );
  if (picked != null && picked != _endDate) {
    if (picked.isBefore(_startDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('End date cannot be before start date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() {
      _endDate = picked;
      _salesDataFuture = fetchSalesData();
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Sales Report",
            style: GoogleFonts.sanchez(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Start Date",
                    style: GoogleFonts.sanchez(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 5),
                  GestureDetector(
                    onTap: () => _selectStartDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('MMM dd, yyyy').format(_startDate),
                            style: GoogleFonts.sanchez(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "End Date",
                    style: GoogleFonts.sanchez(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 5),
                  GestureDetector(
                    onTap: () => _selectEndDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('MMM dd, yyyy').format(_endDate),
                            style: GoogleFonts.sanchez(
                              fontSize: 14,
                              color: Colors.black87,
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
          const SizedBox(height: 20),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _salesDataFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text(
                    "No sales data available for this period",
                    style: GoogleFonts.sanchez(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                );
              }

              final salesData = snapshot.data!;
              final totalSales = salesData.fold<double>(
                  0.0, (sum, sale) => sum + sale['total_amount']);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Total Sales: \Rs ${totalSales.toStringAsFixed(2)}",
                    style: GoogleFonts.sanchez(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 1.5, // Increased width to accommodate new columns
                      child: DataTable(
                        columnSpacing: 20,
                        headingRowColor: MaterialStateColor.resolveWith(
                            (states) => Colors.grey.shade100),
                        border: TableBorder(
                          horizontalInside: BorderSide(color: Colors.grey.shade300),
                          verticalInside: BorderSide(color: Colors.grey.shade300),
                          top: BorderSide(color: Colors.grey.shade300),
                          bottom: BorderSide(color: Colors.grey.shade300),
                          left: BorderSide(color: Colors.grey.shade300),
                          right: BorderSide(color: Colors.grey.shade300),
                        ),
                        columns: [
                          DataColumn(
                            label: Text(
                              "S.No",
                              style: GoogleFonts.sanchez(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              "Date",
                              style: GoogleFonts.sanchez(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              "Total Amount",
                              style: GoogleFonts.sanchez(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              "Product Name",
                              style: GoogleFonts.sanchez(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              "Quantity",
                              style: GoogleFonts.sanchez(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              "Price",
                              style: GoogleFonts.sanchez(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              "Shop Name",
                              style: GoogleFonts.sanchez(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                        rows: salesData.asMap().entries.expand((entry) {
                          int index = entry.key;
                          var sale = entry.value;
                          List<DataRow> rows = [];
                          for (int i = 0; i < sale['items'].length; i++) {
                            var item = sale['items'][i];
                            rows.add(DataRow(cells: [
                              DataCell(
                                Text(
                                  i == 0 ? "${index + 1}" : "", // Show S.No only for the first item
                                  style: GoogleFonts.sanchez(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  i == 0
                                      ? DateFormat('MMM dd, yyyy').format(sale['date'])
                                      : "", // Show Date only for the first item
                                  style: GoogleFonts.sanchez(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  i == 0
                                      ? "\Rs ${sale['total_amount'].toStringAsFixed(2)}"
                                      : "", // Show Total Amount only for the first item
                                  style: GoogleFonts.sanchez(
                                    fontSize: 14,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  item['product_name'],
                                  style: GoogleFonts.sanchez(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  item['quantity'].toString(),
                                  style: GoogleFonts.sanchez(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  "\Rs ${(item['price'] as num?)?.toDouble().toStringAsFixed(2) ?? '0.00'}",
                                  style: GoogleFonts.sanchez(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  i == 0
                                      ? sale['shop_name']
                                      : "", // Show Shop Name only for the first item
                                  style: GoogleFonts.sanchez(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ]));
                          }
                          return rows;
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}