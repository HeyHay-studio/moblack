import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'core/theme.dart';
import 'features/home/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyA96BC9AcGmt24DJt6oTff3yITR5s6mUII",
        authDomain: "moblack-c6525.firebaseapp.com",
        projectId: "moblack-c6525",
        storageBucket: "moblack-c6525.firebasestorage.app",
        messagingSenderId: "672867411539",
        appId: "1:672867411539:web:6d41bdbbd980690756c8a6",
        measurementId: "G-VGF3RTPHDH",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beauty By Moblack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomePage(),
    );
  }
}
