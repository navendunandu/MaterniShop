import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:shop_maternityapp/main.dart';
import 'dart:typed_data';
import 'dart:html' as html;
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

class OrderDetailsPage extends StatefulWidget {
  final int bid;
  const OrderDetailsPage({super.key, required this.bid});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  List<Map<String, dynamic>> orderItems = [];
  Map<String, dynamic>? userDetails;
  bool isLoadingUserDetails = true;

  Future<void> fetchItems() async {
    try {
      // Retrieve the logged-in shop's ID
      final shopId = supabase.auth.currentUser!.id;
      if (shopId == null) {
        throw Exception('Shop ID not found for the logged-in user');
      }

      // Fetch cart items for the booking, filtered by shop_id
      final response = await supabase
          .from('tbl_cart')
          .select('''
            id, cart_qty, cart_status, product_id,
            tbl_product!inner(product_id, product_name, product_image, product_price, shop_id)
          ''')
          .eq('booking_id', widget.bid)
          .eq('tbl_product.shop_id', shopId);

      List<Map<String, dynamic>> items = [];
      for (var item in response) {
        int total = item['tbl_product']['product_price'] * item['cart_qty'];
        items.add({
          'id': item['id'],
          'pid': item['tbl_product']['product_id'],
          'product': item['tbl_product']['product_name'],
          'image': item['tbl_product']['product_image'],
          'qty': item['cart_qty'],
          'price': item['tbl_product']['product_price'],
          'total': total,
          'status': item['cart_status'],
        });
      }
      setState(() {
        orderItems = items;
      });
    } catch (e) {
      print("Error fetching items: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load order items: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> fetchUserDetails() async {
    try {
      final bookingData = await supabase
          .from('tbl_booking')
          .select('user_id')
          .eq('id', widget.bid)
          .single();

      final userData = await supabase
          .from('tbl_user')
          .select('*')
          .eq('id', bookingData['user_id'])
          .single();

      setState(() {
        userDetails = userData;
        isLoadingUserDetails = false;
      });
    } catch (e) {
      print("Error fetching user details: $e");
      setState(() {
        isLoadingUserDetails = false;
      });
    }
  }

  Map<String, String> getShopDetails() {
    return {
      'name': 'Maternity Care Shop',
      'address': '123 Maternal Avenue, Health District',
      'city': ' Wellness City',
      'state': 'Care State',
      'zip': '54321',
      'phone': '+1 (555) 123-4567',
      'email': 'shop@maternitycare.com',
    };
  }

  Future<void> update(int id, int status) async {
    try {
      await supabase.from('tbl_cart').update({'cart_status': status + 1}).eq('id', id);
      await fetchItems();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Status Updated"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error updating status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _downloadBillPdf(Map<String, dynamic> item) async {
    // Fetch shop and user data
    final data = await supabase
        .from('tbl_product')
        .select("tbl_shop(shop_name, shop_address, shop_contact)")
        .eq('product_id', item['pid'])
        .single();
    final response = await supabase
        .from('tbl_cart')
        .select("tbl_booking(tbl_user(*))")
        .eq('id', item['id'])
        .single();

    // Extract shop details
    final shop = data['tbl_shop'] ?? {};
    final shopName = shop['shop_name'] ?? 'Maternity Care Shop';
    final shopAddress = shop['shop_address'] ?? '123 Maternal Avenue, Health District';
    final shopContact = shop['shop_contact'] ?? '+1 (555) 123-4567';

    // Extract user details
    final user = response['tbl_booking']?['tbl_user'] ?? {};
    final userName = user['user_name'] ?? 'Unknown';
    final userAddress = user['user_address'] ?? '';
    final userContact = user['user_contact'] ?? 'N/A';
    final userEmail = user['user_email'] ?? 'N/A';

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(24),
        build: (context) => pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColor.fromHex('#cccccc'), width: 2),
            borderRadius: pw.BorderRadius.circular(12),
          ),
          padding: const pw.EdgeInsets.all(24),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header: Shop details and QR
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        shopName,
                        style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        shopAddress,
                        style: pw.TextStyle(fontSize: 10),
                      ),
                      pw.Text(
                        'Contact: $shopContact',
                        style: pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                  pw.BarcodeWidget(
                    barcode: pw.Barcode.qrCode(),
                    data: 'OrderID: ${item['id']}',
                    width: 50,
                    height: 50,
                  ),
                ],
              ),
              pw.Divider(thickness: 1.2),
              pw.SizedBox(height: 10),

