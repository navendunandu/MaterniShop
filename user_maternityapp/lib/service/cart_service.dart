import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CartService {
  final SupabaseClient supabase;

  CartService(this.supabase);

  Future<void> addToCart(BuildContext context, int id) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("User not logged in")));
        return;
      }

      final booking = await supabase
          .from('tbl_booking')
          .select()
          .eq('booking_status', 0)
          .eq('user_id', userId)
          .maybeSingle();

      int bookingId;
      if (booking == null) {
        final response = await supabase
            .from('tbl_booking')
            .insert([
              {'user_id': userId, 'booking_status': 0}
            ])
            .select("id")
            .single();
        bookingId = response['id'];
      } else {
        bookingId = booking['id'];
      }

      final cartResponse = await supabase
          .from('tbl_cart')
          .select()
          .eq('booking_id', bookingId)
          .eq('product_id', id);

      if (cartResponse.isEmpty) {
        await _addCart(context, bookingId, id);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Item already in cart")));
      }
    } catch (e) {
      print('Error adding to cart: $e');
    }
  }

  Future<void> _addCart(BuildContext context, int bookingId, int itemId) async {
    try {
      await supabase.from('tbl_cart').insert([
        {
          'booking_id': bookingId,
          'product_id': itemId,
        }
      ]);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Added to cart")));
    } catch (e) {
      print('Error adding to cart: $e');
    }
  }
}
