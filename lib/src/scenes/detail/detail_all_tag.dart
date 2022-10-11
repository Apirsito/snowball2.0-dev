import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snowball/src/common/app_constants.dart';
import 'package:snowball/src/models/snowball/snowball.dart';
import 'package:snowball/src/scenes/common/toolbar_view.dart';
import 'package:snowball/src/scenes/detail/detail_snowball_view.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'dart:ui' as ui;

class DetailAllTags extends StatefulWidget {
  final String tags;
  DetailAllTags(this.tags);

  @override
  _DetailAllTagsState createState() => _DetailAllTagsState();
}

class _DetailAllTagsState extends State<DetailAllTags> {
  Widget videoPreview(String video) {
    if (video != null) {
      video =
          "https://isaca-gwdc.org/wp-content/uploads/2016/12/Video-placeholder.png";
    }
    return Image.network(
      video,
      width: 100,
      fit: BoxFit.cover,
    );
  }

  Widget imagePreview(String image) {
    if (image == null) {
      image =
          "https://firebasestorage.googleapis.com/v0/b/snowballapp-84bc6.appspot.com/o/images%2Fsnowball_logo.png?alt=media&token=71af8cc7-33bd-471c-ba1c-3fb53a4bba96";
      return Padding(
        padding: const EdgeInsets.all(10),
        child: Image.network(
          image,
          height: 170,
          fit: BoxFit.contain,
        ),
      );
    } else {
      return Image.network(
        image,
        height: 200,
        fit: BoxFit.cover,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    void sendataToDetail(String document) {
      Snowball item = new Snowball();
      item.id = document;
    }

    String getTagsList(List<String> list) {
      var str = "";
      var mas = "";
      var count = 0;
      for (int i = 0; i < list.length; i++) {
        if (i <= 3) {
          str = str + list[i] + ", ";
        } else {
          count++;
          mas = "+$count";
        }
      }
      return str + mas;
    }

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                AppConstants.darBlue,
                Color.fromRGBO(82, 173, 187, 1)
              ])),
        ),
        title: Text(
          "Snowball by tag",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("snowball")
                .where("etiquetas", arrayContains: widget.tags)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return SizedBox();
              } else {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: GridView.builder(
                      primary: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 1),
                      padding: EdgeInsets.only(top: 0, bottom: 0, right: 16, left: 16),
                      itemCount: snapshot.data.docs.length,
                      scrollDirection: Axis.vertical,
                      itemBuilder: (context, index) {
                        Snowball snowball = Snowball.fromJsonMap(
                            snapshot.data.docs[index].data(),
                            snapshot.data.docs[index].id);

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 0),
                          child: Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Column(
                              children: <Widget>[
                                Expanded(
                                  flex: 3,
                                  child: InkWell(
                                    onTap: () =>
                                        Get.to(DetailSnowballView(snowball.id)),
                                    child: ClipRRect(
                                      borderRadius:
                                          new BorderRadius.circular(5.0),
                                      child: snowball.adjuntos.isNotEmpty
                                          ? snowball.adjuntos.first.video != null
                                              ? videoPreview(
                                                  snowball.adjuntos.first.video)
                                              : imagePreview(
                                                  snowball.adjuntos.first.image)
                                          : imagePreview(null),
                                    ),
                                  ),
                                ),
                                Stack(
                                  children: <Widget>[
                                    Positioned(
                                      right: 20,
                                      bottom: 0,
                                      child: Row(
                                        children: [
                                          Text(getTagsList(snowball.etiquetas),
                                              style: TextStyle(
                                                fontSize: 11,
                                                backgroundColor:Colors.grey.shade100
                                              )
                                          )
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 0, right: 8, bottom: 10),
                                      child: Container(
                                        child: InkWell(
                                          onTap: () {
                                            sendataToDetail( snapshot.data.docs[index].id);
                                          },
                                          child: ListTile(
                                            title: Text(snowball.nombre),
                                            subtitle: Text(snowball.ciudad),
                                            trailing: Text(
                                              timeago.format(
                                                snowball.fecha,
                                                locale: ui.window.locale.languageCode
                                              ),
                                              style: TextStyle(fontSize: 11),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Expanded(
                                  flex: 1,
                                  child: ToolsSnowBalls(id: snowball.id)
                                )
                              ],
                            ),
                          ),
                        );
                      }),
                );
              }
            }),
      ),
    );
  }
}
