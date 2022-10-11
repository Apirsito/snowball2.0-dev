import 'package:cloud_firestore/cloud_firestore.dart';

class Notification {
  String id;
  String title;
  DateTime fecha;
  bool read;
  int type;
  String snowballId;
  String autor;
  String autorId;
  String chatId;

  Notification({this.id, this.title, this.fecha, this.read, this.type});

  Notification.fromJson(DocumentSnapshot json) {
    id = json.id;
    title = json['title'];
    fecha = json["fecha"].toDate();
    read = json['read'];
    type = json['type'];
    chatId = json.data()['chatid'] != null ? json['chatid'] : "";
    snowballId = json.data()['snowball_id'] != null ? json["snowball_id"] : "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['fecha'] = this.fecha;
    data['read'] = this.read;
    data['type'] = this.type;
    data['snowballId'] = this.snowballId;
    return data;
  }
}
