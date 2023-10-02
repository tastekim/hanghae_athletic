import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hanghae_athletic/util/nickname_generator.dart';
import 'package:hanghae_athletic/view/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  var app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  var auth = FirebaseAuth.instanceFor(app: app);
  FirebaseFirestore.instanceFor(app: app);

  var user = await auth.signInAnonymously();

  try {
    int? myPoints = prefs.getInt('points');
    String? myUid = prefs.getString('uid');
    String? myNickname = prefs.getString('nickname');

    if (myPoints == null ) {
      await prefs.setInt('points', 0);
    }

    if (myUid ==null) {
      await prefs.setString('uid', user.user!.uid);
    }

    if (myNickname == null) {
      String nickname = nicknameGenerator();
      await prefs.setString('nickname', nickname);
    }
    debugPrint('set uid: ${prefs.getString('uid')}');
    debugPrint('set nickname: ${prefs.getString('nickname')}');
  } catch (e) {
    debugPrint(e.toString());
  }

  runApp(const MyApp());
}

void initialize() async {

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          onBackground: Colors.black,
          seedColor: Colors.white,
        ),
      ),
      home: Home(),
    );
  }
}
