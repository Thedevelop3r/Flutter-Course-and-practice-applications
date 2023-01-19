import 'package:notepad_pro/modules/notepad_module.dart';
import 'package:flutter/material.dart';
import 'package:notepad_pro/modules/database_model.dart';
import 'package:notepad_pro/widgets.dart';

class CreateNotePadeScreen extends StatelessWidget {
  const CreateNotePadeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CreateNoteScreen();
  }
}

class CreateNoteScreen extends StatefulWidget {
  const CreateNoteScreen({Key? key}) : super(key: key);
  @override
  State<CreateNoteScreen> createState() => _CreateNoteScreenState();
}

class _CreateNoteScreenState extends State<CreateNoteScreen> {
  final TextEditingController _TitleController = TextEditingController();
  final TextEditingController _ParaController = TextEditingController();
  String Title = '';
  String Paragraph = '';
  final db = NOTES_DATABASE.instance;

  // void InitializeDB() async {
  //    db = await NOTES_DATABASE.instance;
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Note'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 15.0),
          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  Title = value;
                });
              },
              autofocus: true,
              //textInputAction: TextInputAction.continueAction,
              controller: _TitleController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                label: Text('Title'),
                hintText: 'Title of note',
              ),
            ),
          ),
          SizedBox(height: 10.0),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: TextField(
                onChanged: (value) {
                  if (value.length < 3000) {
                    Paragraph = value;
                  }
                  setState(() {});
                },
                maxLength: 3000,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                controller: _ParaController,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text('Note'),
                  hintText: 'Type your notes here limit:3000 alphabats',
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () async {
                final note = NOTE(Title: Title, Paragraph: Paragraph);
                NOTE NoteCreated = await db.create_Note(note);

                Navigator.pop(context);
              },
              child: Text(
                'Create',
                style: TextStyle(
                  color: Colors.green,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

// this was a Note widget to show after notes
// Title.length > 0
// ? Expanded(child: Note(Title: Title, Paragraph: Paragraph))
// : SizedBox.shrink()
