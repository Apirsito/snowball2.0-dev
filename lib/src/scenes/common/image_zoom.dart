import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:snowball/src/models/snowball/adjunto.dart';

// ignore: must_be_immutable
class ImageZoomView extends StatelessWidget {
  List<Adjuntos> lista;
  ImageZoomView(this.lista);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(""),
        backgroundColor: Colors.black,
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.black),
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height,
        ),
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            PhotoViewGallery.builder(
              scrollPhysics: const BouncingScrollPhysics(),
              builder: (context, index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: lista[index].image != null
                      ? NetworkImage(lista[index].image)
                      : AssetImage('assets/snowball_logo.png'),
                  initialScale: PhotoViewComputedScale.contained,
                  heroAttributes: PhotoViewHeroAttributes(tag: lista[index].id),
                );
              },
              itemCount: lista.length,
              backgroundDecoration: BoxDecoration(color: Colors.black),
              scrollDirection: Axis.horizontal,
            ),
          ],
        ),
      ),
    );
  }
}
