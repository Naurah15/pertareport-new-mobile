import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pertareport_mobile/models/user_profile/profile_buyer_entry.dart';
import 'package:pertareport_mobile/models/user_profile/profile_seller_entry.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class EditProfile extends StatefulWidget {
  final dynamic profile;

  const EditProfile({super.key, required this.profile});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _storeNameController;
  late TextEditingController _cityController;
  late TextEditingController _subdistrictController;
  late TextEditingController _villageController;
  late TextEditingController _addressController;
  late TextEditingController _mapsController;
  late TextEditingController _nationalityController;
  late TextEditingController _profilePictureController;

  // Add new state variables for dropdown data
  Map<String, String> nationalities = {};
  Map<String, String> subdistricts = {};
  Map<String, String> villages = {};

  // Add variables for selected values
  String? selectedNationality;
  String? selectedSubdistrict;
  String? selectedVillage;

  @override
  void initState() {
    super.initState();
    _profilePictureController =
        TextEditingController(text: widget.profile.profilePicture);
    _storeNameController =
        TextEditingController(text: widget.profile.storeName);
    if (widget.profile is ProfileBuyer) {
      _nationalityController =
          TextEditingController(text: widget.profile.nationality);
      selectedNationality = widget.profile.nationality;
    } else if (widget.profile is ProfileSeller) {
      _cityController = TextEditingController(text: widget.profile.city);
      _subdistrictController =
          TextEditingController(text: widget.profile.subdistrict);
      _villageController = TextEditingController(text: widget.profile.village);
      _addressController = TextEditingController(text: widget.profile.address);
      _mapsController = TextEditingController(text: widget.profile.maps);
      selectedSubdistrict = widget.profile.subdistrict;
      selectedVillage = widget.profile.village;
    }

    // Fetch dropdown data
    fetchDataDropdown();
  }

  @override
  void dispose() {
    _profilePictureController.dispose();
    _storeNameController.dispose();
    if (widget.profile is ProfileBuyer) {
      _nationalityController.dispose();
    } else if (widget.profile is ProfileSeller) {
      _cityController.dispose();
      _subdistrictController.dispose();
      _villageController.dispose();
      _addressController.dispose();
      _mapsController.dispose();
    }
    super.dispose();
  }

  Future<void> fetchDataDropdown() async {
    final request = context.read<CookieRequest>();
    final response = await request.get('https://ezar-akhdan-olehbali.pbp.cs.ui.ac.id/profile/api/edit/choices/');

    setState(() {
      nationalities = Map<String, String>.from(response['nationalities']);
      subdistricts = Map<String, String>.from(response['subdistricts']);
      villages = Map<String, String>.from(response['villages']);
    });
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Picture Section
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Hero(
                    tag: 'profile-picture',
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Theme.of(context).primaryColor, width: 3),
                        image: DecorationImage(
                          image: NetworkImage(_profilePictureController.text),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Basic Information Card
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Basic Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _storeNameController,
                              label: 'Display Name',
                              icon: Icons.person,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _profilePictureController,
                              label: 'Profile Picture URL',
                              icon: Icons.image,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Profile Specific Information Card
                    if (widget.profile is ProfileBuyer)
                      Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Personal Information',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildDropdown(
                                value: selectedNationality,
                                items: nationalities,
                                label: 'Nationality',
                                icon: Icons.public,
                                onChanged: (value) => setState(() => selectedNationality = value),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (widget.profile is ProfileSeller)
                      Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Store Information',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _cityController,
                                label: 'City',
                                icon: Icons.location_city,
                              ),
                              const SizedBox(height: 16),
                              _buildDropdown(
                                value: selectedSubdistrict,
                                items: subdistricts,
                                label: 'Subdistrict',
                                icon: Icons.map,
                                onChanged: (value) => setState(() => selectedSubdistrict = value),
                              ),
                              const SizedBox(height: 16),
                              _buildDropdown(
                                value: selectedVillage,
                                items: villages,
                                label: 'Village',
                                icon: Icons.holiday_village,
                                onChanged: (value) => setState(() => selectedVillage = value),
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _addressController,
                                label: 'Address',
                                icon: Icons.home,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _mapsController,
                                label: 'Maps Link',
                                icon: Icons.map_outlined,
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            // Save profile changes
                            final response = await request.postJson(
                              widget.profile is ProfileBuyer
                                  ? 'https://ezar-akhdan-olehbali.pbp.cs.ui.ac.id/profile/api/buyer/'
                                  : 'https://ezar-akhdan-olehbali.pbp.cs.ui.ac.id/profile/api/seller/',
                              jsonEncode(
                                {
                                  'profile_picture': _profilePictureController.text,
                                  'store_name': _storeNameController.text,
                                  if (widget.profile is ProfileBuyer)
                                    'nationality': selectedNationality,
                                  if (widget.profile is ProfileSeller) ...{
                                    'city': _cityController.text,
                                    'subdistrict': selectedSubdistrict,
                                    'village': selectedVillage,
                                    'address': _addressController.text,
                                    'maps': _mapsController.text,
                                  },
                                },
                              ),
                            );

                            if (response['statusCode'] == 200) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Profile updated successfully'),
                                ),
                              );
                              // Return true to indicate successful update
                              Navigator.of(context).pop(true);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to update profile'),
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  Widget _buildDropdown({
    required String? value,
    required Map<String, String> items,
    required String label,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      items: items.entries.map((entry) {
        return DropdownMenuItem<String>(
          value: entry.key,
          child: Text(entry.value),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select $label';
        }
        return null;
      },
    );
  }
}
