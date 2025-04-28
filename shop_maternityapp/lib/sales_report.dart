import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';
import 'dart:html' as html;

class SalesReportPage extends StatefulWidget {
  const SalesReportPage({super.key});

  @override
  State<SalesReportPage> createState() => _SalesReportPageState();
}

class _SalesReportPageState extends State<SalesReportPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> _salesDataFuture;
  DateTime _startDate = DateTime(2025, 1, 1);
  DateTime _endDate = DateTime.now(); // Always set to today by default

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
              'id, created_at, booking_amount, tbl_cart!inner(cart_qty, product_id, tbl_product!inner(product_price, product_name, shop_id))')
          .eq('tbl_cart.tbl_product.shop_id', supabase.auth.currentUser!.id)
          .eq('booking_status', 1)
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

        return {
          'booking_id': booking['id'].toString(),
          'date': DateTime.parse(booking['created_at']),
          'total_amount': totalAmount,
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
      lastDate: DateTime.now(), // <-- Only allow up to today
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
      firstDate: _startDate,
      lastDate: DateTime.now(), // <-- Only allow up to today
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
        _salesDataFuture = fetchSalesData();
      });
    }
  }

  Future<void> _generateAndDownloadPdf(List<Map<String, dynamic>> salesData) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text('Sales Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 16),
          pw.Table.fromTextArray(
            headers: ['Sl. No.', 'Date', 'Product', 'Quantity', 'Price', 'Total Amount'],
            data: [
              for (int i = 0; i < salesData.length; i++)
                ...salesData[i]['items'].asMap().entries.map((entry) {
                  final item = entry.value;
                  final sale = salesData[i];
                  final itemTotal = ((item['price'] as num?)?.toDouble() ?? 0.0) *
                      (item['quantity'] as num?)!.toDouble();
                  return [
                    '${i + 1}',
                    DateFormat('MMM dd, yyyy').format(sale['date']),
                    item['product_name'],
                    '${item['quantity']}',
                    'Rs${(item['price'] as num?)?.toDouble().toStringAsFixed(2) ?? '0.00'}'
                    'Rs ${itemTotal.toStringAsFixed(2)}',
                  ];
                }),
            ],
          ),
        ],
      ),
    );

    // Save PDF as bytes
    final Uint8List bytes = await pdf.save();

    // Trigger download in browser
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'sales_report.pdf')
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
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
                ElevatedButton.icon(
                  icon: const Icon(Icons.download),
                  label: const Text("Download as PDF"),
                  onPressed: () async {
                    final salesData = await _salesDataFuture;
                    await _generateAndDownloadPdf(salesData);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 20),
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
                      "Total Sales: Rs ${totalSales.toStringAsFixed(2)}",
                      style: GoogleFonts.sanchez(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
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
                              "Sl. No.",
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
                              "Product",
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
                              "Total Amount",
                              style: GoogleFonts.sanchez(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                        rows: [
                          for (int i = 0; i < salesData.length; i++)
                            ...salesData[i]['items'].asMap().entries.map((entry) {
                              final item = entry.value;
                              final sale = salesData[i];
                              final itemTotal = ((item['price'] as num?)?.toDouble() ?? 0.0) *
                                  (item['quantity'] as num?)!.toDouble();
                              return DataRow(cells: [
                                DataCell(
                                  Text(
                                    '${i + 1}',
                                    style: GoogleFonts.sanchez(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    DateFormat('MMM dd, yyyy').format(sale['date']),
                                    style: GoogleFonts.sanchez(
                                      fontSize: 14,
                                      color: Colors.black87,
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
                                    '${item['quantity']}',
                                    style: GoogleFonts.sanchez(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    "Rs ${(item['price'] as num?)?.toDouble().toStringAsFixed(2) ?? '0.00'}",
                                    style: GoogleFonts.sanchez(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    "Rs${itemTotal.toStringAsFixed(2)}",
                                    style: GoogleFonts.sanchez(
                                      fontSize: 14,
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                              ]);
                            }),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}