              // Bill Title and Date
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Order Bill',
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    'Date: ${DateFormat('MMM dd, yyyy').format(DateTime.now())}',
                    style: pw.TextStyle(fontSize: 12),
                  ),
                ],
              ),
              pw.SizedBox(height: 16),

              // User Details
              pw.Text(
                'Customer Details:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
              ),
              pw.Text(
                'Name: $userName',
                style: pw.TextStyle(fontSize: 11),
              ),
              if (userAddress.isNotEmpty)
                pw.Text(
                  'Address: $userAddress',
                  style: pw.TextStyle(fontSize: 11),
                ),
              pw.Text(
                'Contact: $userContact',
                style: pw.TextStyle(fontSize: 11),
              ),
              pw.Text(
                'Email: $userEmail',
                style: pw.TextStyle(fontSize: 11),
              ),
              pw.SizedBox(height: 12),

              // Product Table
              pw.Table(
                border: pw.TableBorder.all(color: PdfColor.fromHex('#cccccc')),
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColor.fromHex('#f2f2f2')),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          'Product',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          'Qty',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          'Price',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          'Total',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('${item['product']}'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('${item['qty']}'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('Rs.${item['price'].toStringAsFixed(2)}'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('Rs.${item['total'].toStringAsFixed(2)}'),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 18),

              // Status
              pw.Text(
                'Order Status: ${_getStatusText(item['status'])}',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 12,
                  color: PdfColor.fromHex('#388e3c'),
                ),
              ),

              pw.Spacer(),
              pw.Divider(),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  'Thank you for shopping with us!',
                  style: pw.TextStyle(fontSize: 12, fontStyle: pw.FontStyle.italic),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final Uint8List bytes = await pdf.save();

    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'bill_${item['id']}.pdf')
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  String _getStatusText(int status) {
    switch (status) {
      case 1:
        return 'Confirmed';
      case 2:
        return 'Order Packed';
      case 3:
        return 'Order Complete';
      case 4:
        return 'Order Cancelled';
      default:
        return 'Unknown';
    }
  }

  @override
  void initState() {
    super.initState();
    fetchItems();
    fetchUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 245, 245, 250),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Order Details",
              style: GoogleFonts.sanchez(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: orderItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: 60,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 10),
                            Text(
                              "No items from your shop in this order",
                              style: GoogleFonts.sanchez(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: orderItems.length,
                        itemBuilder: (context, index) {
                          final item = orderItems[index];
                          return _buildOrderItemCard(item);
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemCard(Map<String, dynamic> item) {
    Color statusColor;
    String status = "";
    String btn = "";
    switch (item['status']) {
      case 1:
        statusColor = Colors.blue;
        status = "Confirmed";
        btn = "Order Packed";
        break;
      case 2:
        statusColor = Colors.orange;
        status = "Order Packed";
        btn = "Order Completed";
        break;
      case 3:
        statusColor = Colors.green;
        status = "Order Complete";
        break;
      case 4:
        statusColor = Colors.red;
        status = "Order Cancelled";
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      elevation: 0,
      color: Colors.grey[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      margin: EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item['image'],
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.image_not_supported,
                  size: 80,
                  color: Colors.grey[400],
                ),
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['product'],
                    style: GoogleFonts.sanchez(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        "Qty: ${item['qty']}",
                        style: GoogleFonts.sanchez(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(width: 20),
                      Text(
                        "Price: Rs.${item['price'].toStringAsFixed(2)}",
                        style: GoogleFonts.sanchez(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Total: Rs.${item['total'].toStringAsFixed(2)}",
                    style: GoogleFonts.sanchez(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                if (item['status'] != 3 && item['status'] != 4)
                  SizedBox(
                    height: 40,
                    width: 120,
                    child: ElevatedButton(
                      onPressed: () {
                        update(item['id'], item['status']);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 198, 176, 249),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        btn,
                        style: GoogleFonts.sanchez(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                SizedBox(height: 10),
                if (item['status'] == 3)
                  SizedBox(
                    height: 40,
                    width: 120,
                    child: ElevatedButton(
                      onPressed: () {
                        _downloadBillPdf(item);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Download Bill",
                        style: GoogleFonts.sanchez(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
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
}