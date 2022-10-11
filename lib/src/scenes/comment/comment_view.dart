import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:snowball/src/common/app_constants.dart';
import 'package:snowball/src/controller/notification/notification_controller.dart';
import 'package:snowball/src/models/snowball/snowball.dart';
import 'package:snowball/src/models/user/user_model.dart';
import 'package:snowball/src/scenes/user/user_view.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

class MoreComments extends StatefulWidget {
  final String comenId;
  final String idSnowBall;
  final comentario;
  MoreComments(this.comenId, this.idSnowBall, this.comentario);

  @override
  _MoreCommentsState createState() => _MoreCommentsState();
}

class _MoreCommentsState extends State<MoreComments> {
  final TextEditingController commentController = new TextEditingController();
  final _db = FirebaseFirestore.instance.collection("comentarios");
  final _dbSnow = FirebaseFirestore.instance.collection("snowball");
  final FocusNode focusNode = new FocusNode();

  final box = GetStorage();

  String randomString(int strlen) {
    var chars = "abcdefghijklmnopqrstuvwxyz0123456789";
    Random rnd = new Random(new DateTime.now().millisecondsSinceEpoch);
    String result = "";
    for (var i = 0; i < strlen; i++) {
      result += chars[rnd.nextInt(chars.length)];
    }
    return result;
  }

  void _sendOtherComment(String idcoment, String message) {
    if (idcoment.isNotEmpty && message.trim().isNotEmpty) {
      final rdocs = randomString(20);
      final referemce =
          _db.doc(widget.comenId).collection("comentarios").doc(rdocs);
      final uuid = box.read('uuid');
      List<String> localComment = [];

      FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.set(referemce, {
          "autor": uuid,
          "descripcion": message,
          "fecha_creacion": DateTime.now(),
          "snowball_id": widget.idSnowBall
        });
      }).then((value) {
        localComment.add(referemce.id);
        focusNode.unfocus();

        _dbSnow.doc(widget.idSnowBall).get().then((snow) {
          Snowball snowball = Snowball.fromSnapshot(snow);
          NotificationController.to.sendPush(
            snowball.autor, 
            uuid, 
            widget.idSnowBall,
          );
        });
      });
      if (commentController.text.trim().isNotEmpty) commentController.clear();
    }
  }

  void _openPerfil(String idUser) {
    Get.to(UserView(id: idUser));
  }

  Widget _buildInput() {
    return Container(
      decoration: BoxDecoration(color: Colors.white),
      child: Row(
        children: <Widget>[
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 1.0),
              child: new IconButton(
                onPressed: () {},
                icon: new Icon(Icons.face),
                color: Colors.grey,
              ),
            ),
            color: Colors.white,
          ),
          Flexible(
            child: Container(
              child: TextField(
                maxLines: null,
                keyboardType: TextInputType.multiline,
                style: TextStyle(color: Colors.black54, fontSize: 15.0),
                controller: commentController,
                decoration: InputDecoration.collapsed(
                  hintText: 'your_comments'.tr,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                onSubmitted: (value) {
                  _sendOtherComment(widget.idSnowBall, value);
                },
                focusNode: focusNode,
              ),
            ),
          ),
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 8.0),
              child: new IconButton(
                icon: new Icon(Icons.send),
                onPressed: () {
                  _sendOtherComment(widget.idSnowBall, commentController.text);
                },
                color: Colors.blueAccent,
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget listMessages() {
    return Flexible(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("comentarios")
            .doc(widget.comenId)
            .collection("comentarios")
            .orderBy("fecha_creacion", descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
              ),
            );
          }
          final otherComment = snapshot.data.docs;
          return ListView.builder(
            padding: EdgeInsets.only(left: 30.0),
            itemCount: snapshot.data.docs.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(top: 5),
                child: FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection("usuarios")
                      .doc(otherComment[index]["autor"])
                      .get(),
                  builder: (context, snow) {
                    if (!snow.hasData) return SizedBox();
                    UserModel user = UserModel.fromJsonMap(snow.data);
                    return ListTile(
                      leading: InkWell(
                        onTap: () => _openPerfil(otherComment[index]["autor"]),
                        child: ClipOval(
                          child: FadeInImage.assetNetwork(
                            placeholder: "assets/snowball_logo.png",
                            image: user.image,
                            height: 50,
                            width: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      title: Row(
                        children: [
                          Text(
                            user.name,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            timeago.format(
                              otherComment[index]["fecha_creacion"].toDate(),
                              locale: 'locale'.tr,
                            ),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      subtitle: SelectableLinkify(
                        options: LinkifyOptions(
                          humanize: false,
                          defaultToHttps: true,
                          removeWww: true,
                        ),
                        onOpen: (link) async {
                          final url = removeDiacritics(link.url);
                          final goToUrl = await canLaunch(url);
                          if (!goToUrl) return throw 'Could not launch $link';
                          await launch(url);
                        },
                        text: otherComment[index]["descripcion"],
                        minLines: 1,
                        maxLines: 3,
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              ],
            ),
          ),
        ),
        title: Text(
          'comment'.tr,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: WillPopScope(
        onWillPop: () async => true,
        child: GestureDetector(
          onTap: () {
            focusNode.unfocus();
            FocusScope.of(context).unfocus();
          },
          child: Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Stack(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(bottom: 10.0),
                      child: FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection("usuarios")
                            .doc(widget.comentario["autor"])
                            .get(),
                        builder: (context, snow) {
                          if (!snow.hasData) return SizedBox();
                          UserModel user = UserModel.fromJsonMap(snow.data);
                          return ListTile(
                            leading: InkWell(
                              onTap: () =>
                                  _openPerfil(widget.comentario["autor"]),
                              child: ClipOval(
                                child: FadeInImage.assetNetwork(
                                  placeholder: "assets/snowball_logo.png",
                                  image: user.image,
                                  height: 50,
                                  width: 50,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            title: Row(
                              children: [
                                Text(
                                  user.name,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  timeago.format(
                                    widget.comentario["fecha_creacion"].toDate(),
                                    locale: 'locale'.tr,
                                  ),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            subtitle: SelectableLinkify(
                              options: LinkifyOptions(
                                humanize: false,
                                defaultToHttps: true,
                                removeWww: true,
                              ),
                              onOpen: (link) async {
                                final url = removeDiacritics(link.url);
                                final goToUrl = await canLaunch(url);
                                if (!goToUrl)
                                  return throw 'Could not launch $link';
                                await launch(url);
                              },
                              text: widget.comentario["descripcion"],
                              minLines: 1,
                              maxLines: 3,
                            ),
                          );
                        },
                      ),
                    ),
                    listMessages(),
                    _buildInput(),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
