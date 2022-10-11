import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

import 'adjunto.dart';

class Snowball {
  List<Adjuntos> adjuntos = <Adjuntos>[];
  String autor;
  String categoria;
  List<String> comentarios = <String>[];
  String ciudad;
  int conteoHits;
  String descripcion;
  String estado;
  List<String> etiquetas = <String>[];
  DateTime fecha;
  String foto;
  int fotos;
  List<String> hits = <String>[];
  String id;
  String nombre;
  String pais;
  int rolls;
  Adjuntos videos = Adjuntos();
  String video;
  GeoFirePoint position;

  Snowball();

  Snowball.fromJsonMap(Map<String, dynamic> map, String docID) {
    if (map['adjuntos'] != null || map['adjuntos'].isEmpty) {
      adjuntos = <Adjuntos>[];
      map['adjuntos'].forEach((i) {
        adjuntos.add(Adjuntos(id: i["id"], image: i["image"], video: i["video"]));
      });
    } else {
      adjuntos.add(
        Adjuntos(
          image: "https://firebasestorage.googleapis.com/v0/b/snowballapp-84bc6.appspot.com/o/images%2Fsnowball_logo.png?alt=media&token=71af8cc7-33bd-471c-ba1c-3fb53a4bba96"
        )
      );
    }
    videos = map["videos"] != null ? Adjuntos(image: map["videos"]["image"]) : null;
    autor = map["autor"];
    categoria = map["categoria"];
    comentarios = map['comentarios'].cast<String>();
    ciudad = map["ciudad"];
    conteoHits = map["conteo_hits"];
    descripcion = map["descripcion"];
    estado = map["estado"];
    etiquetas = map['etiquetas'].cast<String>();
    fecha = map["fecha"].toDate();
    foto = map["foto"];
    fotos = map["fotos"];
    hits = map['hits'].cast<String>();
    id = docID;
    nombre = map["nombre"] != null ? map["nombre"] : "";
    pais = map["pais"];
    rolls = map["rolls"];
    video = map["video"];
    if (map["position"] != null) {
      position = GeoFirePoint(
        map["position"]["geopoint"].latitude,
        map["position"]["geopoint"].longitude
      );
    }
  }

  Snowball.fromSnapshot(DocumentSnapshot map) : this.fromJsonMap(map.data(), map.id);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['autor'] = autor;
    data['categoria'] = categoria;
    data["comentarios"] = comentarios;
    data['ciudad'] = ciudad;
    data['descripcion'] = descripcion;
    data['estado'] = estado;
    data['etiquetas'] = etiquetas;
    data['fecha'] = fecha;
    data['foto'] = foto;
    data['fotos'] = fotos;
    data['hits'] = hits;
    data['id'] = id;
    data['nombre'] = nombre;
    data['pais'] = pais;
    data['rolls'] = rolls;
    data['video'] = video;
    data['adjuntos'] =
        adjuntos != null ? this.adjuntos.map((v) => v.toJson()).toList() : null;
    data['position'] = position != null ? this.position.data : null;
    return data;
  }
}
