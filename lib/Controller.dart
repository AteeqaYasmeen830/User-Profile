import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive/hive.dart';
import 'Model.dart';

class ProfileController {
  final Box _profileBox = Hive.box('profileBox');
  ProfileModel profile = ProfileModel();

  // Add a ValueNotifier for theme mode
  final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

  ProfileController() {
    _loadProfile();
  }

  // Load the profile data
  void _loadProfile() {
    profile = ProfileModel.fromHive(_profileBox);
  }

  // Method to toggle theme
  void toggleTheme() {
    themeNotifier.value =
    themeNotifier.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }

  // Method to select image
  Future<void> selectImage(ImageSource source, bool isProfileImage) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      if (isProfileImage) {
        profile.profileImagePath = pickedFile.path;
      } else {
        profile.backgroundImagePath = pickedFile.path;
      }
      saveProfile();
    }
  }

  // Method to delete image
  void deleteImage(bool isProfileImage) {
    if (isProfileImage) {
      profile.profileImagePath = null;
    } else {
      profile.backgroundImagePath = null;
    }
    saveProfile();
  }

  // Save the profile data to Hive
  void saveProfile() {
    profile.saveToHive(_profileBox);
  }
}
