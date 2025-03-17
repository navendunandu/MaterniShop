import 'package:admin_maternityapp/main.dart';
import 'package:flutter/material.dart';

class ManageVerifiedShop extends StatefulWidget {
  @override
  State<ManageVerifiedShop> createState() => _ManageVerifiedShopState();
}

class _ManageVerifiedShopState extends State<ManageVerifiedShop> {
  List<Map<String, dynamic>> VerifiedShopList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchVerifiedShop();
  }

  Future<void> fetchVerifiedShop() async {
    try {
      final response = await supabase.from("tbl_shop").select("*,tbl_place()",)
          .eq('shop_vstatus', 1);
      print("Fetched VerifiedShop Data: $response");
      setState(() {
        VerifiedShopList = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching VerifiedShop: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> rejectVerifiedShop(String rid) async {
    try {
      await supabase.from('tbl_shop').update({'shop_vstatus': 2}).eq('shop_id', rid);
      fetchVerifiedShop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Shop Rejected!")));
    } catch (e) {
      print("Error rejecting VerifiedShop: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to reject shop.")));
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Verified Shop"),
        backgroundColor: Color.fromARGB(255, 182, 152, 251),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: VerifiedShopList.length,
                itemBuilder: (context, index) {
                  final shop = VerifiedShopList[index];
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
                                onPressed: () => rejectVerifiedShop(shop['shop_id']),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color.fromARGB(255, 194, 170, 250),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Text("Reject",
                                 style: TextStyle(fontSize: 16,
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
