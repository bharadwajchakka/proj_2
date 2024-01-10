import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:proj_2/activity/Basketball.dart';
import 'package:proj_2/activity/badminton.dart';

void main() async{
  //WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp();
  runApp(MaterialApp(
    routes: {

      "/" : (context) => BasketballMatchApp(),
    },
  ));
}