import 'dart:io';
import 'package:multi_image_picker/multi_image_picker.dart';

class Adjuntos {
  String id;
  int index;
  String image;
  String video;
  Asset asset;
  File files;
  bool isDelete = false;

  Adjuntos(
      {this.id,
      this.index,
      this.image,
      this.video,
      this.asset,
      this.files,
      this.isDelete});

  Adjuntos.fromJson(Map<String, dynamic> json) {
    image = json['image'];
    video = json['video'];
    index = json['index'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['index'] = index;
    data['image'] = image;
    data['video'] = video;
    return data;
  }
}
