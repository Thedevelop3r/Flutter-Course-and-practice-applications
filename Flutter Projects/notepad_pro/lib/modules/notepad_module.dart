const String NOTEPAD_TABLE_NAME = 'notepad';

class NOTEPAD_FIELDS {
  static final List<String> values = [id, title, paragraph];

  static final String id = '_id';
  static final String title = 'title';
  static final String paragraph = 'paragraph';
}

class NOTE {
  int? id;
  final String Title;
  final String Paragraph;

  NOTE({this.id, required this.Title, required this.Paragraph});

  Map<String, Object?> toJson() => {
        NOTEPAD_FIELDS.id: id,
        NOTEPAD_FIELDS.title: Title,
        NOTEPAD_FIELDS.paragraph: Paragraph,
      };

  static NOTE fromJson(Map<String, Object?> json) => NOTE(
      id: json[NOTEPAD_FIELDS.id] as int?,
      Title: json[NOTEPAD_FIELDS.title] as String,
      Paragraph: json[NOTEPAD_FIELDS.paragraph] as String);

  NOTE copy({int? Note_id, String? Title, String? Paragraph}) => NOTE(
      id: Note_id ?? this.id,
      Title: Title ?? this.Title,
      Paragraph: Paragraph ?? this.Paragraph);

  @override
  String toString() {
    return 'NOTE{Id: $id, Title: $Title, Paragraph: $Paragraph}';
  }
}
