import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:user_maternityapp/screens/shopping/cart.dart';
import 'package:user_maternityapp/screens/shopping/product_details.dart';

class ShoppingPage extends StatefulWidget {
  const ShoppingPage({super.key});

  @override
  _ShoppingPageState createState() => _ShoppingPageState();
}

class _ShoppingPageState extends State<ShoppingPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> filteredItems = [];
  List<Map<String, dynamic>> subcategories = [];
  List<Map<String, dynamic>> categories = [];
  bool isLoading = true;
  String searchQuery = '';
  int? selectedCategoryId;
  int? selectedSubcategoryId;

  @override
  void initState() {
    super.initState();
    fetchItems();
    fetchCategories();
  }

  Future<void> fetchItems() async {
    try {
      final response = await supabase.from('tbl_product').select("*,tbl_subcategory(*,tbl_category(*))");
      List<Map<String, dynamic>> products = [];
      for (var items in response){
        final response = await supabase
          .from('tbl_review')
          .select()
          .eq('product_id', items['product_id']);
      
      final reviewsList = List<Map<String, dynamic>>.from(response);
      
      // Calculate average rating
      double totalRating = 0;
      for (var review in reviewsList) {
        totalRating += double.parse(review['review_rating'].toString());
      }
      
      double avgRating = reviewsList.isNotEmpty ? totalRating / reviewsList.length : 0;
        items['rating'] = avgRating;
        products.add(items);
      }
      setState(() {
        items = products;
        filteredItems = products;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching items: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchCategories() async {
    try {
      final response = await supabase.from('tbl_category').select();
      setState(() {
        categories = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  Future<void> fetchSubcategories(int categoryId) async {
    try {
      final response = await supabase.from('tbl_subcategory').select().eq('category_id', categoryId);
      setState(() {
        subcategories = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print('Error fetching subcategories: $e');
    }
  }

  void filterItems() {
    print(selectedCategoryId);
    print(selectedSubcategoryId);
    setState(() {
      filteredItems = items.where((item) {
        // Filter by search query
        bool matchesSearch = searchQuery.isEmpty || 
            item['product_name'].toString().toLowerCase().contains(searchQuery.toLowerCase());
        
        // Filter by category
        bool matchesCategory = selectedCategoryId == null || 
            item['tbl_subcategory']['category_id'] == selectedCategoryId;
        
        // Filter by subcategory
        bool matchesSubcategory = selectedSubcategoryId == null || 
            item['subcategory_id'] == selectedSubcategoryId;
        
        return matchesSearch && matchesCategory && matchesSubcategory;
      }).toList();
    });
  }

  void resetFilters() {
    setState(() {
      searchQuery = '';
      selectedCategoryId = null;
      selectedSubcategoryId = null;
      subcategories = [];
      filteredItems = List<Map<String, dynamic>>.from(items);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F2F7),
      appBar: AppBar(
        title: Text('Maternity Shop', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart_outlined),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CartPage()));
                },
              ),
              // Positioned(
              //   top: 8,
              //   right: 8,
              //   child: Container(
              //     padding: EdgeInsets.all(4),
              //     decoration: BoxDecoration(
              //       color: Color(0xFF64B5F6),
              //       shape: BoxShape.circle,
              //     ),
              //     child: Text(
              //       '0',
              //       style: TextStyle(
              //         color: Colors.white,
              //         fontSize: 10,
              //         fontWeight: FontWeight.bold,
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF64B5F6)))
          : Column(
              children: [
                // Search bar
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 0),
                    ),
                    onChanged: (value) {
                      searchQuery = value;
                      filterItems();
                    },
                  ),
                ),
                
                // Filter section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Filters',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: resetFilters,
                            child: Text(
                              'Reset',
                              style: TextStyle(color: Color(0xFF64B5F6)),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            // Category filter chips
                            ...categories.map((category) {
                              bool isSelected = selectedCategoryId == category['id'];
                              return Padding(
                                padding: EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  label: Text(category['category_name']),
                                  selected: isSelected,
                                  selectedColor: Colors.blue[100],
                                  checkmarkColor: Color(0xFF64B5F6),
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        selectedCategoryId = category['id'];
                                        fetchSubcategories(category['id']);
                                      } else {
                                        selectedCategoryId = null;
                                        subcategories = [];
                                      }
                                      selectedSubcategoryId = null;
                                      filterItems();
                                    });
                                  },
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                      
                      // Subcategory filter chips (if a category is selected)
                      if (subcategories.isNotEmpty) ...[
                        SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              ...subcategories.map((subcategory) {
                                bool isSelected = selectedSubcategoryId == subcategory['id'];
                                return Padding(
                                  padding: EdgeInsets.only(right: 8),
                                  child: FilterChip(
                                    label: Text(subcategory['subcategory_name']),
                                    selected: isSelected,
                                    selectedColor: Colors.blue[100],
                                    checkmarkColor: Color(0xFF64B5F6),
                                    onSelected: (selected) {
                                      setState(() {
                                        selectedSubcategoryId = selected ? subcategory['id'] : null;
                                        filterItems();
                                      });
                                    },
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Results count
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${filteredItems.length} products found',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                      DropdownButton<String>(
                        hint: Text('Sort by'),
                        underline: SizedBox(),
                        icon: Icon(Icons.sort),
                        items: [
                          DropdownMenuItem(value: 'price_asc', child: Text('Price: Low to High')),
                          DropdownMenuItem(value: 'price_desc', child: Text('Price: High to Low')),
                          DropdownMenuItem(value: 'name_asc', child: Text('Name: A to Z')),
                        ],
                        onChanged: (value) {
                          // Implement sorting logic here
                          setState(() {
                            if (value == 'price_asc') {
                              filteredItems.sort((a, b) => (a['product_price'] as num).compareTo(b['product_price'] as num));
                            } else if (value == 'price_desc') {
                              filteredItems.sort((a, b) => (b['product_price'] as num).compareTo(a['product_price'] as num));
                            } else if (value == 'name_asc') {
                              filteredItems.sort((a, b) => a['product_name'].toString().compareTo(b['product_name'].toString()));
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
                
                // Product grid
                Expanded(
                  child: filteredItems.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'No products found',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Try adjusting your search or filters',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: EdgeInsets.all(16),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.7,
                          ),
                          itemCount: filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = filteredItems[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductPage(productId: item['product_id']),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Product image
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                                          image: DecorationImage(
                                            image: NetworkImage(item['product_image']),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                    
                                    // Product info
                                    Padding(
                                      padding: EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['product_name'],
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(Icons.star, size: 16, color: Colors.amber),
                                              Text(
                                                item['rating'].toString(),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            '₹${item['product_price']}',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF64B5F6),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
