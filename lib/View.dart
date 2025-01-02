import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'Controller.dart';

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  late ProfileController _controller;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _controller = ProfileController();
    _nameController = TextEditingController(text: _controller.profile.name);
  }

  // Method to pick image
  void _pickImage(bool isProfile) async {
    await showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.camera_alt),
            title: Text("Take Photo"),
            onTap: () async {
              Navigator.pop(context);
              await _controller.selectImage(ImageSource.camera, isProfile);
              setState(() {});
            },
          ),
          ListTile(
            leading: Icon(Icons.photo),
            title: Text("Choose from Gallery"),
            onTap: () async {
              Navigator.pop(context);
              await _controller.selectImage(ImageSource.gallery, isProfile);
              setState(() {});
            },
          ),
          if ((isProfile && _controller.profile.profileImagePath != null) ||
              (!isProfile && _controller.profile.backgroundImagePath != null))
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text("Delete Image", style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _controller.deleteImage(isProfile);
                setState(() {});
              },
            ),
        ],
      ),
    );
  }

  // Method to save the profile
  void _saveProfile() {
    _controller.profile.name = _nameController.text;
    if (_nameController.text.isEmpty ||
        _controller.profile.profileImagePath == null ||
        _controller.profile.backgroundImagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please complete all fields before saving.')),
      );
      return;
    }
    _controller.saveProfile();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Profile saved successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _controller.themeNotifier,
      builder: (context, themeMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: themeMode,
          home: Scaffold(
            appBar: AppBar(
              title: Text('User Profile'),
              actions: [
                IconButton(
                  icon: Icon(
                    themeMode == ThemeMode.dark
                        ? Icons.dark_mode
                        : Icons.light_mode,
                  ),
                  onPressed: _controller.toggleTheme,  // Toggle the theme mode
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => _pickImage(false),
                        child: Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            image: _controller.profile.backgroundImagePath != null
                                ? DecorationImage(
                              image: FileImage(File(_controller.profile.backgroundImagePath!)),
                              fit: BoxFit.cover,
                            )
                                : null,
                          ),
                          child: _controller.profile.backgroundImagePath == null
                              ? Center(child: Text("Tap to add background image"))
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: -50,
                        child: GestureDetector(
                          onTap: () => _pickImage(true),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundImage: _controller.profile.profileImagePath != null
                                ? FileImage(File(_controller.profile.profileImagePath!))
                                : null,
                            child: _controller.profile.profileImagePath == null
                                ? Icon(Icons.camera_alt, size: 40)
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 60),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Enter your name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  ElevatedButton(onPressed: _saveProfile, child: Text('Save')),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
