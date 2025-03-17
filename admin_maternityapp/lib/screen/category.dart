import 'package:admin_maternityapp/main.dart';
import 'package:flutter/material.dart';

class ManageCategory extends StatefulWidget {
  const ManageCategory({super.key});

  @override
  State<ManageCategory> createState() => _ManageCategoryState();
}

class _ManageCategoryState extends State<ManageCategory> {
  final TextEditingController _categoryController = TextEditingController();
  List<Map<String, dynamic>> category = [];
  int eid = 0;

  Future<void> insert() async {
    if (_categoryController.text.trim().isEmpty) return;

    try {
      await supabase.from("tbl_category").insert({
        'category_name': _categoryController.text.trim(),
      });
      _categoryController.clear();
      fetchData();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Category added successfully")));
    } catch (e) {
      print("Error Inserting Category: $e");
    }
  }

  Future<void> fetchData() async {
    try {
      final response = await supabase.from("tbl_category").select();
      setState(() {
        category = response;
      });
    } catch (e) {
      print("Error fetching Category: $e");
    }
  }

  Future<void> delete(int id) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Deletion"),
        content: const Text("Are you sure you want to delete this category?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmDelete) {
      try {
        await supabase.from('tbl_category').delete().eq('id', id);
        fetchData();
      } catch (e) {
        print("Error Deleting: $e");
      }
    }
  }

  Future<void> update() async {
    if (_categoryController.text.trim().isEmpty) return;

    try {
      await supabase.from('tbl_category').update({
        'category_name': _categoryController.text.trim(),
      }).eq('id', eid);
      fetchData();
      _categoryController.clear();
      setState(() {
        eid = 0;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Category updated successfully")));
    } catch (e) {
      print("Error updating data: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: Color.fromARGB(255, 194, 170, 250),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _categoryController,
                      keyboardType: TextInputType.name,
                      onChanged: (value) {
                        setState(() {}); // Update button state when text changes
                      },
                      decoration: InputDecoration(
                        hintText: "Enter Category",
                        hintStyle: TextStyle(color: Colors.black, fontSize: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _categoryController.text.trim().isEmpty
                        ? null
                        : () {
                            eid == 0 ? insert() : update();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 182, 152, 251),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
          const SizedBox(height: 20),
          Expanded(
            child: category.isEmpty
                ? const Center(child: Text("No categories found"))
                : ListView.builder(
                    itemCount: category.length,
                    itemBuilder: (context, index) {
                      final data = category[index];
                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Color.fromARGB(255, 194, 170, 250),
                            child: Text(
                              (index + 1).toString(),
                              style: const TextStyle(color: Color.fromARGB(255, 255, 253, 253)),
                            ),
                          ),
                          title: Text(
                            data['category_name'],
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    eid = data['id'];
                                    _categoryController.text = data['category_name'];
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
