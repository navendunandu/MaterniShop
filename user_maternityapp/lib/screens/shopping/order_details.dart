import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:user_maternityapp/main.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:user_maternityapp/screens/shopping/post_complaint.dart';
import 'package:user_maternityapp/screens/shopping/rating.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class OrderDetailsPage extends StatefulWidget {
  final int orderId;
  final int cartId;

  const OrderDetailsPage({super.key, required this.orderId, required this.cartId});

  @override
  _OrderDetailsPageState createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  Map<String, dynamic>? orderDetails;
  Map<String, dynamic> orderItems = {};
  Map<String, dynamic>? shopDetails;
  Map<String, dynamic>? userDetails;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrderDetails();
  }

  Future<void> fetchOrderDetails() async {
    try {
      final orderResponse = await supabase
          .from('tbl_booking')
          .select()
          .eq('id', widget.orderId)
          .single();

      final itemsResponse = await supabase
          .from('tbl_cart')
          .select('*, tbl_product(*)')
          .eq('id', widget.cartId)
          .single();
      Map<String, dynamic> items = {
        "id": itemsResponse['id'],
        "product_id": itemsResponse['product_id'],
        "name": itemsResponse['tbl_product']['product_name'],
        "image": itemsResponse['tbl_product']['product_image'],
        "price": itemsResponse['tbl_product']['product_price'],
        "quantity": itemsResponse['cart_qty'],
        "status": itemsResponse['cart_status'],
        "shop_id": itemsResponse['tbl_product']['shop_id'],
      };

      final shopResponse = await supabase
          .from('tbl_shop')
          .select('*')
          .eq('shop_id', items['shop_id'])
          .single();

      final userResponse = await supabase
          .from('tbl_user')
          .select('*')
          .eq('id', orderResponse['user_id'])
          .single();

      setState(() {
        orderDetails = orderResponse;
        orderItems = items;
        shopDetails = shopResponse;
        userDetails = userResponse;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching order details: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String getOrderStatusText(int status) {
    switch (status) {
      case 1:
        return 'Processing';
      case 2:
        return 'Shipped';
      case 3:
        return 'Delivered';
      case 4:
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  Color getOrderStatusColor(int status) {
    switch (status) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.green;
      case 4:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _generateAndDownloadBill() async {
    final pdf = pw.Document();

    final orderDate = DateTime.parse(orderDetails!['created_at']);
    final formattedDate = DateFormat('MMMM dd, yyyy').format(orderDate);
    final formattedTime = DateFormat('hh:mm a').format(orderDate);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("Maternishop", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
  pw.SizedBox(height: 8),
                    pw.Text(shopDetails != null ? "${shopDetails!['shop_name']}" : "Shop Name",
                        style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 5),
                    pw.Text(shopDetails != null ? "${shopDetails!['shop_address']}" : "Shop Address"),
                    pw.Text(shopDetails != null ? "Phone: ${shopDetails!['shop_contact']}" : "Phone: Not available"),
                    pw.Text(shopDetails != null ? "Email: ${shopDetails!['shop_email']}" : "Email: Not available"),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text("INVOICE", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                    pw.Text("Order #${widget.orderId}"),
                    pw.Text("Date: $formattedDate"),
                    pw.Text("Time: $formattedTime"),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 30),
            pw.Container(
              padding: pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(width: 1),
                borderRadius: pw.BorderRadius.circular(5),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("BILL TO:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 5),
                  pw.Text(userDetails != null ? "${userDetails!['user_name']}" : "Customer"),
                  pw.Text("Address: ${userDetails?['user_address'] ?? 'Not available'}"),
                  pw.Text(userDetails != null ? "Phone: ${userDetails!['user_contact'] ?? 'Not available'}" : "Phone: Not available"),
                  pw.Text(userDetails != null ? "Email: ${userDetails!['user_email'] ?? 'Not available'}" : "Email: Not available"),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text("Order Status: ${getOrderStatusText(orderItems['status'])}",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            pw.Table(
              border: pw.TableBorder.all(),
              children: [
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text("Product", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text("Quantity", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text("Unit Price", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text("Total", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text(orderItems['name']),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text("${orderItems['quantity']}"),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text("Rs.${orderItems['price']}"),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text("Rs.${orderItems['price'] * orderItems['quantity']}"),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Container(
              alignment: pw.Alignment.centerRight,
              child: pw.Container(
                width: 200,
                child: pw.Column(
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text("Subtotal:"),
                        pw.Text("Rs.${orderItems['price'] * orderItems['quantity']}"),
                      ],
                    ),
                    pw.Divider(),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text("TOTAL:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text("Rs.${orderItems['price'] * orderItems['quantity']}",
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            pw.SizedBox(height: 40),
            pw.Center(
              child: pw.Text("Thank you for your business!", style: pw.TextStyle(fontStyle: pw.FontStyle.italic)),
            ),
          ],
        ),
      ),
    );

    final directory = await getExternalStorageDirectory();
    final file = File("${directory!.path}/Order_${widget.orderId}_Bill.pdf");
    await file.writeAsBytes(await pdf.save());

    OpenFile.open(file.path);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Bill downloaded to ${file.path}")),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Order Details"),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF64B5F6))),
      );
    }

    if (orderDetails == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Order Details"),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: Center(child: Text("Order not found")),
      );
    }

    final orderDate = DateTime.parse(orderDetails!['created_at']);
    final formattedDate = DateFormat('MMMM dd, yyyy').format(orderDate);
    final formattedTime = DateFormat('hh:mm a').format(orderDate);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("Order #${widget.orderId}", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Order Status", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: getOrderStatusColor(orderItems['status']).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          getOrderStatusText(orderItems['status']),
                          style: TextStyle(color: getOrderStatusColor(orderItems['status']), fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  _buildOrderTimeline(orderItems['status']),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text("Order Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Container(
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 4))],
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        orderItems['image'],
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 70,
                          height: 70,
                          color: Colors.grey[200],
                          child: Icon(Icons.image_not_supported, color: Colors.grey),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(orderItems['name'], style: TextStyle(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                          SizedBox(height: 4),
                          Text("Qty: ${orderItems['quantity']}", style: TextStyle(color: Colors.grey[700])),
                          SizedBox(height: 4),
                          Text("Rs.${orderItems['price']}", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64B5F6))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text("Shop Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 4))],
              ),
              child: Column(
                children: [
                  _buildInfoRow("Shop Name", shopDetails != null ? shopDetails!['shop_name'] : "Loading..."),
                  Divider(height: 24),
                  _buildInfoRow("Shop Address", shopDetails != null ? shopDetails!['shop_address'] : "Loading..."),
                  Divider(height: 24),
                  _buildInfoRow("Shop Contact", shopDetails != null ? shopDetails!['shop_contact'] : "Loading..."),
                  Divider(height: 24),
                  _buildInfoRow("Shop Email", shopDetails != null ? shopDetails!['shop_email'] : "Loading..."),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text("Shipping Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 4))],
              ),
              child: Column(
                children: [
                  _buildInfoRow("Name", userDetails != null ? userDetails!['user_name'] : "Loading..."),
                  Divider(height: 24),
                  // _buildInfoRow("Address", userDetails != null ? (userDetails!['user_address'] ?? "Not available") : "Loading..."),
                  Divider(height: 24),
                  _buildInfoRow("Contact", userDetails != null ? userDetails!['user_contact'] : "Loading..."),
                  Divider(height: 24),
                  _buildInfoRow("Email", userDetails != null ? userDetails!['user_email'] : "Loading..."),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 4))],
              ),
              child: Column(
                children: [
                  _buildInfoRow("Order Date", "$formattedDate at $formattedTime"),
                  Divider(height: 24),
                  _buildInfoRow("Payment Status", orderDetails!['booking_status'] == 1 ? "Paid" : "Pending"),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text("Order Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 4))],
              ),
              child: Column(
                children: [
                  Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider()),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text("Total", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text("Rs.${orderItems['price'] * orderItems['quantity']}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF64B5F6))),
                  ]),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 4))],
              ),
              child: Column(
                children: [
                  if (orderItems['status'] == 3)
                    ElevatedButton.icon(
                      icon: Icon(Icons.star_border_outlined, color: Colors.amber),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => FeedbackPage(pid: orderItems['product_id'])));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF64B5F6),
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 45),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      label: Text("Rate Us"),
                    ),
                  SizedBox(height: 12),
                  orderItems['status'] < 2 ? OutlinedButton(
                    onPressed: () {
                      // Show confirmation dialog
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text("Cancel Order"),
                          content: Text("Are you sure you want to cancel this order? This action cannot be undone."),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text("No"),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                await supabase.from('tbl_cart').update({'cart_status': 4}).eq('id', widget.cartId);
                                fetchOrderDetails();
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Order Cancelled")));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: Text("Yes, Cancel Order"),
                            ),
                          ],
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: BorderSide(color: Colors.red),
                      minimumSize: Size(double.infinity, 45),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text("Cancel Order"),
                  ) : SizedBox(),
                  SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ComplaintPage(id: orderItems['product_id'])));
                    },
                    icon: Icon(Icons.support_agent),
                    label: Text("Post a Complaint"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Color(0xFF64B5F6),
                      side: BorderSide(color: Color(0xFF64B5F6)),
                      minimumSize: Size(double.infinity, 45),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: Icon(Icons.download, color: Colors.white),
                    onPressed: _generateAndDownloadBill,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 45),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    label: Text("Download Bill"),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[700])),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildOrderTimeline(int status) {
    // If order is cancelled, show a different timeline
    if (status == 4) {
      return Column(
        children: [
          TimelineTile(
            alignment: TimelineAlign.start,
            isFirst: true,
            indicatorStyle: IndicatorStyle(
              width: 20,
              color: Colors.green,
              iconStyle: IconStyle(color: Colors.white, iconData: Icons.check, fontSize: 12),
            ),
            endChild: _buildTimelineChild("Order Placed", "Your order has been placed successfully", true),
          ),
          TimelineTile(
            alignment: TimelineAlign.start,
            isLast: true,
            indicatorStyle: IndicatorStyle(
              width: 20,
              color: Colors.red,
              iconStyle: IconStyle(color: Colors.white, iconData: Icons.close, fontSize: 12),
            ),
            endChild: _buildTimelineChild("Order Cancelled", "Your order has been cancelled", true),
          ),
        ],
      );
    }

    // Regular order timeline
    return Column(
      children: [
        TimelineTile(
          alignment: TimelineAlign.start,
          isFirst: true,
          indicatorStyle: IndicatorStyle(
            width: 20,
            color: Colors.green,
            iconStyle: IconStyle(color: Colors.white, iconData: Icons.check, fontSize: 12),
          ),
          endChild: _buildTimelineChild("Order Placed", "Your order has been placed successfully", true),
        ),
        TimelineTile(
          alignment: TimelineAlign.start,
          indicatorStyle: IndicatorStyle(
            width: 20,
            color: status >= 1 ? Colors.green : (Colors.grey[300] ?? Colors.grey),
            iconStyle: IconStyle(color: Colors.white, iconData: status >= 1 ? Icons.check : Icons.circle, fontSize: 12),
          ),
          endChild: _buildTimelineChild("Processing", "Your order is being processed", status >= 1),
        ),
        TimelineTile(
          alignment: TimelineAlign.start,
          indicatorStyle: IndicatorStyle(
            width: 20,
            color: status >= 2 ? Colors.green : (Colors.grey[300] ?? Colors.grey),
            iconStyle: IconStyle(color: Colors.white, iconData: status >= 2 ? Icons.check : Icons.circle, fontSize: 12),
          ),
          endChild: _buildTimelineChild("Shipped", "Your order has been shipped", status >= 2),
        ),
        TimelineTile(
          alignment: TimelineAlign.start,
          isLast: true,
          indicatorStyle: IndicatorStyle(
            width: 20,
            color: status >= 3 ? Colors.green : (Colors.grey[300] ?? Colors.grey),
            iconStyle: IconStyle(color: Colors.white, iconData: status >= 3 ? Icons.check : Icons.circle, fontSize: 12),
          ),
          endChild: _buildTimelineChild("Delivered", "Your order has been delivered", status >= 3),
        ),
      ],
    );
  }

  Widget _buildTimelineChild(String title, String subtitle, bool isActive) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isActive ? Colors.black : Colors.grey)),
          SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 12, color: isActive ? Colors.grey[700] : Colors.grey[400])),
        ],
      ),
    );
  }
}