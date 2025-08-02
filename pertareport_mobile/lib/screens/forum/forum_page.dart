import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:pertareport_mobile/models/forum/forum_model.dart';
import 'package:pertareport_mobile/screens/forum/add_new_form_page.dart';
import 'package:pertareport_mobile/screens/forum/forum_detail.dart';
import 'package:pertareport_mobile/widgets/forum/top_places.dart';

class ForumPage extends StatefulWidget {
  const ForumPage({Key? key}) : super(key: key);

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  late Future<List<ForumEntry>> _forumFuture;

  @override
  void initState() {
    super.initState();
    final request = Provider.of<CookieRequest>(context, listen: false);
    _forumFuture = fetchForums(request);
  }

  Future<List<ForumEntry>> fetchForums(CookieRequest request) async {
    final response =
        await request.get('http://127.0.0.1:8000/forum/get-forum-entries/');
    return List<ForumEntry>.from(
      response.map((data) => ForumEntry.fromJson(data)),
    );
  }

  Future<void> _refreshForums() async {
    final request = Provider.of<CookieRequest>(context, listen: false);
    setState(() {
      _forumFuture = fetchForums(request);
    });
  }

  void _deleteForum(ForumEntry forum) async {
    final request = Provider.of<CookieRequest>(context, listen: false);
    final deleteUrl =
        'http://127.0.0.1:8000/forum/delete-forum-flutter/${forum.pk}/';

    try {
      final response = await request.post(deleteUrl, {});

      if (response['success'] == true) {
        setState(() {
          _forumFuture = fetchForums(request);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Forum berhasil dihapus')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(response['message'] ?? 'Gagal menghapus forum')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _showDeleteConfirmationDialog(ForumEntry forum) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Hapus Forum"),
          content: const Text("Apakah Anda yakin ingin menghapus forum ini?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _deleteForum(forum); // Perform delete
              },
              child: const Text(
                "Hapus",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F3EE),
      appBar: AppBar(
        title: const Text(
          'Forum Diskusi',
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
      body: RefreshIndicator(
        onRefresh: _refreshForums,
        child: FutureBuilder<List<ForumEntry>>(
          future: _forumFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: TopPlacesSection(),
                  ),
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        'Belum ada forum, tambahkan sekarang!',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              );
            } else {
              final forums = snapshot.data!;
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: TopPlacesSection(),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 16.0),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.2,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final forum = forums[index];
                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ForumDetailPage(forum: forum),
                                  ),
                                );
                              },
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          forum.fields.title,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF5B4636),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          forum.fields.description,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF5B4636),
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          '${forum.fields.commentsCount} Komentar',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF5B4636),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (forum.fields.isAuthor)
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {
                                          _showDeleteConfirmationDialog(forum);
                                        },
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                        childCount: forums.length,
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddNewFormPage()),
          );
        },
        backgroundColor: const Color(0xFF9C6F4A),
        child: const Icon(Icons.add),
      ),
    );
  }
}
