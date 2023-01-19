import 'package:flutter/material.dart';
import 'package:notepad_pro/modules/notepad_module.dart';
import 'package:notepad_pro/modules/database_model.dart';

class NotesScrren extends StatelessWidget {
  const NotesScrren({Key? key, required this.Note_recieved}) : super(key: key);

  final NOTE Note_recieved;
  @override
  Widget build(BuildContext context) {
    return NotesDisplay(
      Note_recieved: Note_recieved,
    );
  }
}

class NotesDisplay extends StatefulWidget {
  const NotesDisplay({Key? key, required this.Note_recieved}) : super(key: key);

  final NOTE Note_recieved;

  @override
  State<NotesDisplay> createState() => _NotesDisplayState();
}

class _NotesDisplayState extends State<NotesDisplay> {
  late final NOTE note;

  final TextEditingController _controller = TextEditingController();
  final TextEditingController _controllerTitle = TextEditingController();
  String newParagraph = '';
  String newTitle = '';
  final db = NOTES_DATABASE.instance;

  @override
  void initState() {
    note = widget.Note_recieved;
    _controller.text = note.Paragraph;
    _controllerTitle.text = note.Title;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controllerTitle,
          maxLines: 1,
          decoration: InputDecoration(
            border: InputBorder.none,
          ),
          onChanged: (value) {
            newTitle = value;
          },
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
      ),
      body: Column(
        children: [
          TextButton(
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateColor.resolveWith((states) => Colors.green),
              ),
              onPressed: () async {
                if (note.Title != _controllerTitle.text &&
                    note.Paragraph != _controller.text) {
                  NOTE newNote =
                      note.copy(Title: newTitle, Paragraph: newParagraph);
                  await db.update_Note(newNote);
                } else if (note.Title != _controllerTitle.text) {
                  NOTE newNote = note.copy(Title: newTitle);
                  await db.update_Note(newNote);
                } else if (note.Paragraph != _controller.text) {
                  NOTE newNote = note.copy(Paragraph: newParagraph);
                  await db.update_Note(newNote);
                } else {
                  return;
                }

                Navigator.pop(context);
              },
              child: Text(
                'Update',
                style: TextStyle(color: Colors.white),
              )),
          SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.only(
                    top: 15.0, left: 8.0, right: 8.0, bottom: 5.0),
                child: TextField(
                  controller: _controller,
                  maxLines: null,
                  onChanged: (value) {
                    newParagraph = value;
                  },
                )),
          ),
        ],
      ),
    );
  }
}

// Text(
// '${note.Paragraph}',
// maxLines: null,
// softWrap: true,
// style: TextStyle(color: Colors.black54, fontSize: 20.0),
// ),
