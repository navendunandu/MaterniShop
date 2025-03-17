import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:user_maternityapp/main.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:user_maternityapp/screens/shopping/post_complaint.dart';
import 'package:user_maternityapp/screens/shopping/rating.dart';

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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrderDetails();
  }

  Future<void> fetchOrderDetails() async {
    try {
      // Fetch order details
      final orderResponse = await supabase
          .from('tbl_booking')
          .select()
          .eq('id', widget.orderId)
          .single();

      // Fetch order items
      final itemsResponse = await supabase
          .from('tbl_cart')
          .select('*, tbl_product(*)')
          .eq('id', widget.cartId
          ).single();
        Map<String,dynamic> items = {
          "id": itemsResponse['id'],
          "product_id": itemsResponse['product_id'],
          "name": itemsResponse['tbl_product']['product_name'],
          "image": itemsResponse['tbl_product']['product_image'],
          "price": itemsResponse['tbl_product']['product_price'],
          "quantity": itemsResponse['cart_qty'],
          "status":itemsResponse['cart_status'],
        };
      

      setState(() {
        orderDetails = orderResponse;
        orderItems = items;
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
        body:
            Center(child: CircularProgressIndicator(color: Color(0xFF64B5F6))),
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
        title: Text(
          "Order #${widget.orderId}",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order status card
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Order Status",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: getOrderStatusColor(
                                  orderItems['status'])
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          getOrderStatusText(orderItems['status']),
                          style: TextStyle(
                            color: getOrderStatusColor(
                                orderItems['status']),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Order timeline
                  _buildOrderTimeline(orderItems['status']),
                ],
              ),
            ),

            // Order information
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Order Information",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
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
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              width: 70,
                              height: 70,
                              color: Colors.grey[200],
                              child: Icon(Icons.image_not_supported,
                                  color: Colors.grey),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                orderItems['name'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Qty: ${orderItems['quantity']}",
                                style: TextStyle(
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "₹${orderItems['price']}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF64B5F6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
            ),
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildInfoRow(
                      "Order Date", "$formattedDate at $formattedTime"),
                  Divider(height: 24),
                 
                  _buildInfoRow(
                      "Payment Status",
                      orderDetails!['booking_status'] == 1
                          ? "Paid"
                          : "Pending"),
                ],
              ),
            ),

            // Shipping address
            // Padding(
            //   padding: EdgeInsets.symmetric(horizontal: 16),
            //   child: Text(
            //     "Shipping Address",
            //     style: TextStyle(
            //       fontSize: 18,
            //       fontWeight: FontWeight.bold,
            //     ),
            //   ),
            // ),
            // Container(
            //   margin: EdgeInsets.all(16),
            //   padding: EdgeInsets.all(16),
            //   decoration: BoxDecoration(
            //     color: Colors.white,
            //     borderRadius: BorderRadius.circular(16),
            //     boxShadow: [
            //       BoxShadow(
            //         color: Colors.black.withOpacity(0.05),
            //         blurRadius: 10,
            //         offset: Offset(0, 4),
            //       ),
            //     ],
            //   ),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Text(
            //         user['user_name'] ?? "N/A",
            //         style: TextStyle(
            //           fontWeight: FontWeight.bold,
            //           fontSize: 16,
            //         ),
            //       ),
            //       SizedBox(height: 8),
            //       Text(
            //         user['user_name'] ?? "N/A",
            //         style: TextStyle(
            //           color: Colors.grey[700],
            //         ),
            //       ),
            //       SizedBox(height: 8),
            //       Text(
            //         "Phone: ${user[] ?? 'N/A'}",
            //         style: TextStyle(
            //           color: Colors.grey[700],
            //         ),
            //       ),
            //     ],
            //   ),
            // ),

            // Order summary
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Order Summary",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Subtotal",
                        style: TextStyle(
                          color: Colors.grey[700],
                        ),
                      ),
                      Text(
                        "₹${orderItems['price']}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  // SizedBox(height: 12),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     Text(
                  //       "Shipping",
                  //       style: TextStyle(
                  //         color: Colors.grey[700],
                  //       ),
                  //     ),
                  //     Text(
                  //       "₹50.00",
                  //       style: TextStyle(
                  //         fontWeight: FontWeight.bold,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "₹${orderItems['price']}",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF64B5F6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Support and actions
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  if (orderItems['status'] == 3)
                    ElevatedButton.icon(
                      icon: Icon(Icons.star_border_outlined, color: Colors.amber,),
                      onPressed: () {
                        // Implement cancel order functionality
                        Navigator.push(context, MaterialPageRoute(builder: (context) => FeedbackPage(pid: orderItems['product_id'],),));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF64B5F6),
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      label: Text("Rate Us"),
                    ),
                  SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      // Implement contact support functionality
                     ComplaintPage(id: orderItems['product_id'],);
                    },
                    icon: Icon(Icons.support_agent),
                    label: Text("Post a Complaint"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Color(0xFF64B5F6),
                      side: BorderSide(color: Color(0xFF64B5F6)),
                      minimumSize: Size(double.infinity, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
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
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderTimeline(int status) {
    return Column(
      children: [
        TimelineTile(
          alignment: TimelineAlign.start,
          isFirst: true,
          indicatorStyle: IndicatorStyle(
            width: 20,
            color: Colors.green,
            iconStyle: IconStyle(
              color: Colors.white,
              iconData: Icons.check,
              fontSize: 12,
            ),
          ),
          endChild: _buildTimelineChild(
            "Order Placed",
            "Your order has been placed successfully",
            true,
          ),
        ),
        TimelineTile(
          alignment: TimelineAlign.start,
          indicatorStyle: IndicatorStyle(
            width: 20,
            color:
                status >= 1 ? Colors.green : (Colors.grey[300] ?? Colors.grey),
            iconStyle: IconStyle(
              color: Colors.white,
              iconData:
                  status >= 1 ? Icons.check : Icons.circle, // Default fallback
              fontSize: 12,
            ),
          ),
          endChild: _buildTimelineChild(
            "Processing",
            "Your order is being processed",
            status >= 1,
          ),
        ),
        TimelineTile(
          alignment: TimelineAlign.start,
          indicatorStyle: IndicatorStyle(
            width: 20,
            color:
                status >= 2 ? Colors.green : (Colors.grey[300] ?? Colors.grey),
            iconStyle: IconStyle(
              color: Colors.white,
              iconData:
                  status >= 2 ? Icons.check : Icons.circle, // Default fallback
              fontSize: 12,
            ),
          ),
          endChild: _buildTimelineChild(
            "Shipped",
            "Your order has been shipped",
            status >= 2,
          ),
        ),
        TimelineTile(
          alignment: TimelineAlign.start,
          isLast: true,
          indicatorStyle: IndicatorStyle(
            width: 20,
            color:
                status >= 3 ? Colors.green : (Colors.grey[300] ?? Colors.grey),
            iconStyle: IconStyle(
              color: Colors.white,
              iconData:
                  status >= 3 ? Icons.check : Icons.circle, // Default fallback
              fontSize: 12,
            ),
          ),
          endChild: _buildTimelineChild(
            "Delivered",
            "Your order has been delivered",
            status >= 3,
          ),
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
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.black : Colors.grey,
            ),
          ),
          SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: isActive ? Colors.grey[700] : Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  // double _calculateSubtotal() {
  //   return orderItems.fold(
  //       0, (sum, item) => sum + (item['price'] * item['quantity']));
  // }
}
