import 'package:flutter/material.dart';

import 'package:talk/screens/home.dart';
import 'package:talk/services/auth_service.dart';
import 'package:talk/services/chat_service.dart';

class AddGroupPage extends StatefulWidget {
  const AddGroupPage({super.key});

  @override
  AddGroupPageState createState() => AddGroupPageState();
}

class AddGroupPageState extends State<AddGroupPage> {
  final TextEditingController _groupNameController = TextEditingController();
  final List<String> _selectedMembers = [];
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
  }

  Widget _buildUserList() {
    return StreamBuilder(
      stream: _chatService.getUserStreamExcludingBlocked(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("Error");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          children: snapshot.data!
              .map<Widget>((userData) => _buildUserListItem(userData, context))
              .toList(),
        );
      },
    );
  }

  Widget _buildUserListItem(
    Map<String, dynamic> userData,
    BuildContext context,
  ) {
    if (_authService.getCurrentUser() != null &&
        userData["email"] != _authService.getCurrentUser()!.email) {
      return ListTile(
        title: Text(userData["uname"]),
        subtitle: Text(userData["email"]),
        trailing: Checkbox(
          value: _selectedMembers.contains(userData["uid"]),
          onChanged: (bool? value) {
            setState(() {
              if (value == true) {
                _selectedMembers.add(userData["uid"]);
              } else {
                _selectedMembers.remove(userData["uid"]);
              }
            });
          },
        ),
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Group',
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
              (route) => route.isFirst,
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _groupNameController,
              decoration: InputDecoration(
                labelText: 'Group Name',
                labelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _buildUserList(),

              /*ListView.builder(
                itemCount: _users.length,
                itemBuilder: (context, index) {
                  final user = _users[index];
                  return ListTile(
                    title: Text(user[
                        'email']),
                    trailing: Checkbox(
                      value: _selectedMembers
                          .contains(user['id']),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _selectedMembers.add(user['id']);
                          } else {
                            _selectedMembers.remove(user['id']);
                          }
                        });
                      },
                    ),
                  );
                },
              ),*/
            ),
            ElevatedButton(
              onPressed: () async {
                if (_groupNameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Give your group some name!')),
                  );
                }
                if (_groupNameController.text.isNotEmpty &&
                    _selectedMembers.isNotEmpty) {
                  await _chatService.createGroup(
                    _groupNameController.text,
                    _selectedMembers,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Create Group'),
            ),
          ],
        ),
      ),
    );
  }
}
