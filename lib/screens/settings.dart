import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import 'package:talk/screens/blocked_users.dart';
import 'package:talk/services/auth_service.dart';
import 'package:talk/services/theme_provider.dart';
import 'package:talk/widget/my_textfield.dart';
import 'package:talk/widget/settings_tile.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final AuthService _authService = AuthService();
  final TextEditingController _changeUnameController = TextEditingController();

  String? _profileImageUrl;
  bool _isLoadingImage = false;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    setState(() => _isLoadingImage = true);
    try {
      final fetchedPhotoUrl = await _authService.getProfileImageURL();
      setState(() {
        _profileImageUrl = fetchedPhotoUrl;
        _isLoadingImage = false;
      });
    } catch (e) {
      debugPrint('Error loading profile image in Settings: $e');
      setState(() {
        _profileImageUrl = null;
        _isLoadingImage = false;
      });
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      File originalFile = File(pickedFile.path);
      final compressed = await FlutterImageCompress.compressAndGetFile(
        originalFile.path,
        '${originalFile.path}_compressed.jpg',
        quality: 65,
      );

      if (compressed != null) {
        setState(() => _isLoadingImage = true);
        try {
          String downloadUrl = await _authService.uploadProfileImage(
            File(compressed.path),
          );

          setState(() => _profileImageUrl = downloadUrl);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile image updated.")),
          );
        } catch (e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Failed to upload image: $e")));
        } finally {
          setState(() => _isLoadingImage = false);
        }
      }
    }
  }

  Future<void> deleteProfileImage() async {
    try {
      setState(() => _isLoadingImage = true);
      await _authService.deleteProfileImage();

      setState(() {
        _profileImageUrl = null;
        _isLoadingImage = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Profile image deleted.")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to delete image: $e")));
      setState(() => _isLoadingImage = false);
    }
  }

  void changeUsernameDialog(BuildContext context) async {
    String? fetchedUsername = await _authService.getUsername();
    _changeUnameController.text = fetchedUsername; //?? ''
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Change Username"),
          content: MyTextField(
            hintText: fetchedUsername.toString(),
            obscureText: false,
            controller: _changeUnameController,
            multiLine: false,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _changeUnameController.clear();
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => changeUsername(context),
              child: const Text("Change"),
            ),
          ],
        );
      },
    );
    _changeUnameController.clear();
  }

  void changeUsername(BuildContext context) async {
    String newUsername = _changeUnameController.text.trim();
    if (newUsername.isNotEmpty) {
      try {
        await _authService.changeUsername(newUsername);
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username changed successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to change username: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid username.')),
      );
    }
  }

  void userWantsToDeleteAccount(BuildContext context) async {
    bool confirm =
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Confirm Delete!"),
            content: const Text(
              "This will delete your account permanently! Are you sure?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text("Delete"),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      try {
        Navigator.pop(context);
        await _authService.deleteAccount();
      } catch (e) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentThemeMode = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Settings",
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 3,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 65,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    backgroundImage:
                        _profileImageUrl != null && _profileImageUrl!.isNotEmpty
                        ? NetworkImage(_profileImageUrl!)
                        : null,
                    child: _isLoadingImage
                        ? const CircularProgressIndicator()
                        : (_profileImageUrl == null || _profileImageUrl!.isEmpty
                              ? Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                                )
                              : null),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    radius: 18,
                    child: IconButton(
                      icon: const Icon(
                        Icons.edit,
                        size: 16,
                        color: Colors.white,
                      ),
                      onPressed: pickImage,
                    ),
                  ),
                ),
              ],
            ),
            if (_profileImageUrl != null && _profileImageUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: TextButton.icon(
                  onPressed: deleteProfileImage,
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text(
                    "Delete Profile Image",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            const SizedBox(height: 10),

            MySettingsListTile(
              onTap: () => themeNotifier.toggleTheme(),
              title: "Dark Mode",
              action: CupertinoSwitch(
                value: currentThemeMode == ThemeModeType.dark,
                onChanged: (value) => themeNotifier.toggleTheme(),
              ),
              color: Theme.of(context).cardColor,
              textColor: Theme.of(context).colorScheme.primary,
            ),

            MySettingsListTile(
              onTap: () => changeUsernameDialog(context),
              title: "Change Username",
              action: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => changeUsernameDialog(context),
              ),
              color: Theme.of(context).cardColor,
              textColor: Theme.of(context).colorScheme.primary,
            ),

            MySettingsListTile(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => BlockedUsersPage()),
              ),
              title: "Blocked Users",
              action: IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => BlockedUsersPage()),
                ),
                icon: const Icon(Icons.arrow_forward_rounded),
                color: Theme.of(context).colorScheme.primary,
              ),
              color: Theme.of(context).cardColor,
              textColor: Theme.of(context).colorScheme.primary,
            ),

            MySettingsListTile(
              onTap: () => userWantsToDeleteAccount(context),
              title: "Delete Account!",
              action: IconButton(
                onPressed: () => userWantsToDeleteAccount(context),
                icon: const Icon(Icons.delete, size: 30, color: Colors.red),
              ),
              color: Theme.of(context).cardColor,
              textColor: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}
