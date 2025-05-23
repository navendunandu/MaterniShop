import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop_maternityapp/main.dart';
import 'package:shop_maternityapp/order_details.dart';

class BookingManagementPage extends StatefulWidget {
  const BookingManagementPage({super.key});

  @override
  State<BookingManagementPage> createState() => _BookingManagementPageState();
}

class _BookingManagementPageState extends State<BookingManagementPage> {
  List<Map<String, dynamic>> bookingData = [];

  Future<void> fetchBookings() async {
    try {
      final shopId = supabase.auth.currentUser!.id;
      if (shopId == null) {
        throw Exception('Shop ID not found for the logged-in user');
      }
      final response = await supabase
    .from('tbl_booking')
    .select('''
      id, created_at, booking_amount, booking_status, user_id,
      tbl_user(user_name, user_contact, user_email),
      tbl_cart!inner(
        product_id,
        tbl_product!inner(shop_id)
      )
    ''')
    .eq('booking_status', 1)
    .eq('tbl_cart.tbl_product.shop_id', shopId);
    print(response);
      List<Map<String, dynamic>> items = [];
      for (var row in response) {
        // Parse the created_at timestamp
        DateTime createdAt = DateTime.parse(row['created_at']);

        // Format the date and time
        String date =
            "${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}";
        String time =
            "${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}";

        items.add({
          'id': row['id'],
          'name': row['tbl_user']['user_name'],
          'date': date,
          'time': time,
          'contact': row['tbl_user']['user_contact'],
          'email': row['tbl_user']['user_email'],
          'status': row['booking_status'],
        });
      }
      setState(() {
        bookingData = items;
      });
    } catch (e) {
      print('Error fetching bookings: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load bookings: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchBookings();
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
              "Booking Management",
              style: GoogleFonts.sanchez(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20),

            // Bookings List
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    Expanded(
                      child: bookingData.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.event_busy,
                                    size: 60,
                                    color: Colors.grey[400],
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "No bookings found for your shop",
                                    style: GoogleFonts.sanchez(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: bookingData.length,
                              itemBuilder: (context, index) {
                                final booking = bookingData[index];
                                return _buildBookingCard(booking);
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    Color statusColor;
    switch (booking['status']) {
      case 1:
        statusColor = Colors.green;
        break;
      case 0:
        statusColor = Colors.orange;
        break;
      case 'Cancelled':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailsPage(bid: booking['id']),
          ),
        );
      },
      child: Card(
        elevation: 0,
        color: Colors.grey[50],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking['name'],
                          style: GoogleFonts.sanchez(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 5),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      booking['status'] == 1 ? 'Confirmed' : 'Pending',
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 5),
                  Text(
                    "${booking['date']} ${booking['time']}",
                    style: GoogleFonts.sanchez(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 5),
                  Text(
                    booking['contact'],
                    style: GoogleFonts.sanchez(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(width: 15),
                  Icon(Icons.email, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 5),
                  Text(
                    booking['email'],
                    style: GoogleFonts.sanchez(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}