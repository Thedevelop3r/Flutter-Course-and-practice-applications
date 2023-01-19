import 'package:flutter/material.dart';
import 'package:notepad_pro/screens/create_note.dart';
import 'package:notepad_pro/modules/database_model.dart';
import 'package:notepad_pro/modules/notepad_module.dart';
import 'package:notepad_pro/screens/notesscreen.dart';
import 'package:notepad_pro/widgets.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NotePade Pro',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final db = NOTES_DATABASE.instance;
  List<NOTE> Notes = [];
  List<NOTE> temp = [];
  final ScrollController _ScrolController = ScrollController();

  void initState() {
    RefreshNotes();
  }

  void RefreshNotes() async {
    Notes = await db
        .read_All_Notes(); // this code query the database for all notes and maps it to a list and returns it.

    Notes = new List.from(
        Notes.reversed); // this code reverse the list to the last added item.

    // for (var notes in Notes) {
    //   print('$notes');
    // }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notepad Pro'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              height: 60.0,
              width: 180.0,
              child: TextButton(
                onPressed: () async {
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CreateNotePadeScreen()));
                  // todo: 1 when we will get back we update all notes again.
                  RefreshNotes();
                  _ScrolController.jumpTo(1.0);
                  setState(() {});
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Create Note',
                      style: TextStyle(color: Colors.black, fontSize: 20.0),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: Icon(
                        Icons.create,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Divider(
            thickness: 1.0,
            color: Colors.black26,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0, bottom: 10.0),
            child: Text(
              'long press to delete tap to view',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          Notes.isEmpty
              ? SizedBox.shrink()
              : Flexible(
                  flex: 1,
                  fit: FlexFit.loose,
                  child: ListView.builder(
                      controller: _ScrolController,
                      //shrinkWrap: true,
                      itemCount: Notes.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () async {
                            await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => NotesScrren(
                                        Note_recieved: Notes[index])));

                            RefreshNotes();
                          },
                          onLongPress: () async {
                            await db.delete_Note(Notes[index].id);

                            RefreshNotes();
                          },
                          child: Note(
                            Title: Notes[index].Title,
                            Paragraph: Notes[index].Paragraph,
                          ),
                        );
                      }),
                ),
        ],
      ),
    );
  }
}
