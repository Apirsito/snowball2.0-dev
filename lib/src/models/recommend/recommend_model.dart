import 'package:snowball/src/models/snowball/snowball.dart';

class RecommendModel {
  String id;
  DateTime dateCreation;
  String imagenProfile;
  String imagen;
  bool aprovado;
  String descripcion;
  String autor;
  String autorName;
  String snowballId;
  Snowball snowball;

  RecommendModel(
      {this.id,
      this.dateCreation,
      this.imagenProfile,
      this.imagen,
      this.autorName,
      this.descripcion,
      this.autor,
      this.snowballId});

  RecommendModel.fromJsonMap(Map<String, dynamic> map, String docID) {
    id = docID;
    autor = map["autor"];
    aprovado = map['aprovado'];
    dateCreation = map["fecha_creacion"].toDate();
    imagenProfile = map['image_profile'].cast<String>();
    imagen = map["image"];
    descripcion = map["descripcion"];
    snowballId = map["snowball_id"];
  }
}
