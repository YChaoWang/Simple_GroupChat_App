import 'package:chat_app/widgets/message_bubbles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  final authenticatedUser = FirebaseAuth.instance.currentUser!;
  ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chat')
            .orderBy(
              'createdAt',
              descending: true,
            )
            .snapshots(),
        builder: (ctx, chatSnapshot) {
          if (chatSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!chatSnapshot.hasData || chatSnapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No messages found!'));
          }

          if (chatSnapshot.hasError) {
            return const Center(child: Text('Something went wrong...'));
          }

          final chatDocs = chatSnapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.only(bottom: 40, left: 13, right: 13),
            reverse: true,
            itemCount: chatDocs.length,
            itemBuilder: (ctx, index) {
              final chatMessage = chatDocs[index].data();
              final timestamp = chatMessage['createdAt'] as Timestamp;
              final createdAtDateTime = timestamp.toDate();
              final nextChatMessage = index + 1 < chatDocs.length
                  ? chatDocs[index + 1].data()
                  : null;
              final currentMessageUserId = chatMessage['userId'];
              final nextChatMessageUserId =
                  nextChatMessage != null ? nextChatMessage['userId'] : null;
              final nextUserIsSame =
                  nextChatMessageUserId == currentMessageUserId;
              if (nextUserIsSame) {
                return MessageBubble.next(
                    messageTime: createdAtDateTime,
                    message: chatMessage['text'],
                    isMe: authenticatedUser.uid == currentMessageUserId);
              } else {
                return MessageBubble.first(
                  messageTime: createdAtDateTime,
                  userImage: chatMessage['userImage'],
                  username: chatMessage['userName'],
                  message: chatMessage['text'],
                  isMe: authenticatedUser.uid == currentMessageUserId,
                );
              }
            },
          );
        });
  }
}
