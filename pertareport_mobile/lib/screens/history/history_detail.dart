import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:pertareport_mobile/models/history/comment_model.dart';
import 'package:pertareport_mobile/models/history/history_model.dart';

class ForumDetailPage extends StatefulWidget {
  final ForumEntry forum;

  const ForumDetailPage({Key? key, required this.forum}) : super(key: key);

  @override
  State<ForumDetailPage> createState() => _ForumDetailPageState();
}

class _ForumDetailPageState extends State<ForumDetailPage> {
  final TextEditingController _commentController = TextEditingController();
  List<Comment> comments = []; // Store comments for the current forum

  // Fetch comments for the specific forum using its `pk`
  Future<void> fetchForumComments(CookieRequest request) async {
    try {
      final response = await request.get(
        'http://127.0.0.1:8000/forum/show-json-comment/${widget.forum.pk}/',
      );

      if (response is Map<String, dynamic> && response.containsKey('comment')) {
        setState(() {
          comments = List<Comment>.from(
            response['comment'].map((comment) => Comment.fromJson(comment)),
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch comments.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching comments: $e')),
      );
    }
  }

  // Submit a new comment for the current forum
  Future<void> submitComment(CookieRequest request) async {
    if (_commentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a comment')),
      );
      return;
    }

    Map<String, dynamic> data = {
      'content': _commentController.text,
    };

    try {
      final response = await request.postJson(
        'http://127.0.0.1:8000/forum/add_comment_flutter/${widget.forum.pk}/',
        jsonEncode(data),
      );

      if (response is Map && response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Comment submitted successfully!')),
        );
        _commentController.clear();

        // Re-fetch comments to include the new comment
        await fetchForumComments(request);
      } else if (response is Map && response['status'] == 'error') {
        String errorMessage =
            response['message'] ?? 'Failed to submit comment.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit comment: $errorMessage')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unexpected response from server.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting comment: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // Fetch comments for the forum when the page loads
    final request = Provider.of<CookieRequest>(context, listen: false);
    fetchForumComments(request);
  }

  @override
  Widget build(BuildContext context) {
    final request = Provider.of<CookieRequest>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.forum.fields.title,
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.forum.fields.description),
            const Divider(),
            const Text('Komentar:'),
            Expanded(
              child: comments.isEmpty
                  ? const Center(child: Text('Belum ada komentar.'))
                  : ListView.builder(
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        return ListTile(
                          title: Text(comment.user), // Display the user
                          subtitle: Text(
                              comment.content), // Display the comment content
                          trailing: Text(
                            '${comment.createdAt.toLocal()}'.split(' ')[0],
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      },
                    ),
            ),
            const Divider(),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                labelText: 'Tambah Komentar',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => submitComment(request),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
