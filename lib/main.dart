import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('profileBox');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ValueNotifier<ThemeMode> _themeNotifier = ValueNotifier(ThemeMode.light);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeNotifier,
      builder: (context, themeMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: themeMode,
          home: UserProfilePage(themeNotifier: _themeNotifier),
        );
      },
    );
  }
}

class UserProfilePage extends StatefulWidget {
  final ValueNotifier<ThemeMode> themeNotifier;

  UserProfilePage({required this.themeNotifier});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  File? _profileImage;
  File? _backgroundImage;
  TextEditingController _nameController = TextEditingController();
  final Box _profileBox = Hive.box('profileBox');

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    setState(() {
      _nameController.text = _profileBox.get('name', defaultValue: '');
      String? profilePath = _profileBox.get('profileImage');
      String? backgroundPath = _profileBox.get('backgroundImage');
      _profileImage = profilePath != null ? File(profilePath) : null;
      _backgroundImage = backgroundPath != null ? File(backgroundPath) : null;
    });
  }

  void _pickImage(bool isProfile) async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text("Take Photo"),
              onTap: () async {
                Navigator.pop(context);
                await _selectImage(ImageSource.camera, isProfile);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo),
              title: Text("Choose from Gallery"),
              onTap: () async {
                Navigator.pop(context);
                await _selectImage(ImageSource.gallery, isProfile);
              },
            ),
            if (isProfile ? _profileImage != null : _backgroundImage != null)
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text("Delete Image", style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    if (isProfile) {
                      _profileImage = null;
                      _profileBox.delete('profileImage');
                    } else {
                      _backgroundImage = null;
                      _profileBox.delete('backgroundImage');
                    }
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Image deleted successfully!')),
                  );
                },
              ),
          ],
        );
      },
    );
  }

  Future<void> _selectImage(ImageSource source, bool isProfile) async {
    try {
      final ImagePicker _picker = ImagePicker();
      final XFile? pickedFile = await _picker.pickImage(source: source);

      if (pickedFile != null) {
        setState(() {
          if (isProfile) {
            _profileImage = File(pickedFile.path);
            _profileBox.put('profileImage', pickedFile.path);
          } else {
            _backgroundImage = File(pickedFile.path);
            _profileBox.put('backgroundImage', pickedFile.path);
          }
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  void _toggleTheme() {
    widget.themeNotifier.value = widget.themeNotifier.value == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  void _saveProfile() {
    String name = _nameController.text;

    if (name.isEmpty || _profileImage == null || _backgroundImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please complete all fields before saving.')),
      );
      return;
    }

    _profileBox.put('name', name);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Profile saved successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = widget.themeNotifier.value == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
            onPressed: _toggleTheme,
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
                      image: _backgroundImage != null
                          ? DecorationImage(
                        image: FileImage(_backgroundImage!),
                        fit: BoxFit.cover,
                      )
                          : null,
                    ),
                    child: _backgroundImage == null
                        ? Center(
                      child: Text(
                        "Tap to add background image",
                        style: TextStyle(
                          color: isDarkMode ? Colors.deepPurple : Colors.black54,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                        : null,
                  ),
                ),
                Positioned(
                  bottom: -50,
                  child: GestureDetector(
                    onTap: () => _pickImage(true),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : null,
                      child: _profileImage == null
                          ? Icon(
                        Icons.camera_alt,
                        size: 40,
                        color: isDarkMode ? Colors.white : Colors.black54, // Change icon color based on theme
                      )
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
            ElevatedButton(
              onPressed: _saveProfile,
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
