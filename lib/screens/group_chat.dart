import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:talk/screens/group_list.dart';
import 'package:talk/services/auth_service.dart';
import 'package:talk/services/chat_service.dart';
import 'package:talk/widget/chat_bubble.dart';
import 'package:talk/widget/my_textfield.dart';

class GroupChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;

  const GroupChatPage({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<GroupChatPage> createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  final FocusNode _messageFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _messageFocusNode.addListener(() {
      if (_messageFocusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 300), () => _scrollDown());
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollDown());
  }

  @override
  void dispose() {
    _messageFocusNode.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollDown() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() async {
    String? userName = await _authService.getUsername();
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendGroupMessage(
        widget.groupId,
        _messageController.text.trim(),
        userName, //?? ""
      );
      _messageController.clear();
      _scrollDown();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                widget.groupName.isNotEmpty
                    ? widget.groupName[0].toUpperCase()
                    : '?',
                style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              widget.groupName,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        foregroundColor: theme.colorScheme.onSurface,
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: theme.colorScheme.onSurface),
            onPressed: _showDeleteConfirmationDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: theme.scaffoldBackgroundColor),
              child: _buildMessageList(),
            ),
          ),
          _buildUserInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _chatService.getGroupMessages(widget.groupId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error: ${snapshot.error}",
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        }

        final messages = snapshot.data ?? [];

        if (messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 80,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: 20),
                Text(
                  'Say Hello!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Start a new group conversation',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          );
        }

        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollDown());

        return ListView.builder(
          controller: _scrollController,
          itemCount: messages.length,
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          itemBuilder: (context, index) {
            final messageData = messages[index];
            return _buildMessageItem(messageData);
          },
        );
      },
    );
  }

  Widget _buildMessageItem(Map<String, dynamic> data) {
    bool isCurrentUser = data['senderID'] == _authService.getCurrentUser()!.uid;

    Timestamp timestamp = data["timestamp"];
    DateTime dateTime = timestamp.toDate();
    String formattedTime =
        "${dateTime.hour % 12}:${dateTime.minute.toString().padLeft(2, '0')} ${dateTime.hour >= 12 ? 'PM' : 'AM'}";

    final String? senderProfileImage = data['senderProfileImage'] as String?;
    final String? senderUname = data['senderUname'] as String?;

    return ChatBubble(
      isCurrentUser: isCurrentUser,
      message: data["message"],
      messageId: data['messageId'],
      userId: data["senderID"],
      formattedTime: formattedTime,
      uname: data["uname"],
      senderProfileImageUrl: senderProfileImage,
      senderDisplayName: senderUname,
    );
  }

  Widget _buildUserInput() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      color: theme.appBarTheme.backgroundColor,
      child: Row(
        children: [
          Expanded(
            child: MyTextField(
              circular: true,
              multiLine: true,
              focusNode: _messageFocusNode,
              controller: _messageController,
              hintText: "Type a message...",
              obscureText: false,
              fillColor: theme.appBarTheme.backgroundColor,
              hintStyle: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textStyle: TextStyle(color: theme.colorScheme.onSurface),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: _sendMessage,
              icon: Icon(
                Icons.send_rounded,
                color: theme.colorScheme.onPrimary,
              ),
              padding: const EdgeInsets.all(14),
              splashRadius: 28,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog() {
    String groupName = widget.groupName;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Group'),
          content: Text(
            'Are you sure you want to delete "$groupName" group? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Cancel",
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
            TextButton(
              onPressed: () async {
                await _chatService.deleteGroup(widget.groupId);
                Navigator.of(context).pop();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => GroupListPage()),
                  (route) => route.isFirst,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$groupName group deleted successfully!'),
                  ),
                );
              },
              child: Text(
                "Delete",
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        );
      },
    );
  }
}
