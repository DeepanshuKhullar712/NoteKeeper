import 'package:flutter/material.dart';
import 'package:flutter_notekeeper/screens/noteList.dart';

void main(){
  runApp(MyApp());
}

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "NoteKeeper",
      theme: ThemeData(
        brightness: Brightness.light,
      ),
      debugShowCheckedModeBanner: false,
      home: NoteList(),
    );
  }
}



