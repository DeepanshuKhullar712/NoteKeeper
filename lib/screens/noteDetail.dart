import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_notekeeper/utils/database_helper.dart';
import 'package:flutter_notekeeper/models/node.dart';

class noteDetail extends StatefulWidget {
  final String appBarTitle;
  final Note note;
  noteDetail(this.note,this.appBarTitle, );

  @override
  State<StatefulWidget> createState() {
    return NoteDetailState(this.note, this.appBarTitle);
  }
}

class NoteDetailState extends State<noteDetail> {
  static var _priority = ["High", "Low"];
  var selectedValue = _priority[0];
  DatabaseHelper databaseHelper =  DatabaseHelper();
  TextEditingController titleController = TextEditingController();
  TextEditingController desciptionController = TextEditingController();
  String appBarTitle;
  Note note;

  NoteDetailState(this.note,this.appBarTitle);
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;
    titleController.text = note.title;
    desciptionController.text = note.description;
    return WillPopScope(
        onWillPop: () {
          moveToLastScreen();
        },
        child: Scaffold(
          appBar: AppBar(
              title: Text(appBarTitle),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  moveToLastScreen();
                },
              ),
            actions: [
              FlatButton(
                textColor: Colors.black,
                child: Text(
                  "Save",
                  textScaleFactor: 1.5,
                ),
                onPressed: () {
                  _save();
                },
              ),
              Container(
                width: 5,
              ),
              FlatButton(
                textColor: Colors.black,
                child: Text("Delete",
                textScaleFactor: 1.5,),
                onPressed: () {
                  setState(() {
                    _delete();
                  });
                },
              )
            ],
          ),
          body: Padding(
            padding: EdgeInsets.only(top: 1.0, left: 10.0, right: 10.0),
            child: ListView(
              children: <Widget>[
                ListTile(
                  title: DropdownButton(
                      items: _priority.map((String changedValue) {
                        return DropdownMenuItem<String>(
                          value: changedValue,
                          child: Text(changedValue),
                        );
                      }).toList(),
                      style: textStyle,
                      value: getPriorityAsString(note.priority),
                      onChanged: (String valueSelectedByUser) {
                        setState(() {
                          this.selectedValue = valueSelectedByUser;
                          updatePriorityAsInt(valueSelectedByUser);
                        });
                      },
                  )

                ),
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: TextField(
                    controller: titleController,
                    style: textStyle,
                    onChanged: (value) {
                      updateTitle();
                    },
                    decoration: InputDecoration(
                        labelText: "Title",
                        labelStyle: textStyle,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 15.0),
                  child: TextField(
                        controller: desciptionController,
                        minLines: 5,
                        maxLines: 20,
                        style: textStyle,
                        onChanged: (value) {
                          updateDescription();
                        },
                        decoration: InputDecoration(
                            labelText: "Type here...",
                            labelStyle: textStyle,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0))),
                      ),
                  ),
              ],
            ),
          ),
        ));
  }

  void moveToLastScreen() {
   // Navigator.pop(context);
    Navigator.pop(context,true);
  }
  void updatePriorityAsInt(String value){
    switch(value){
      case 'High':
        note.priority = 1;
        break;
      case 'Low':
        note.priority = 2;
        break;
    }
  }
  String getPriorityAsString(int value){
    String priority;
    switch(value){
      case 1:
        priority= _priority[0];
        break;
      case 2:
        priority= _priority[1];
        break;
    }
    return priority;
  }
  void updateTitle(){
    note.title=  titleController.text;
  }
  void updateDescription(){
    note.description= desciptionController.text;
  }
  void _save() async{
    moveToLastScreen();
    note.date= DateFormat.yMMMd().format(DateTime.now());
    int result;
    if(note.id!= null){
       result = await databaseHelper.updateNote(note);
    }
    else{
       result=await databaseHelper.insertNote(note);
    }
    if(result!= 0){
      _showAlertDialog('status','Saved');
    }else{
      _showSnackBar('Saved');
    }
  }
  void _showAlertDialog(String title, String message) {

    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(
        context: context,
        builder: (_) => alertDialog
    );
  }
  void _showSnackBar(String message){
    final snackBar = SnackBar(content: Text(message,));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }
  void _delete() async{
    moveToLastScreen();
    if(note.id == null){
    _showSnackBar( 'Nothing Noted');
      return;
    }
    final result=await databaseHelper.deleteNote(note.id);
    if(result!=0){
      _showSnackBar( 'Note Deleted ');
    }else{
      _showSnackBar('Error occured while Deleting Note');
    }
  }
}
