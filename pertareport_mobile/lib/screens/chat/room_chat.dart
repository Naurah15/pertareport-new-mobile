import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:pertareport_mobile/models/chat/message_entry.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MessageEntryFormPage extends StatefulWidget {
  final String chatId;

  const MessageEntryFormPage({
    super.key,
    required this.chatId,
  });

  @override
  State<MessageEntryFormPage> createState() => _MessageEntryFormPageState();
}

class _MessageEntryFormPageState extends State<MessageEntryFormPage> {
  final _formKey = GlobalKey<FormState>();
  String _message = "";
  List<Message> messages = [];
  String user_loggedin = "";

  @override
  void initState() {
    super.initState();
    fetchMessages();
  }

  Future<void> fetchMessages() async {
    try {
      final url =
          "http://127.0.0.1:8000/chat/get-messages-flutter/${widget.chatId}/";
      print("Fetching messages from: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final dataSent = jsonDecode(response.body);
        final String loggedInUser = dataSent['user_loggedin'];
        final List<dynamic> data = dataSent['messages'];
        setState(() {
          messages = data.map((json) => Message.fromJson(json)).toList();
          user_loggedin = loggedInUser;
        });
      } else {
        print("Error status code: ${response.statusCode}");
        print("Error response: ${response.body}");
      }
    } catch (e) {
      print("Error fetching messages: $e");
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      final url =
          "http://127.0.0.1:8000/chat/delete-message-flutter/$messageId/";
      print("Fetching messages from: $url");

      final response = await http.delete(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          messages.removeWhere((message) => message.pk.toString() == messageId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Message deleted successfully")),
        );
      } else {
        final errorData = jsonDecode(response.body);
        print('Error: ${errorData['error']}');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(errorData['error'] ?? "Failed to delete message")),
        );
      }
    } catch (e) {
      print('Delete error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        toolbarHeight: 60,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            InkWell(
              splashColor: Colors.white,
              highlightColor: Colors.white,
              onTap: () {
                Navigator.pop(context);
              },
              child: const Row(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 60,
                        child: Row(
                          children: [
                            SizedBox(width: 24),
                            Image(
                              width: 18,
                              image: AssetImage('assets/images/back_icon.png'),
                            ),
                            SizedBox(width: 12),
                            Text(
                              "Room Chat",
                              style: TextStyle(
                                color: Color.fromRGBO(0, 0, 0, 1),
                                fontSize: 18,
                                height: 1,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 24),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: const [
          SizedBox(width: 20),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final bool isMe = message.fields.sender == user_loggedin;

                String defaultAvatar = 'assets/images/user_icon.png';
                String defaultRoleName = message.fields.sender;
                Color defaultColor = const Color.fromRGBO(229, 245, 244, 1);
                Color defaultTextColor = Colors.black;
                String defaultTextPrefix = '';
                List<Widget> defaultIcons = [
                  // _renderVoiceWidget(message),
                  // const SizedBox(width: 6),
                  // _renderShareWidget(message),
                  // const SizedBox(width: 8),
                  // _renderCopyWidget(message),
                ];

                Widget? customContent;

                if (isMe) {
                  defaultAvatar = 'assets/images/user_icon.png';
                  defaultRoleName = message.fields.sender;
                  defaultColor = const Color.fromRGBO(236, 236, 236, 1.0);
                  defaultTextColor = Colors.black;
                  defaultTextPrefix = '';
                  defaultIcons = [
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      color: Colors.red,
                      onPressed: () {
                        // Show confirmation dialog before deleting
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Delete Message"),
                              content: const Text(
                                  "Are you sure you want to delete this message?"),
                              actions: [
                                TextButton(
                                  child: const Text("Cancel"),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                                TextButton(
                                  child: const Text("Delete"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    deleteMessage(message.pk);
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ];
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 12.0),
                  // alignment:
                  //     isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
                    decoration: BoxDecoration(
                      color: defaultColor,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(30.0),
                                    clipBehavior: Clip.antiAlias,
                                    child: Image(
                                      width: 36,
                                      height: 36,
                                      image: AssetImage(defaultAvatar),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    defaultRoleName,
                                    softWrap: true,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      height: 24 / 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: defaultIcons,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Divider(
                          height: 2,
                          color: Color.fromRGBO(124, 119, 119, 1.0),
                        ),
                        const SizedBox(height: 10),
                        customContent ??
                            MarkdownBody(
                              data:
                                  '$defaultTextPrefix${message.fields.content}',
                              shrinkWrap: true,
                              selectable: true,
                              styleSheet: MarkdownStyleSheet(
                                textScaleFactor: 1.1,
                                textAlign: WrapAlignment.start,
                                p: TextStyle(
                                  height: 1.5,
                                  color: defaultTextColor,
                                ),
                              ),
                            ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Message input form
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: "Message",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                      ),
                      onChanged: (String? value) {
                        setState(() {
                          _message = value!;
                        });
                      },
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return "Message tidak boleh kosong!";
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  IconButton(
                      icon: Icon(Icons.send),
                      color: Theme.of(context).colorScheme.primary,
                      onPressed: () async {
                        if (_formKey.currentState!.validate() &&
                            _message.isNotEmpty) {
                          try {
                            final response = await http.post(
                              Uri.parse(
                                  "http://127.0.0.1:8000/chat/send-message-flutter/"),
                              headers: <String, String>{
                                'Content-Type':
                                    'application/json; charset=UTF-8',
                              },
                              body: jsonEncode(<String, String>{
                                'messages': _message,
                                'chat_id': widget.chatId
                              }),
                            );

                            if (response.statusCode == 200) {
                              final responseData = jsonDecode(response.body);
                              if (responseData['status'] == 'success') {
                                setState(() {
                                  messages.add(Message.fromJson(
                                      responseData['message']));
                                });
                                _formKey.currentState!.reset();
                                // Clear _message after sending
                                _message = '';

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Berhasil")),
                                );
                              }
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Error: ${e.toString()}")),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Pesan tidak boleh kosong")),
                          );
                        }
                      }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
