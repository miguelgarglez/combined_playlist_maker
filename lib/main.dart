import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:combined_playlist_maker/models/user.dart';
import 'package:combined_playlist_maker/src/routes.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  // Hive initialization
  await Hive.initFlutter();
  Hive.registerAdapter(UserAdapter());
  await Hive.openBox('auth');
  await Hive.openBox('codeVerifiers');
  await Hive.openBox('urlCode');
  await Hive.openBox('firstTime');
  await Hive.openBox<User>('users');
  // Load .env file
  await dotenv.load(fileName: ".env");

  usePathUrlStrategy();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: myAppRoutes(),
      title: 'Combined Playlist Maker',
      theme: ThemeData.dark(useMaterial3: true),
    );
  }
}

List hiveGetUsers() {
  return Hive.box<User>('users').values.toList();
}

bool hiveDeleteUser(String userId) {
  var userBox = Hive.box<User>('users');
  if (userBox.containsKey(userId)) {
    userBox.delete(userId);
    return true;
  }
  return false;
}

void deleteContentFromHive() async {
  await Hive.box('auth').clear();
  await Hive.box<User>('users').clear();
  await Hive.box('codeVerifiers').clear();
  await Hive.box('urlCode').clear();
}
