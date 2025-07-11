import 'package:flutter/material.dart';

import 'package:talk/screens/group_list.dart';
import 'package:talk/screens/home.dart';
import 'package:talk/screens/settings.dart';
import 'package:talk/services/auth_service.dart';
import 'package:talk/widget/drawer_tile.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  final AuthService _authService = AuthService();

  String email = 'Loading...';
  String username = 'Loading username...';
  String? profilePhotoUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = _authService.getCurrentUser();
      await user?.reload();

      final fetchedUsername = await _authService.getUsername();
      final fetchedPhotoUrl = await _authService.getProfileImageURL();

      if (mounted) {
        setState(() {
          email = user?.email ?? 'No Email';
          username = fetchedUsername; //?? 'No Username'
          profilePhotoUrl = fetchedPhotoUrl;
          debugPrint("Updated profile URL in Drawer: $profilePhotoUrl");
        });
      }
    } catch (e) {
      debugPrint('Failed to load user data in Drawer: $e');
      if (mounted) {
        setState(() {
          profilePhotoUrl = null;
        });
      }
    }
  }

  void logout(BuildContext context) {
    _authService.signOut();
  }

  void _showAboutDialog(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          backgroundColor: theme.colorScheme.surface,
          title: Row(
            children: [
              Icon(Icons.chat_rounded, color: theme.colorScheme.primary),
              const SizedBox(width: 10),
              Text(
                "About Talk",
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  "Talk: A fast and secure messaging app.",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  "This app provides a quick messaging experience for connecting with friends and groups, more features coming soon!",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Text(
                  "Designed by:",
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Shubham Ramdeo",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Developed by:",
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Navneed Vyas",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 25),
                Text(
                  "App Version: 2.0.0",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Let's Talk!",
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initials = email.isNotEmpty ? email[0].toUpperCase() : '?';

    return Drawer(
      //backgroundColor: theme.colorScheme.black,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.9),
                  theme.colorScheme.primaryContainer.withValues(alpha: 0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                profilePhotoUrl != null && profilePhotoUrl!.isNotEmpty
                    ? CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(profilePhotoUrl!),
                      )
                    : CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        child: Text(
                          initials,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                const SizedBox(height: 12),
                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(username, style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: [
                MyDrawerTile(
                  title: "Home",
                  icon: Icons.home_rounded,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                      (Route<dynamic> route) => false,
                    );
                  },
                ),
                MyDrawerTile(
                  title: "Groups",
                  icon: Icons.group_rounded,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => GroupListPage()),
                    );
                  },
                ),
                MyDrawerTile(
                  title: "User Settings",
                  icon: Icons.settings_rounded,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SettingsPage()),
                    ).then((_) {
                      _loadUserData();
                    });
                  },
                ),
                MyDrawerTile(
                  title: "About",
                  icon: Icons.info_rounded,
                  onTap: () {
                    Navigator.pop(context);
                    _showAboutDialog(context);
                  },
                ),
              ],
            ),
          ),

          const Divider(),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: MyDrawerTile(
              title: "Logout",
              icon: Icons.logout_rounded,
              onTap: () => logout(context),
            ),
          ),
        ],
      ),
    );
  }
}
