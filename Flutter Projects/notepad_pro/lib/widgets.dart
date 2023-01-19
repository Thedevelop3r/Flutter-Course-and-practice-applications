import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Note extends StatelessWidget {
  const Note({Key? key, required this.Title, required this.Paragraph})
      : super(key: key);
  final String Title;
  final String Paragraph;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 5.0),
      child: Container(
        decoration: BoxDecoration(
          //color: Colors.purpleAccent,
          border: Border.all(color: Colors.purpleAccent),
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 5.0, top: 4.0, bottom: 1.0),
              child: Text(
                '$Title',
                style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 30.0),
                maxLines: 1,
              ),
            ),
            Divider(
              thickness: 1.0,
              color: Colors.lightBlueAccent,
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 5.0, right: 5.0, top: 6.0, bottom: 6.0),
              child: Text(
                '$Paragraph',
                maxLines: null,
                softWrap: true,
                style: TextStyle(color: Colors.black54, fontSize: 20.0),
              ),
            )
          ],
        ),
      ),
    );
  }
}
