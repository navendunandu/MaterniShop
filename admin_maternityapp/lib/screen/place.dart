import 'package:admin_maternityapp/main.dart';
import 'package:flutter/material.dart';

class ManagePlace extends StatefulWidget {
  const ManagePlace({super.key});

  @override
  State<ManagePlace> createState() => _ManagePlaceState();
}

class _ManagePlaceState extends State<ManagePlace> {
  final TextEditingController _placeController = TextEditingController();
  List<Map<String, dynamic>> place = [];
  List<Map<String, dynamic>> districts = [];
  String? selectedDistrict;
  int eid = 0;

  Future<void> insert() async {
  String placeName = _placeController.text.trim();

  if (placeName.isEmpty || selectedDistrict == null) return;

  try {
    // Check if place already exists in the selected district
    final existingPlaces = await supabase
        .from("tbl_place")
        .select("place_name")
        .eq("place_name", placeName)
        .eq("district_id", selectedDistrict!);

    if (existingPlaces.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Place already exists in this district!")),
      );
      return;
    }

    // Insert new place
    await supabase.from("tbl_place").insert({
      'place_name': placeName,
      'district_id': selectedDistrict,
    });

    _placeController.clear();
    fetchData();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Place Added Successfully")),
    );
  } catch (e) {
    print("Error Inserting Place: $e");
  }
}


  Future<void> fetchData() async {
    try {
      final response = await supabase.from("tbl_place").select("*,tbl_district(*)");
      setState(() {
        place = response;
      });
    } catch (e) {
      print("Error fetching Places: $e");
    }
  }

  Future<void> fetchDistrict() async {
    try {
      final response = await supabase.from("tbl_district").select();
      setState(() {
        districts = response;
      });
    } catch (e) {
      print("Error fetching Districts: $e");
    }
  }

  Future<void> delete(int id) async {
    try {
      await supabase.from('tbl_place').delete().eq('id', id);
      fetchData();
    } catch (e) {
      print("Error Deleting: $e");
    }
  }

  Future<void> update() async {
    try {
      await supabase.from('tbl_place').update({
        'place_name': _placeController.text,
      }).eq('id', eid);
      fetchData();
      _placeController.clear();
      setState(() {
        eid = 0;
      });
    } catch (e) {
      print("Error updating data: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchDistrict();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: Color.fromARGB(255, 194, 170, 250),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField(
                      decoration: InputDecoration(
                        hintText: "Select District",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      value: selectedDistrict,
                      items: districts.map((district) {
                        return DropdownMenuItem(
                          value: district['district_id'].toString(),
                          child: Text(district['district_name']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedDistrict = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _placeController,
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                        hintText: "Enter Place",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      eid == 0 ? insert() : update();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 182, 152, 251),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                    child: Text(
                      eid == 0 ? "Add" : "Update",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: place.length,
              itemBuilder: (context, index) {
                final data = place[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Color.fromARGB(255, 194, 170, 250),
                      child: Text((index + 1).toString(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(
                      data['place_name'],
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      data['tbl_district']['district_name'],
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              eid = data['id'];
                              _placeController.text = data['place_name'];
                              selectedDistrict = data['district_id'].toString();
                            });
                          },
                          icon: const Icon(Icons.edit, color: Color.fromARGB(255, 160, 141, 247)),
                        ),
                        IconButton(
                          onPressed: () => delete(data['id']),
                          icon: const Icon(Icons.delete_outline_rounded, color: Color.fromARGB(255, 160, 141, 247)),
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
