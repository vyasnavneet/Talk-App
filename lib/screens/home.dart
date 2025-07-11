import 'package:flutter/material.dart';

import 'package:talk/screens/chat.dart';
import 'package:talk/services/auth_service.dart';
import 'package:talk/services/chat_service.dart';
import 'package:talk/widget/drawer.dart';
import 'package:talk/widget/user_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final ChatService _chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      drawer: const MyDrawer(),
      appBar: AppBar(
        title: Text(
          'Chats',
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        //backgroundColor: theme.colorScheme.background,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
      ),
      body: Container(
        //color: theme.colorScheme.background,
        padding: const EdgeInsets.only(top: 10),
        child: _buildUserList(),
      ),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder(
      stream: _chatService.getUserStreamExcludingBlocked(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Something went wrong: ${snapshot.error}"));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data!;
        final currentUser = _authService.getCurrentUser();

        final filteredUsers = users
            .where((userData) => userData["email"] != currentUser?.email)
            .toList();

        if (filteredUsers.isEmpty) {
          return const Center(child: Text("No users found"));
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: filteredUsers.length,
          separatorBuilder: (_, __) => const SizedBox(height: 4),
          itemBuilder: (context, index) {
            final userData = filteredUsers[index];
            return _buildUserListItem(userData, context);
          },
        );
      },
    );
  }

  Widget _buildUserListItem(
    Map<String, dynamic> userData,
    BuildContext context,
  ) {
    final currentUser = _authService.getCurrentUser();

    if (currentUser != null && userData["email"] != currentUser.email) {
      final String? profileImageUrl = userData["profileImage"] as String?;

      return UserTile(
        email: userData["email"],
        unreadMessageCount: userData['unreadCount'],
        text: userData["uname"],
        profileImageUrl: profileImageUrl,
        onTap: () async {
          await _chatService.markMessageAsRead(userData["uid"]);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatPage(
                reciverID: userData["uid"],
                reciverEmail: userData["email"],
                uname: userData["uname"],
                receiverProfileImageUrl: profileImageUrl,
              ),
            ),
          );
        },
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
