import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  String id;
  String autor;
  String autorImage;
  DateTime dateCreation;
  String descripcion;
  List<CommentModel> child;

  CommentModel.fromSnapshot(DocumentSnapshot map) {
    id = map.id;
    autor = map["autor"];
    dateCreation = map["fecha_creacion"].toDate();
    descripcion = map["descripcion"];
  }
}
