import 'package:flutter/material.dart';
import 'package:pertareport_mobile/utils/mainpage_theme.dart';
import 'package:pertareport_mobile/models/auth/profile_entry.dart';

import 'dart:convert';
import 'package:pertareport_mobile/screens/chat/room_chat.dart';
import 'package:http/http.dart' as http;

class AreaListView extends StatelessWidget {
  final AnimationController? animationController;
  final Animation<double>? animation;
  final User item;

  const AreaListView(
      {super.key,
      this.animationController,
      this.animation,
      required this.item});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation!,
          child: new Transform(
            transform: new Matrix4.translationValues(
                0.0, 30 * (1.0 - animation!.value), 0.0),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                      left: 24, right: 24, top: 0, bottom: 0),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 7, bottom: 7),
                        child: InkWell(
                          onTap: () async {
                            try {
                              final response = await http.post(
                                Uri.parse(
                                    "http://127.0.0.1:8000/chat/handle-room-flutter/"),
                                headers: {
                                  "Content-Type": "application/json",
                                },
                                body: jsonEncode({
                                  "id": item.pk,
                                }),
                              );

                              if (response.statusCode == 200) {
                                final data = jsonDecode(response.body);
                                print(data); // Handle the response data

                                // Navigate to new screen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MessageEntryFormPage(
                                      chatId: data[
                                          "chat_id"], // Passing chat_id ke screen berikutnya
                                    ),
                                  ),
                                );
                              } else {
                                print(
                                    'Request failed with status: ${response.statusCode}');
                              }
                            } catch (e) {
                              print('Error: $e');
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: FitnessAppTheme.white,
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(8.0),
                                  bottomLeft: Radius.circular(8.0),
                                  bottomRight: Radius.circular(8.0),
                                  topRight: Radius.circular(8.0)),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                    color:
                                        FitnessAppTheme.grey.withOpacity(0.4),
                                    offset: Offset(1.1, 1.1),
                                    blurRadius: 10.0),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.centerLeft,
                              children: <Widget>[
                                ClipRRect(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8.0)),
                                  child: SizedBox(
                                    height: 40,
                                    child: AspectRatio(
                                      aspectRatio: 1.714,
                                      child: Image.asset(
                                          "assets/images/user_icon.png"),
                                    ),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 80,
                                            right: 16,
                                            top: 16,
                                          ),
                                          child: Text(
                                            item.fields.username,
                                            textAlign: TextAlign.left,
                                            style: const TextStyle(
                                              fontFamily:
                                                  FitnessAppTheme.fontName,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14,
                                              letterSpacing: 0.0,
                                              color: FitnessAppTheme.lightbrown,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 80,
                                        bottom: 12,
                                        top: 4,
                                        right: 16,
                                      ),
                                      child: Text(
                                        "Tap to start the chat",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontFamily: FitnessAppTheme.fontName,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 10,
                                          letterSpacing: 0.0,
                                          color: FitnessAppTheme.grey
                                              .withOpacity(0.5),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
