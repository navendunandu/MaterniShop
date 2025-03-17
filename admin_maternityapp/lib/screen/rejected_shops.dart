import 'package:admin_maternityapp/main.dart';
import 'package:flutter/material.dart';

class ManageRejectedShop extends StatefulWidget {
  @override
  State<ManageRejectedShop> createState() => _ManageRejectedShopState();
}

class _ManageRejectedShopState extends State<ManageRejectedShop> {
  List<Map<String, dynamic>> RejectedShopList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRejectedShop();
  }

  Future<void> fetchRejectedShop() async {
    try {
      final response = await supabase.from("tbl_shop").select("*,tbl_place()")
          .eq('shop_vstatus', 2);
      print("Fetched RejectedShop Data: $response");
      setState(() {
        RejectedShopList = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching RejectedShop: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> approveNewShop(String rid) async {
    try {
      await supabase.from('tbl_shop').update({'shop_vstatus': 1}).eq('shop_id', rid);
      fetchRejectedShop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Shop Approved!")));
    } catch (e) {
      print("Error approving RejectedShop: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to approve shop.")));
    }
  }

 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage New Shops"),
        backgroundColor: Color.fromARGB(255, 182, 152, 251),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: RejectedShopList.length,
                itemBuilder: (context, index) {
                  final shop = RejectedShopList[index];
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            shop["shop_name"] ?? 'N/A',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                          SizedBox(height: 8),
                          Text("Email: ${shop["shop_email"] ?? 'N/A'}"),
                          Text("Contact: ${shop["shop_contact"] ?? 'N/A'}"),
                          Text("Address: ${shop["shop_address"] ?? 'N/A'}"),
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: () => approveNewShop(shop['shop_id']),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color.fromARGB(255, 194, 170, 250),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Text("Accept", style: TextStyle(fontSize: 16,
                                fontWeight: FontWeight.bold, color: Colors.white)),
                              ),
                             
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
