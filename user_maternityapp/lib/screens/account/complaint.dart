import 'package:flutter/material.dart';
import 'package:user_maternityapp/main.dart';
import 'package:user_maternityapp/screens/account/mycomplaint.dart';

class Mycomplaint extends StatefulWidget {
  const Mycomplaint({super.key});

  @override
  State<Mycomplaint> createState() => _MycomplaintState();
}

class _MycomplaintState extends State<Mycomplaint> {
  List<Map<String, dynamic>> answers = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception("User not logged in");
      }

      final response = await supabase
          .from('tbl_complaint')
          .select()
          .eq('user_id', user.id)
          ;
      List<Map<String, dynamic>> responseList = [];
      for (var item in response) {
       if(item['product_id'] != null) {
          responseList.add(item);
        }
      }
      setState(() {
        answers = List<Map<String, dynamic>>.from(responseList);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text(
          "Failed to load complaints",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> deleteComplaint(int id) async {
    try {
      await supabase.from('tbl_complaint').delete().eq('id', id);
      fetchData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text(
          "Failed to delete",
          style: TextStyle(color: Colors.red),
        ),
        backgroundColor: Colors.black,
      ));
    }
  }

  int? selectedCardIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.blue[400],
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
        ),
        title: const Text(
          "My Complaints",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => PostComplaint(),));
        },
        label: const Text('Report an Issue'),
        icon: const Icon(Icons.warning_amber_outlined),
        backgroundColor: Colors.blue[400],
      ),
      body: answers.isEmpty
          ? const Center(
              child: Text(
                "No complaints found",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: ListView.builder(
                itemCount: answers.length,
                itemBuilder: (context, index) {
                  final data = answers[index];
                  return Card(
                    color: selectedCardIndex == index
                        ? Colors.blue.shade100
                        : Colors.white,
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: selectedCardIndex == index
                            ? Colors.blue
                            : Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            data['complaint_title'] ?? "No Title",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: selectedCardIndex == index
                                  ? Colors.blue.shade900
                                  : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Content
                          Text(
                            data['complaint_content'] ?? "No Content",
                            style: TextStyle(
                              fontSize: 14,
                              color: selectedCardIndex == index
                                  ? Colors.blueGrey.shade700
                                  : Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Status & Reply
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: selectedCardIndex == index
                                  ? Colors.blue.shade50
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: data['complaint_status'] != 0
                                  ? Border.all(
                                      color: const Color.fromARGB(153, 139, 199, 129),
                                      width: 1)
                                  : null,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  data['complaint_status'] == 0
                                      ? Icons.hourglass_empty
                                      : Icons.check_circle,
                                  size: 18,
                                  color: selectedCardIndex == index
                                      ? Colors.blue
                                      : data['complaint_status'] == 0
                                          ? Colors.grey.shade600
                                          : Colors.green,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (data['complaint_status'] != 0)
                                        Text(
                                          "Shop Reply:",
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: selectedCardIndex == index
                                                ? Colors.blue
                                                : Colors.green,
                                          ),
                                        ),
                                      Text(
                                        data['complaint_status'] == 0
                                            ? "Awaiting Shop Review"
                                            : data['complaint_reply'] ?? "No Reply",
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontStyle:
                                              data['complaint_status'] == 0
                                                  ? FontStyle.italic
                                                  : FontStyle.normal,
                                          color: selectedCardIndex == index
                                              ? Colors.blueGrey
                                              : data['complaint_status'] == 0
                                                  ? Colors.grey.shade600
                                                  : Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Delete Button
                          Align(
                            alignment: Alignment.bottomRight,
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                deleteComplaint(data['id']);
                              },
                            ),
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