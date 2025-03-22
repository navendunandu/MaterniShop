import 'package:admin_maternityapp/main.dart';
import 'package:flutter/material.dart';

class ManageSubCategory extends StatefulWidget {
  const ManageSubCategory({super.key});

  @override
  State<ManageSubCategory> createState() => _ManageSubCategoryState();
}

class _ManageSubCategoryState extends State<ManageSubCategory> {
  final TextEditingController _subcategoryController = TextEditingController();
  List<Map<String, dynamic>> subcategories = [];
  List<Map<String, dynamic>> categories = [];
  String? selectedCategory;
  int eid = 0;

  Future<void> insert() async {
    try {
      await supabase.from("tbl_subcategory").insert({
        'subcategory_name': _subcategoryController.text,
        'category_id': selectedCategory,
      });
      _subcategoryController.clear();
      fetchData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("SubCategory Added Successfully")),
      );
    } catch (e) {
      print("Error Inserting SubCategory: $e");
    }
  }

  Future<void> fetchData() async {
    try {
      final response = await supabase.from("tbl_subcategory").select("*,tbl_category(*)");
      setState(() {
        subcategories = response;
      });
    } catch (e) {
      print("Error fetching SubCategories: $e");
    }
  }

  Future<void> fetchCategories() async {
    try {
      final response = await supabase.from("tbl_category").select();
      setState(() {
        categories = response;
      });
    } catch (e) {
      print("Error fetching Categories: $e");
    }
  }

  Future<void> delete(int id) async {
    try {
      await supabase.from('tbl_subcategory').delete().eq('id', id);
      fetchData();
    } catch (e) {
      print("Error Deleting: $e");
    }
  }

  Future<void> update() async {
    try {
      await supabase.from('tbl_subcategory').update({
        'subcategory_name': _subcategoryController.text,
        'category_id':selectedCategory,
      }).eq('id', eid);
      fetchData();
      _subcategoryController.clear();
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
    fetchCategories();
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
                        hintText: "Select Category",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      value: selectedCategory,
                      items: categories.map((category) {
                        return DropdownMenuItem(
                          value: category['id'].toString(),
                          child: Text(category['category_name']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _subcategoryController,
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                        hintText: "Enter SubCategory",
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
              itemCount: subcategories.length,
              itemBuilder: (context, index) {
                final data = subcategories[index];
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
                      data['subcategory_name'],
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      data['tbl_category']['category_name'],
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              eid = data['id'];
                              _subcategoryController.text = data['subcategory_name'];
                              print(data['category_id']);
                              selectedCategory = data['category_id'].toString();
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