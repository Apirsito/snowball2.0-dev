import 'dart:io';

import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:get/get.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:snowball/src/common/app_constants.dart';
import 'package:snowball/src/models/recommend/recommend_model.dart';
import 'package:snowball/src/models/snowball/adjunto.dart';
import 'package:snowball/src/scenes/user/user_view.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:snowball/src/controller/recomend/recommended_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'image_zoom.dart';

// ignore: must_be_immutable
class RecommendedView extends StatefulWidget {
  String id;
  RecommendedView({this.id});

  @override
  _RecommendedViewState createState() => _RecommendedViewState();
}

class _RecommendedViewState extends State<RecommendedView> {

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * .8,
      ),
      height: // MediaQuery.of(context).viewInsets.bottom <= 0 ? Get.height - 100: 300
          MediaQuery.of(context).size.height *
              (RecommendedController.to.focusNode.hasFocus && !Platform.isIOS
                  ? .5
                  : 1),
      decoration: BoxDecoration(
        color: Theme.of(context).canvasColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              ListTile(
                title: Text(
                  'recommendation'.tr,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              ListTile(
                leading: Icon(Icons.security),
                title: Text('aprove_recomment'.tr),
              ),
            ],
          ),
          Flexible(
            child: GetBuilder<RecommendedController>(
              initState: (_) =>
                  RecommendedController.to.getRecommendbySnow(widget.id),
              dispose: (_) => RecommendedController.to.clearData(),
              builder: (c) => Obx(() {
                if (c.allRecommends.isNotEmpty) {
                  List<RecommendModel> uniqueList = <RecommendModel>[];
                  for (final item in c.allRecommends) {
                    if (uniqueList.isEmpty)
                      uniqueList.add(item);
                    else {
                      final exist =
                          uniqueList.where((e) => e.id == item.id).toList();
                      if (exist.isEmpty) uniqueList.add(item);
                    }
                  }
                  uniqueList
                      .sort((a, b) => b.dateCreation.compareTo(a.dateCreation));
                  c.allRecommends.assignAll(uniqueList);
                }
                return Padding(
                  padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                  child: ListView.builder(
                    itemCount: c.allRecommends.length,
                    shrinkWrap: true,
                    physics: const ScrollPhysics(),
                    itemBuilder: (context, index) {
                      final r = c.allRecommends[index];
                      return ListTile(
                        leading: InkWell(
                          onTap: () => Get.to(UserView(id: r.autor)),
                          child: ClipOval(
                            child: FadeInImage.assetNetwork(
                              placeholder: "assets/snowball_logo.png",
                              image: (r.imagenProfile != null &&
                                      r.imagenProfile.isNotEmpty)
                                  ? r.imagenProfile
                                  : r.snowball.adjuntos.isNotEmpty
                                      ? r.snowball.adjuntos.first.image
                                      : AppConstants.logoSnowball,
                              height: 50,
                              width: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        title: Row(
                          children: [
                            Text(
                              r.autorName ?? "",
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(width: 15),
                            Text(
                              timeago.format(
                                r.dateCreation,
                                locale: 'locale'.tr,
                              ),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Visibility(
                              visible:
                                  (r.imagen != null && r.imagen.isNotEmpty),
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: InkWell(
                                  onTap: () {
                                    /// REVISAR COMO HACERLO CON Get.to DE GETX
                                    /// O SI SE PUEDE HACERLO CON ESE
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (ctx) => ImageZoomView(
                                          <Adjuntos>[
                                            Adjuntos(
                                              id: r.id,
                                              index: 0,
                                              image: r.imagen,
                                              video: '',
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  child: FadeInImage.assetNetwork(
                                    placeholder: "assets/snowball_logo.png",
                                    image: r.imagen,
                                    height: 160,
                                    width: 160,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            SelectableLinkify(
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
                              text: r.descripcion,
                              minLines: 1,
                              maxLines: 3,
                              textAlign: TextAlign.start,
                              textDirection: TextDirection.ltr,
                              style: TextStyle(),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ),
          Container(
            child: Padding(
              padding: EdgeInsets.only( bottom: MediaQuery.of(context).viewInsets.bottom ),
              child: toolsToRecommend(),
            ),
          ),
        ],
      ),
    );
  }

  Widget toolsToRecommend() => Column(
        children: [
          // WIDGET IMAGE UPLOADED
          Container(
            transform: Matrix4.translationValues(
              -120,
              !Platform.isIOS ? 0 : -.1,
              0,
            ),
            child: Stack(
              children: [
                Obx(
                  () => Visibility(
                    visible:
                        (RecommendedController.to.imageUploaded.value != null &&
                            RecommendedController.to.imageUploaded.value
                                .trim()
                                .isNotEmpty),
                    child: Container(
                      width: 100,
                      height: 100,
                      child: AssetThumb(
                        width: 100,
                        height: 100,
                        asset: RecommendedController.to.imageForUpload,
                      ),
                    ),
                  ),
                ),
                Obx(
                  () => Visibility(
                    visible:
                        (RecommendedController.to.imageUploaded.value != null &&
                            RecommendedController.to.imageUploaded.value
                                .trim()
                                .isNotEmpty),
                    child: Container(
                      transform: Matrix4.translationValues(50, -20, 0),
                      child: MaterialButton(
                        onPressed: () {
                          RecommendedController.to.imageUploaded.value = "";
                          setState(() {});
                        },
                        color: Colors.white,
                        textColor: Colors.black,
                        child: Icon(
                          Icons.close,
                          size: 20,
                        ),
                        padding: EdgeInsets.all(0),
                        shape: CircleBorder(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // TOOLBAR RECOMMENDS
          Container(
            color: Colors.white,
            child: Row(
              children: <Widget>[
                Material(
                  child: new Container(
                    width: 30,
                    margin: new EdgeInsets.symmetric(horizontal: 0),
                    child: new IconButton(
                      onPressed: () {},
                      icon: new Icon(Icons.face),
                      color: Colors.grey,
                    ),
                  ),
                  color: Colors.white,
                ),
                Material(
                  child: InkWell(
                    onTap: () => RecommendedController.to.loadAssets(),
                    child: new Container(
                      margin: EdgeInsets.symmetric(horizontal: 2),
                      child: IconButton(
                        onPressed: () async {
                          await RecommendedController.to.loadAssets();
                          setState(() {});
                        },
                        icon: new Icon(Icons.image),
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  color: Colors.white,
                ),
                Flexible(
                  child: Container(
                    color: Colors.white,
                    height: 50,
                    child: TextField(
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      style: TextStyle(color: Colors.black54, fontSize: 15.0),
                      controller: RecommendedController.to.recommend,
                      decoration: InputDecoration(
                          hintText: 'your_recommend'.tr,
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none),
                      onSubmitted: (value) {
                        if (RecommendedController.to.focusNode.hasFocus) {
                          RecommendedController.to.focusNode.unfocus();
                          FocusScope.of(context).unfocus();
                        }
                        RecommendedController.to.saveRecomendation();
                        setState(() {});
                      },
                      focusNode: RecommendedController.to.focusNode,
                    ),
                  ),
                ),
                Material(
                  child: new Container(
                    margin: new EdgeInsets.symmetric(horizontal: 8.0),
                    child: new IconButton(
                      icon: new Icon(Icons.send),
                      onPressed: () {
                        if (RecommendedController.to.focusNode.hasFocus) {
                          RecommendedController.to.focusNode.unfocus();
                          FocusScope.of(context).unfocus();
                        }
                        RecommendedController.to.saveRecomendation();
                        setState(() {});
                      },
                      color: AppConstants.blue,
                    ),
                  ),
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ],
      );
}
