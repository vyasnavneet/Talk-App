import 'package:flutter/material.dart';

import 'package:talk/services/chat_service.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;
  final String messageId;
  final String userId;
  final String formattedTime;
  final String uname;

  final String? senderProfileImageUrl;
  final String? senderDisplayName;

  const ChatBubble({
    super.key,
    required this.isCurrentUser,
    required this.message,
    required this.messageId,
    required this.userId,
    required this.formattedTime,
    required this.uname,
    this.senderProfileImageUrl,
    this.senderDisplayName,
  });

  void _showOptions(BuildContext context, String messageId, String userId) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.flag),
                title: const Text('Report'),
                onTap: () {
                  Navigator.pop(context);
                  _reportMessage(context, messageId, userId);
                },
              ),
              ListTile(
                leading: const Icon(Icons.block),
                title: const Text('Block User'),
                onTap: () {
                  Navigator.pop(context);
                  _blockUser(context, userId);
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text('Cancel'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _reportMessage(BuildContext context, String messageId, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Report Message"),
        content: const Text("Are you sure you want to report this message?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          TextButton(
            onPressed: () {
              ChatService().reportUser(messageId, userId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Message Reported!")),
              );
            },
            child: Text(
              'Report',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _blockUser(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Block User"),
        content: const Text("Are you sure you want to block this user?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          TextButton(
            onPressed: () {
              ChatService().blockUser(userId);
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text("User Blocked!")));
            },
            child: Text(
              'Block',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Color bubbleColor = isCurrentUser
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.secondaryContainer;
    final Color textColor = isCurrentUser
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onSecondaryContainer;

    final CrossAxisAlignment columnAlignment = isCurrentUser
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;
    final MainAxisAlignment rowAlignment = isCurrentUser
        ? MainAxisAlignment.end
        : MainAxisAlignment.start;

    final double horizontalMargin = 80;
    final double messageSidePadding = 15;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        isCurrentUser ? horizontalMargin : messageSidePadding,
        4,
        isCurrentUser ? messageSidePadding : horizontalMargin,
        4,
      ),
      child: Column(
        crossAxisAlignment: columnAlignment,
        children: [
          if (!isCurrentUser &&
              (senderDisplayName != null || senderProfileImageUrl != null))
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0, left: 4.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: rowAlignment,
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    backgroundImage:
                        (senderProfileImageUrl != null &&
                            senderProfileImageUrl!.isNotEmpty)
                        ? NetworkImage(senderProfileImageUrl!)
                        : null,
                    child:
                        (senderProfileImageUrl == null ||
                            senderProfileImageUrl!.isEmpty)
                        ? Text(
                            (senderDisplayName?.isNotEmpty == true)
                                ? senderDisplayName![0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontSize: 10,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 6),
                  if (senderDisplayName != null &&
                      senderDisplayName!.isNotEmpty)
                    Text(
                      senderDisplayName!,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
          GestureDetector(
            onLongPress: () {
              if (!isCurrentUser) {
                _showOptions(context, messageId, userId);
              }
            },
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: isCurrentUser
                      ? const Radius.circular(18)
                      : const Radius.circular(4),
                  bottomRight: isCurrentUser
                      ? const Radius.circular(4)
                      : const Radius.circular(18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withValues(alpha: 0.08),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    formattedTime,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: textColor.withValues(alpha: 0.7),
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
