import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:user_maternityapp/screens/shopping/cart.dart';
import 'package:user_maternityapp/service/cart_service.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
//import 'package:user/screen/cart.dart';

class ProductPage extends StatefulWidget {
  final int productId;

  const ProductPage({super.key, required this.productId});

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  Map<String, dynamic>? product;
  int? remaining;
  bool isLoading = true;
  List<Map<String, dynamic>> reviews = [];
  Map<String, dynamic> userNames = {};
  double averageRating = 0.0;
  int reviewCount = 0;

  final cartService = CartService(Supabase.instance.client);

  void addItemToCart(BuildContext context, int itemId) {
    cartService.addToCart(context, itemId);
  }

  @override
  void initState() {
    super.initState();
    fetchProductDetails();
    fetchReviews();
    _checkWishlistStatus();
  }

  Future<void> fetchProductDetails() async {
    try {
      final stock = await supabase
          .from('tbl_stock')
          .select('stock_quantity')
          .eq('product_id', widget.productId);

      int totalStock =
          stock.fold(0, (sum, item) => sum + (item['stock_quantity'] as int));
      final cart = await supabase
          .from('tbl_cart')
          .select('cart_qty')
          .eq('product_id', widget.productId);

      int totalCartQty =
          cart.fold(0, (sum, item) => sum + (item['cart_qty'] as int));
      final response = await supabase
          .from('tbl_product')
          .select()
          .eq('product_id', widget.productId)
          .single();

      int remainingStock = totalStock - totalCartQty;

      setState(() {
        remaining = remainingStock;
        product = response;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching product details: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchReviews() async {
    try {
      final response = await supabase
          .from('tbl_review')
          .select()
          .eq('product_id', widget.productId);

      final reviewsList = List<Map<String, dynamic>>.from(response);
      double totalRating = 0;
      for (var review in reviewsList) {
        totalRating += double.parse(review['review_rating'].toString());
      }

      double avgRating =
          reviewsList.isNotEmpty ? totalRating / reviewsList.length : 0;

      setState(() {
        reviews = reviewsList;
        averageRating = avgRating;
        reviewCount = reviewsList.length;
      });

      for (var review in reviews) {
        final userId = review['user_id'];
        if (userId != null) {
          final userResponse = await supabase
              .from('tbl_user')
              .select('user_name')
              .eq('id', userId)
              .single();

          setState(() {
            userNames[userId] = userResponse['user_name'] ?? 'Anonymous';
          });
        }
      }
    } catch (e) {
      print('Error fetching reviews: $e');
    }
  }

  bool _isWishlisted = false;

  Future<void> _checkWishlistStatus() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      final response = await supabase
          .from('tbl_wishlist')
          .select()
          .eq('product_id', widget.productId)
          .eq('user_id', userId!)
          .maybeSingle();

      setState(() {
        _isWishlisted = response != null;
      });
    } catch (e) {
      print('Error checking wishlist: $e');
    }
  }

  Future<void> _toggleWishlist() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (_isWishlisted) {
        await supabase
            .from('tbl_wishlist')
            .delete()
            .eq('product_id', widget.productId)
            .eq('user_id', userId!);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Removed from wishlist')),
        );
      } else {
        // Add to wishlist
        await supabase.from('tbl_wishlist').insert({
          'product_id': widget.productId,
          'user_id': userId!,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Added to wishlist')),
        );
      }

      setState(() {
        _isWishlisted = !_isWishlisted;
      });
    } catch (e) {
      print('Error toggling wishlist: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating wishlist')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          product?['product_name'] ?? "Loading...",
          style:
              TextStyle(color: Color(0xFF333333), fontWeight: FontWeight.w600),
        ),
        iconTheme: IconThemeData(color: Color(0xFF333333)),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => CartPage()));
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF64B5F6)))
          : product == null
              ? Center(child: Text("Product not found"))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Image with Gradient Overlay
                      Stack(
                        children: [
                          Container(
                            height: 300,
                            width: double.infinity,
                            child: Image.network(
                              product?['product_image'] ??
                                  'https://via.placeholder.com/300',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                height: 300,
                                color: Colors.grey[200],
                                child: Icon(Icons.broken_image,
                                    size: 100, color: Colors.grey),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 80,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.7)
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 16,
                            right: 16,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color:
                                    remaining! <= 0 ? Colors.red : Colors.green,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                remaining! <= 0
                                    ? 'Out of Stock'
                                    : '${remaining} in stock',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Product Details Card
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product?['product_name'] ?? 'Unknown product',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF333333),
                              ),
                            ),
                            SizedBox(height: 8),

                            // Average Rating
                            Row(
                              children: [
                                RatingBarIndicator(
                                  rating: averageRating,
                                  itemBuilder: (context, index) => Icon(
                                    Icons.star,
                                    color: Color(0xFFFFD700),
                                  ),
                                  itemCount: 5,
                                  itemSize: 20.0,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  '${averageRating.toStringAsFixed(1)} (${reviewCount} ${reviewCount == 1 ? 'review' : 'reviews'})',
                                  style: TextStyle(
                                    color: Color(0xFF666666),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 16),
                            Text(
                              "₹${product?['product_price'] ?? 'N/A'}",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF64B5F6),
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              "Description",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF333333),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              product?['product_description'] ??
                                  'No details available',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF666666),
                                height: 1.5,
                              ),
                            ),
                            SizedBox(height: 24),

                            // Add to Cart Button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: remaining! <= 0
                                    ? null
                                    : () {
                                        addItemToCart(
                                            context, product?['product_id']);
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF64B5F6),
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: Colors.grey[300],
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  remaining! <= 0
                                      ? "Out of Stock"
                                      : "Add to Cart",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 16),
                            IconButton(
                              onPressed: _toggleWishlist,
                              icon: Icon(
                                Icons.favorite,
                                color: _isWishlisted ? Colors.red : Colors.grey,
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Reviews Section
                      Container(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Customer Reviews",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF333333),
                              ),
                            ),
                            SizedBox(height: 16),

                            // Reviews List
                            reviews.isEmpty
                                ? Container(
                                    padding: EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 10,
                                          offset: Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        'No reviews yet. Be the first to review!',
                                        style: TextStyle(
                                          color: Color(0xFF999999),
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  )
                                : Column(
                                    children: reviews.map((review) {
                                      final userId = review['user_id'];
                                      final userName =
                                          userNames[userId] ?? 'Anonymous';
                                      final rating = double.parse(
                                          review['review_rating'].toString());

                                      return Container(
                                        margin: EdgeInsets.only(bottom: 16),
                                        padding: EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.05),
                                              blurRadius: 10,
                                              offset: Offset(0, 5),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                CircleAvatar(
                                                  backgroundColor:
                                                      Color(0xFF64B5F6)
                                                          .withOpacity(0.2),
                                                  child: Text(
                                                    userName
                                                        .substring(0, 1)
                                                        .toUpperCase(),
                                                    style: TextStyle(
                                                      color: Color(0xFF64B5F6),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 12),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      userName,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    SizedBox(height: 4),
                                                    Text(
                                                      '${DateTime.parse(review['created_at']).toLocal().toString().split(' ')[0]}',
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF999999),
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Spacer(),
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFF64B5F6)
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.star,
                                                        size: 16,
                                                        color:
                                                            Color(0xFFFFD700),
                                                      ),
                                                      SizedBox(width: 4),
                                                      Text(
                                                        rating.toString(),
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              Color(0xFF333333),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 12),
                                            Container(
                                              padding: EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Color(0xFFF8F9FA),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                review['review_content'] ??
                                                    'No comment',
                                                style: TextStyle(
                                                  color: Color(0xFF666666),
                                                  height: 1.5,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
