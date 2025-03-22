import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop_maternityapp/main.dart'; // Assuming supabase is defined here

class AccountManagementPage extends StatefulWidget {
  const AccountManagementPage({super.key});

  @override
  State<AccountManagementPage> createState() => _AccountManagementPageState();
}

class _AccountManagementPageState extends State<AccountManagementPage> {
  Map<String, dynamic>? accountData;
  bool isLoading = true;
  bool isEditing = false;

  // Controllers for editable fields
  late TextEditingController _shopNameController;
  late TextEditingController _shopContactController;
  late TextEditingController _shopAddressController;

  Future<void> fetchAccountData() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      final response = await supabase
          .from('tbl_shop')
          .select()
          .eq('shop_id', user.id)
          .single();

      setState(() {
        accountData = response;
        isLoading = false;
        _shopNameController.text = accountData!['shop_name'] ?? '';
        _shopContactController.text = accountData!['shop_contact'] ?? '';
        _shopAddressController.text = accountData!['shop_address'] ?? '';
      });
    } catch (e) {
      print("Error fetching data: $e");
      setState(() {
        accountData = null;
        isLoading = false;
      });
    }
  }

  Future<void> saveProfileChanges() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      await supabase.from('tbl_shop').update({
        'shop_name': _shopNameController.text,
        'shop_contact': _shopContactController.text,
        'shop_address': _shopAddressController.text,
      }).eq('shop_id', user.id);

      setState(() {
        accountData!['shop_name'] = _shopNameController.text;
        accountData!['shop_contact'] = _shopContactController.text;
        accountData!['shop_address'] = _shopAddressController.text;
        isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      print("Error saving profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _shopNameController = TextEditingController();
    _shopContactController = TextEditingController();
    _shopAddressController = TextEditingController();
    fetchAccountData();
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _shopContactController.dispose();
    _shopAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color.fromARGB(255, 198, 176, 249)))
          : accountData == null
              ? Center(
                  child: Text(
                    "No shop data found",
                    style: GoogleFonts.sanchez(
                      fontSize: 20,
                      color: Colors.black54,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with Refresh and Edit/Save Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Account Management",
                              style: GoogleFonts.sanchez(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.refresh, color: Color.fromARGB(255, 198, 176, 249)),
                                  onPressed: fetchAccountData,
                                  tooltip: 'Refresh Data',
                                ),
                                const SizedBox(width: 8),
                                isEditing
                                    ? Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.save, color: Color.fromARGB(255, 198, 176, 249)),
                                            onPressed: saveProfileChanges,
                                            tooltip: 'Save Changes',
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.cancel, color: Colors.red),
                                            onPressed: () {
                                              setState(() {
                                                isEditing = false;
                                                _shopNameController.text = accountData!['shop_name'] ?? '';
                                                _shopContactController.text = accountData!['shop_contact'] ?? '';
                                                _shopAddressController.text = accountData!['shop_address'] ?? '';
                                              });
                                            },
                                            tooltip: 'Cancel',
                                          ),
                                        ],
                                      )
                                    : IconButton(
                                        icon: const Icon(Icons.edit, color: Color.fromARGB(255, 198, 176, 249)),
                                        onPressed: () => setState(() => isEditing = true),
                                        tooltip: 'Edit Profile',
                                      ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Account Card
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Shop Logo and Name Section
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    _buildShopLogo(),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: isEditing
                                          ? TextField(
                                              controller: _shopNameController,
                                              style: GoogleFonts.sanchez(
                                                fontSize: 28,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                              decoration: const InputDecoration(
                                                border: OutlineInputBorder(),
                                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                              ),
                                            )
                                          : Text(
                                              accountData!['shop_name'] ?? 'Not available',
                                              style: GoogleFonts.sanchez(
                                                fontSize: 28,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 32),
                                // Information Fields
                                _buildInfoRow("Email", accountData!['shop_email'] ?? 'Not available', isEditable: false),
                                const SizedBox(height: 16),
                                _buildInfoRow("Contact", _shopContactController.text, isEditable: true),
                                const SizedBox(height: 16),
                                _buildInfoRow("Address", _shopAddressController.text, isEditable: true),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildShopLogo() {
    final logoUrl = accountData!['shop_logo'] as String?;
    final screenWidth = MediaQuery.of(context).size.width;
    final logoSize = (screenWidth * 0.15).clamp(100.0, 200.0); // Responsive logo size

    return Container(
      width: logoSize,
      height: logoSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: logoUrl != null && logoUrl.isNotEmpty
            ? Image.network(
                logoUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.store,
                  size: 60,
                  color: Color.fromARGB(255, 198, 176, 249),
                ),
              )
            : const Icon(
                Icons.store,
                size: 60,
                color: Color.fromARGB(255, 198, 176, 249),
              ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isEditable = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            "$label:",
            style: GoogleFonts.sanchez(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.right,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: isEditing && isEditable
              ? TextField(
                  controller: label == "Contact" ? _shopContactController : _shopAddressController,
                  style: GoogleFonts.sanchez(
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                )
              : Text(
                  value,
                  style: GoogleFonts.sanchez(
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
        ),
      ],
    );
  }
}