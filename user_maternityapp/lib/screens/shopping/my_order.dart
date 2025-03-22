import 'package:flutter/material.dart';
import 'package:user_maternityapp/main.dart';
import 'package:user_maternityapp/screens/shopping/order_details.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  List<Map<String, dynamic>> cartProducts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCartProducts();
  }

  // Fetch Cart Products from Supabase
  Future<void> fetchCartProducts() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      // Fetch all active bookings for the user
      final bookings = await supabase
          .from('tbl_booking')
          .select('id')
          .eq('user_id', user.id)
          .eq('booking_status', 1);

      if (bookings.isEmpty) {
        setState(() {
          cartProducts = [];
          isLoading = false;
        });
        return;
      }

      // List to store all products across bookings
      List<Map<String, dynamic>> products = [];

      // Loop through each booking
      for (var booking in bookings) {
        final cartResponse = await supabase
            .from('tbl_cart')
            .select('*')
            .eq('booking_id', booking['id']);

        // Fetch product details for each cart item
        for (var cartItem in cartResponse) {
          final productResponse = await supabase
              .from('tbl_product')
              .select('product_name, product_image, product_price')
              .eq('product_id', cartItem['product_id'])
              .maybeSingle();

          if (productResponse != null) {
            products.add({
              "id": cartItem['id'],
              "order_id": cartItem['booking_id'],
              "product_id": cartItem['product_id'],
              "name": productResponse['product_name'],
              "image": productResponse['product_image'],
              "price": productResponse['product_price'],
              "quantity": cartItem['cart_qty'],
            });
          }
        }
      }

      setState(() {
        cartProducts = products;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching cart products: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "My Orders",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF64B5F6)))
          : cartProducts.isEmpty
              ? _buildEmptyCart()
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: cartProducts.length,
                  itemBuilder: (context, index) {
                    var product = cartProducts[index];
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderDetailsPage(
                              orderId: product['order_id'],
                              cartId: product['id'],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 16), // Note: 'bottom' might be intended here
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
                          padding: EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Product Image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  product['image'],
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    width: 100,
                                    height: 100,
                                    color: Colors.grey[200],
                                    child: Icon(Icons.image_not_supported,
                                        color: Colors.grey),
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              // Product Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product['name'],
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "₹${product['price']}",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF64B5F6),
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    // Quantity
                                    Text(
                                      "Quantity: ${product['quantity']}",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  // Empty Cart Widget
  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Colors.grey[400],
          ),
          SizedBox(height: 24),
          Text(
            "Your Cart is Empty",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 12),
          Text(
            "Looks like you haven't added\nanything to your cart yet",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF64B5F6),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              "Continue Shopping",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}