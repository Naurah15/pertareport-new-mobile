// blog_form_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:pertareport_mobile/models/forum/forum_model.dart';
import 'package:pertareport_mobile/screens/forum/forum_page.dart';

class AddNewFormPage extends StatefulWidget {
  final ForumEntry? forum;

  const AddNewFormPage({super.key, this.forum});

  @override
  State<AddNewFormPage> createState() => _AddNewFormPage();
}

class _AddNewFormPage extends State<AddNewFormPage> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;

  @override
  void initState() {
    super.initState();
    _title = widget.forum?.fields.title ?? "";
    _description = widget.forum?.fields.description ?? "";
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      backgroundColor: const Color(0xFFF8F3EE),
      appBar: AppBar(
        title: const Text(
          'Tambah Forum Baru',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF9C6F4A), Color(0xFFC89F94)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Field
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    "Title",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5B4636),
                        ),
                  ),
                ),
                TextFormField(
                  initialValue: _title, // Set initial value
                  decoration: InputDecoration(
                    hintText: "Enter forum title",
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(
                        color: const Color.fromARGB(255, 59, 41, 40),
                        width: 2.0,
                      ),
                    ),
                  ),
                  style: const TextStyle(color: Color(0xFF5B4636)),
                  onChanged: (value) => setState(() {
                    _title = value;
                  }),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Title cannot be empty";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Content Field
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    "Description",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5B4636),
                        ),
                  ),
                ),
                TextFormField(
                  initialValue: _description, // Set initial value
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText: "Enter forum description",
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(
                        color: const Color.fromARGB(
                            255, 59, 41, 40), // Warna border saat ada error
                        width: 2.0,
                      ),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  onChanged: (value) => setState(() {
                    _description = value;
                  }),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Description cannot be empty";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                // Save/Update Button
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14.0,
                        horizontal: 30.0,
                      ),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        // Create new article
                        final response = await request.postJson(
                          "http://127.0.0.1:8000/forum/create-forum-flutter/",
                          jsonEncode(<String, String>{
                            'title': _title,
                            'description': _description,
                          }),
                        );
                        if (context.mounted) {
                          if (response['status'] == 'success') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Forum created successfully"),
                              ),
                            );
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ForumPage(),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    "An error occurred, please try again."),
                              ),
                            );
                          }
                        }
                      }
                    },
                    child: Text(
                      'Save',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
