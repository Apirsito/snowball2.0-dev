import 'package:cloud_firestore/cloud_firestore.dart';

class UserMessage {
  String id;
  String from;
  String content;
  DateTime time;

  UserMessage();

  UserMessage.fromJson(DocumentSnapshot json) {
    id = json.id;
    from = json['idFrom'];
    content = json['content'];
    time = json['timestamp'];
  }
}
