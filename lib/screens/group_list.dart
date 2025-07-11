import 'package:flutter/material.dart';

import 'package:talk/screens/add_groups.dart';
import 'package:talk/screens/group_chat.dart';
import 'package:talk/services/chat_service.dart';
import 'package:talk/widget/user_tile.dart';

class GroupListPage extends StatelessWidget {
  final ChatService chatService = ChatService();

  GroupListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _appbar(context), body: _buildGroupList());
  }

  AppBar _appbar(BuildContext context) {
    return AppBar(
      title: Text(
        'Groups',
        style: TextStyle(color: Theme.of(context).colorScheme.primary),
      ),

      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: IconButton(
            icon: Icon(Icons.add, color: Theme.of(context).colorScheme.primary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddGroupPage()),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGroupList() {
    return StreamBuilder(
      stream: chatService.getUserGroups(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("Error");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'No group found, Add a new group by +',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        }

        final groups = snapshot.data!;

        return ListView.builder(
          itemCount: groups.length,
          itemBuilder: (context, index) {
            final group = groups[index];
            return UserTile(
              text: group.name,
              icon: Icons.group,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        GroupChatPage(groupId: group.id, groupName: group.name),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
