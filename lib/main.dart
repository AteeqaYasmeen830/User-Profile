import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'View.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('profileBox');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: UserProfilePage(),
    );
  }
}
