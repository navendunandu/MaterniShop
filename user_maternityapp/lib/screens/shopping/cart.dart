import 'package:flutter/material.dart';
import 'package:user_maternityapp/main.dart';
import 'package:user_maternityapp/screens/shopping/my_order.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> with SingleTickerProviderStateMixin  {
  List<Map<String, dynamic>> cartItems = [];
  bool isLoading = true;

  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    fetchCartItems();
    _razorpay = Razorpay();
   
    
    // Event Listeners
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

int? bookingId;
int? bookingAmt;

  void _openCheckout(int total, int id) {
    setState(() {
      bookingId = id;
      bookingAmt = total;
    });
    var options = {
      'key': 'rzp_test_31UbYA8dUUi4m0',
      'amount': total*100, 
      'name': 'Maternity App',
      'description': 'Payment',
      'prefill': {
        'contact': '8606540112',
        'email': 'test@razorpay.com',
      },
      'theme': {'color': '#00245E'}
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error in payment: $e');
    }
  }

      

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
  try {

   await supabase
          .from('tbl_cart')
          .update({'cart_status': 1}).eq('booking_id', bookingId!);
      await supabase
          .from('tbl_booking')
          .update({'booking_status': 1, 'booking_amount': bookingAmt!}).eq('id', bookingId!);

    Fluttertoast.showToast(
      msg: 'Payment Successful! Status Updated.',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );

    Navigator.pop(context); // Go back to MyBookings after success
  } catch (e) {
    Fluttertoast.showToast(
      msg: '❌ Error updating status in Supabase: $e',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }
}


  void _handlePaymentError(PaymentFailureResponse response) {
    print('Error: ${response.code} - ${response.message}');
    Fluttertoast.showToast(
      msg: 'Payment Failed',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(
      msg: 'External Wallet Selected: ${response.walletName}',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.orange,
      textColor: Colors.white,
    );
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  int? bid;

  // Fetch Cart Items from Supabase
  Future<void> fetchCartItems() async {
    try {
      final booking = await supabase.from('tbl_booking').select("id").eq('user_id', supabase.auth.currentUser!.id).eq('booking_status', 0).maybeSingle();
      
      if (booking == null) {
        setState(() {
          cartItems = [];
          isLoading = false;
        });
        return;
      }
      
      int bookingId = booking['id'];
      setState(() {
        bid = bookingId;
      });
      
      final cartResponse = await supabase
          .from('tbl_cart')
          .select('*')
          .eq('booking_id', bookingId)
          .eq('cart_status', 0);

      List<Map<String, dynamic>> items = [];
      for (var cartItem in cartResponse) {
        final itemResponse = await supabase
            .from('tbl_product')
            .select('product_name, product_image, product_price')
            .eq('product_id', cartItem['product_id'])
            .maybeSingle();
            
        final stock = await supabase
          .from('tbl_stock')
          .select('stock_quantity')
          .eq('product_id', cartItem['product_id']);

        int totalStock =
            stock.fold(0, (sum, item) => sum + (item['stock_quantity'] as int));
            
        final cart = await supabase
            .from('tbl_cart')
            .select('cart_qty')
            .eq('product_id', cartItem['product_id']);

        int totalCartQty =
            cart.fold(0, (sum, item) => sum + (item['cart_qty'] as int));

        num remainingStock = totalStock - totalCartQty + cartItem['cart_qty'];

        if (itemResponse != null) {
          items.add({
            "id": cartItem['id'],
            "product_id": cartItem['product_id'],
            "name": itemResponse['product_name'],
            "image": itemResponse['product_image'],
            "price": itemResponse['product_price'],
            "quantity": cartItem['cart_qty'],
            "stock": remainingStock,
          });
        }
      }

      setState(() {
        cartItems = items;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching cart data: $e");
      setState(() => isLoading = false);
    }
  }

  // Update Cart Quantity
  Future<void> updateCartQuantity(int cartId, int newQty) async {
    try {
      await supabase
          .from('tbl_cart')
          .update({'cart_qty': newQty})
          .eq('id', cartId);

      fetchCartItems(); // Refresh the cart after updating
    } catch (e) {
      print("Error updating cart quantity: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update quantity. Please try again.')),
      );
    }
  }

  // Delete Item from Cart
  Future<void> deleteCartItem(int cartId) async {
    try {
      await supabase.from('tbl_cart').delete().eq('id', cartId);

      fetchCartItems(); // Refresh cart after deletion
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Item removed from cart'),
          backgroundColor: Color(0xFF64B5F6),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      print("Error deleting item: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete item. Please try again.')),
      );
    }
  }

  // Calculate Total Price
  double getTotalPrice() {
    return cartItems.fold(
        0, (sum, item) => sum + (item['price'] * item['quantity']));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "Your Cart",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OrdersPage()),
              );
            },
            icon: Icon(Icons.shopping_bag_outlined, color: Color(0xFF64B5F6)),
            label: Text(
              "My Orders",
              style: TextStyle(color: Color(0xFF64B5F6)),
            ),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF64B5F6)))
          : cartItems.isEmpty
              ? _buildEmptyCart()
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          var item = cartItems[index];
                          return Dismissible(
                            key: Key(item['id'].toString()),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: Colors.red[400],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                Icons.delete_outline,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            onDismissed: (direction) {
                              deleteCartItem(item['id']);
                            },
                            child: Container(
                              margin: EdgeInsets.only(bottom: 16),
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
                                    // Product image
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        item['image'],
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          width: 100,
                                          height: 100,
                                          color: Colors.grey[200],
                                          child: Icon(Icons.image_not_supported, color: Colors.grey),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    
                                    // Product details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['name'],
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            "₹${item['price']}",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF64B5F6),
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          
                                          // Quantity controls
                                          Row(
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  border: Border.all(color: Colors.grey[300]!),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Row(
                                                  children: [
                                                    _buildQuantityButton(
                                                      icon: Icons.remove,
                                                      onPressed: item['quantity'] > 1
                                                          ? () {
                                                              int newQty = item['quantity'] - 1;
                                                              updateCartQuantity(item['id'], newQty);
                                                            }
                                                          : null,
                                                    ),
                                                    SizedBox(
                                                      width: 40,
                                                      child: Center(
                                                        child: Text(
                                                          item['quantity'].toString(),
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    _buildQuantityButton(
                                                      icon: Icons.add,
                                                      onPressed: item['stock'] > 0
                                                          ? () {
                                                              int newQty = item['quantity'] + 1;
                                                              updateCartQuantity(item['id'], newQty);
                                                            }
                                                          : null,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Spacer(),
                                              IconButton(
                                                icon: Icon(
                                                  Icons.delete_outline,
                                                  color: Colors.red[400],
                                                ),
                                                onPressed: () => deleteCartItem(item['id']),
                                              ),
                                            ],
                                          ),
                                          
                                          if (item['stock'] <= 5 && item['stock'] > 0)
                                            Padding(
                                              padding: EdgeInsets.only(top: 8),
                                              child: Text(
                                                "Only ${item['stock']} left in stock",
                                                style: TextStyle(
                                                  color: Colors.orange[700],
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          if (item['stock'] <= 0)
                                            Padding(
                                              padding: EdgeInsets.only(top: 8),
                                              child: Text(
                                                "Out of stock",
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
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
                    ),
                    
                    // Order summary
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, -4),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Subtotal",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                Text(
                                  "₹${getTotalPrice().toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Divider(),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Total",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "₹${(getTotalPrice()).toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF64B5F6),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed: cartItems.isEmpty ? null : () {
                                  int total = getTotalPrice().toInt();
                                  _openCheckout(total, bid!);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF64B5F6),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  "Proceed to Checkout",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildQuantityButton({required IconData icon, VoidCallback? onPressed}) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.all(8),
        child: Icon(
          icon,
          size: 16,
          color: onPressed == null ? Colors.grey : Colors.black,
        ),
      ),
    );
  }

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
            "Your cart is empty",
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
