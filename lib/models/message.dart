class Message {
  int id;
  DateTime dateTime;
  String title;
  String text;
  String category;
  bool isRead;
  Message({
    required this.id,
    required this.dateTime,
    required this.title,
    required this.text,
    required this.category,
    this.isRead = false,
  });
}
