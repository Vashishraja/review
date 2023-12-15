import 'package:flutter/material.dart';
import 'package:loveshots_review/home_screen.dart';
import 'package:supabase/supabase.dart';

void main() {
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
   MyApp({super.key});

  final SupabaseClient client = SupabaseClient(
    'https://rubowdmygoftnjzqqdkn.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ1Ym93ZG15Z29mdG5qenFxZGtuIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTU0OTcwNTAsImV4cCI6MjAxMTA3MzA1MH0.eSLZoqiKpyrXUZebas6xDeungntmk36Cob2fjkxf-PQ',
  );  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.cyan,
      ),
      home:  HomePage(client: client,),
    );
  }
}
