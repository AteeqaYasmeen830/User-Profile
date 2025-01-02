import 'package:hive/hive.dart';

class ProfileModel {
  String? name;
  String? profileImagePath;
  String? backgroundImagePath;

  ProfileModel({this.name, this.profileImagePath, this.backgroundImagePath});

  factory ProfileModel.fromHive(Box box) {
    return ProfileModel(
      name: box.get('name', defaultValue: ''),
      profileImagePath: box.get('profileImage'),
      backgroundImagePath: box.get('backgroundImage'),
    );
  }

  void saveToHive(Box box) {
    box.put('name', name);
    box.put('profileImage', profileImagePath);
    box.put('backgroundImage', backgroundImagePath);
  }
}
