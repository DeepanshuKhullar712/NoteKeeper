import 'package:flutter/material.dart';
import 'package:flutter_notekeeper/screens/noteDetail.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_notekeeper/utils/database_helper.dart';
import 'package:flutter_notekeeper/models/node.dart';
class NoteList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NoteListState();
  }
}

class NoteListState extends State<NoteList> {
  int count = 0;
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note> noteList;


  @override
  Widget build(BuildContext ctx) {
    if(noteList == null){
      noteList = List<Note>();
      updadeListView();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Notes"),
      ),

      body: getNoteListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigateToDetail(Note('','',2),"Add note");
        },
        tooltip: "Add note",
        child: Icon(Icons.add),
      ),
    );
  }

  ListView getNoteListView() {
    TextStyle titleStyle = Theme
        .of(context)
        .textTheme
        .subhead;
    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int position) {
        return Card(
          color: Colors.white,
          elevation: 2.0,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: getPriorityColor(this.noteList[position].priority),
              child: getPriorityIcon(this.noteList[position].priority),
            ),
            title:Text(this.noteList[position].title,style: titleStyle,),
            subtitle: Text(this.noteList[position].date),
            trailing: GestureDetector(
                child: Icon(Icons.delete, color: Colors.grey,),
              onTap: (){
                  _delete(context, noteList[position]);
              },
            ),
            onTap: () {
              navigateToDetail(this.noteList[position],"Edit note");
            },
          ),
        );
      },

    );
  }

  Color getPriorityColor(int priority){
    switch(priority){
      case 1: return Colors.red; break;
      case 2: return Colors.yellow; break;
      default: return Colors.yellow;
    }
  }
  Icon getPriorityIcon(int priority){
    switch(priority){
      case 1: return Icon(Icons.play_arrow);
      case 2:return Icon(Icons.keyboard_arrow_right);
      default: return Icon(Icons.keyboard_arrow_right);
    }
  }

  void navigateToDetail(Note note,String title) async{
    bool result=await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return noteDetail(note,title);
    }));
    if(result ==true){
      updadeListView();
    }
  }
  void _showSnackBar(BuildContext context,String message){
    final snackbar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackbar);
  }

  void _delete(BuildContext context, Note note) async{
    int result = await databaseHelper.deleteNote(note.id);
    if(result != 0){
      _showSnackBar(context,'Note Deleted Successfully');
      updadeListView();
    }
  }

  void updadeListView(){
    final Future<Database> dbFuture = databaseHelper.initializedDataBase();
    dbFuture.then((database){
      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((noteList) {
        setState(() {
          this.noteList = noteList;
          this.count = noteList.length;
        });
      });
    });
  }

}