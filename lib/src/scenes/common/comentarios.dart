import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:snowball/src/common/app_constants.dart';
import 'package:snowball/src/controller/detail/detail_snowball_controller.dart';
import 'package:snowball/src/models/user/user_model.dart';
import 'package:snowball/src/scenes/comment/comment_view.dart';
import 'package:snowball/src/scenes/user/user_view.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

//ignore: must_be_immutable
class ComentariosView extends StatelessWidget {
  String id;
  String autor;
  ComentariosView(this.id, this.autor);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
        child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("comentarios")
                .where("snowball_id", isEqualTo: id)
                .orderBy("fecha_creacion", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return SizedBox();
              return ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  padding: EdgeInsets.all(1),
                  scrollDirection: Axis.vertical,
                  primary: false,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    ValueNotifier<bool> longDescrip = ValueNotifier<bool>(false);
                    final commnet = snapshot.data.docs[index];
                    if (commnet["descripcion"] != null &&
                      (commnet["descripcion"]).toString().isNotEmpty &&
                      (commnet["descripcion"]).toString().length >= 80)
                        longDescrip.value = true;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Stack(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 17.0),
                              child: InkWell(
                                onTap: () => Get.to(UserView(id: commnet["autor"])),
                                child: FutureBuilder<DocumentSnapshot>(
                                    future: FirebaseFirestore.instance
                                        .collection("usuarios")
                                        .doc(commnet["autor"])
                                        .get(),
                                    builder: (context, snow) {
                                      if (!snow.hasData) return SizedBox();
                                      UserModel user = UserModel.fromJsonMap(snow.data);
                                      return ListTile(
                                        dense: true,
                                        leading: ClipOval(
                                          child: FadeInImage.assetNetwork(
                                            placeholder: "assets/snowball_logo.png",
                                            image: user.image,
                                            height: 50,
                                            width: 50,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        title: Row(
                                          children: [
                                            Text(user.name,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black)),
                                            SizedBox(width: 10),
                                            Text(
                                              timeago.format(
                                                  commnet["fecha_creacion"]
                                                      .toDate(),
                                                  locale: 'locale'.tr),
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                        subtitle: ValueListenableBuilder<bool>(
                                          valueListenable: longDescrip,
                                          builder: (context, snapLngDesc, _) {
                                            TextSpan link = TextSpan(
                                              text: snapLngDesc ? " ...${'viewMore'.tr}" : " ${'viewLess'.tr}",
                                              style: TextStyle(color: Colors.blue, fontSize: 14),
                                              recognizer: TapGestureRecognizer()..onTap = () {
                                                longDescrip.value = !longDescrip.value;
                                              }
                                            );
                                            return LayoutBuilder(
                                              builder: (context, constraints) {
                                                assert(constraints.hasBoundedWidth);
                                                final double maxWidth = constraints.maxWidth;
                                                final text = TextSpan(
                                                  text: '${commnet["descripcion"]}',
                                                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                                );
                                                TextPainter textPainter = TextPainter(
                                                  text: text,
                                                  textDirection: TextDirection.rtl,
                                                  maxLines: 2,
                                                  ellipsis: '...',
                                                );
                                                textPainter.layout(
                                                  minWidth: constraints.minWidth,
                                                  maxWidth: maxWidth
                                                );
                                                final linkSize = textPainter.size;
                                                textPainter.text = text;
                                                textPainter.layout(minWidth: constraints.minWidth, maxWidth: maxWidth);
                                                final textSize = textPainter.size;
                                                // Get the endIndex of data
                                                int endIndex;
                                                final pos = textPainter.getPositionForOffset(Offset(
                                                    textSize.width - linkSize.width,
                                                    textSize.height,
                                                ));
                                                endIndex = textPainter.getOffsetBefore(pos.offset);
                                                TextSpan textSpan;
                                                if (textPainter.didExceedMaxLines) {
                                                  textSpan = TextSpan(
                                                    text: snapLngDesc
                                                        ? '${commnet["descripcion"]}'.substring(0, endIndex)
                                                        : '${commnet["descripcion"]}',
                                                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                                    children: <TextSpan>[link],
                                                  );
                                                } else {
                                                  textSpan = TextSpan(
                                                    text: '${commnet["descripcion"]}',
                                                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                                  );
                                                }
                                                return RichText(
                                                  text: textSpan,
                                                );
                                              },
                                            );
                                          }
                                        ),
                                      );
                                    }),
                              ),
                            ),
                            Positioned(
                                bottom: 2,
                                left: 95,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    InkWell(
                                        onTap: () {
                                          DetailSnowballController
                                              .to.commentId.value = commnet.id;
                                          print(commnet.id);
                                          DetailSnowballController.to
                                              .requestForcus();
                                        },
                                        child: Text(
                                          "respond".tr,
                                          style: TextStyle(
                                              color: AppConstants.blue,
                                              fontSize: 12),
                                        )),
                                    SizedBox(width: 35),
                                  ],
                                ))
                          ],
                        ),
                        FutureBuilder<QuerySnapshot>(
                          future: FirebaseFirestore.instance
                              .collection("comentarios")
                              .doc(commnet.id)
                              .collection("comentarios")
                              .orderBy("fecha_creacion", descending: true)
                              .limit(1)
                              .get()
                              .asStream()
                              .first,
                          builder: (context, comen) {
                            if (!comen.hasData) return SizedBox();
                            if (comen.data.docs.isEmpty) return SizedBox();
                            final comentario = comen.data.docs.first;
                            return Column(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(left: 40.0),
                                  child: FutureBuilder<DocumentSnapshot>(
                                      future: FirebaseFirestore.instance
                                          .collection("usuarios")
                                          .doc(comentario["autor"])
                                          .get(),
                                      builder: (context, snow) {
                                        if (!snow.hasData) return SizedBox();
                                        UserModel user =
                                            UserModel.fromJsonMap(snow.data);
                                        return ListTile(
                                          dense: true,
                                          leading: InkWell(
                                            onTap: () => Get.to(
                                              UserView(id: comentario["autor"]),
                                            ),
                                            child: ClipOval(
                                              child: FadeInImage.assetNetwork(
                                                placeholder:
                                                    "assets/snowball_logo.png",
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
                                                  comentario["fecha_creacion"]
                                                      .toDate(),
                                                  locale: 'locale'.tr,
                                                ),
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                          subtitle: Container(
                                            child: SelectableLinkify(
                                              options: LinkifyOptions(
                                                humanize: false,
                                                defaultToHttps: true,
                                                removeWww: true,
                                              ),
                                              onOpen: (link) async {
                                                final url = removeDiacritics(
                                                    link.url);
                                                final goToUrl =
                                                    await canLaunch(url);
                                                if (!goToUrl)
                                                  return throw 'Could not launch $link';
                                                await launch(url);
                                              },
                                              text:
                                                  '${comentario["descripcion"]}',
                                              minLines: 1,
                                              maxLines: 3,
                                            ),
                                          ),
                                        );
                                      }),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: InkWell(
                                      onTap: () => Get.to(
                                        MoreComments(
                                          commnet.id,
                                          id,
                                          commnet,
                                        ),
                                      ),
                                      child: Text(
                                        'see_all_comment'.tr,
                                        style: TextStyle(
                                          color: Colors.grey, 
                                          fontSize: 13,
                                        ),
                                      )),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    );
                  });
            }),
      ),
    );
  }
}
