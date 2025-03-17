import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop_maternityapp/main.dart';

class OrderDetailsPage extends StatefulWidget {
  final int bid;
  const OrderDetailsPage({super.key, required this.bid});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {

  List<Map<String,dynamic>> orderItems = [];

  Future<void> fetchItems() async {
    try {
      final response = await supabase.from('tbl_cart').select("*,tbl_product(*)").eq('booking_id', widget.bid);
      List<Map<String,dynamic>> items = [];
      for( var item in response){
        int total = item['tbl_product']['product_price']*item['cart_qty'];
        items.add({
          'id':item['id'],
          'product':item['tbl_product']['product_name'],
          'image':item['tbl_product']['product_image'],
          'qty':item['cart_qty'],
          'price':item['tbl_product']['product_price'],
          'total':total,
          'status':item['cart_status']
        });
      }
      setState(() {
        orderItems=items;
      });
      print(items);
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> update(int id, int status) async {
    try {
      await supabase.from('tbl_cart').update({'cart_status':status + 1}).eq('id', id);
      fetchItems();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Updated")));
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchItems();
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
            // Header
            Text(
              "Order Details",
              style: GoogleFonts.sanchez(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20),

            // Order Items List
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
                              "No items in this order",
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
            // Product Photo
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

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    item['product'],
                    style: GoogleFonts.sanchez(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),

                  // Quantity and Price
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
                        "Price: \$${item['price'].toStringAsFixed(2)}",
                        style: GoogleFonts.sanchez(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),

                  // Total Price
                  Text(
                    "Total: \$${item['total'].toStringAsFixed(2)}",
                    style: GoogleFonts.sanchez(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),

                  // Status
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

            // Action Button
           item['status'] !=3 ? SizedBox(
              height: 40,
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
            ):Container(),
          ],
        ),
      ),
    );
  }
}