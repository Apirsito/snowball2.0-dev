import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snowball/src/common/app_constants.dart';
import 'package:snowball/src/controller/home/home_controller.dart';
import 'package:snowball/src/models/snowball/snowball.dart';
import 'package:snowball/src/scenes/add/add_view.dart';
import 'package:snowball/src/scenes/common/custom_video.dart';
import 'package:snowball/src/scenes/common/modals.dart';
import 'package:snowball/src/scenes/common/toolbar_view.dart';
import 'package:snowball/src/scenes/detail/detail_snowball_view.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with SingleTickerProviderStateMixin {
  final controller = Get.put(HomeController());
  final _db = FirebaseFirestore.instance.collection("snowball");

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(AddView()),
        backgroundColor: AppConstants.darBlue,
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: 25,
        ),
      ),
      body: Container(
        child: StreamBuilder<QuerySnapshot>(
          stream: _db.orderBy("fecha", descending: true).snapshots(),
          builder: (context, snapSnowBalls) {
            if (!snapSnowBalls.hasData) {
              return Padding(
                padding: const EdgeInsets.only(
                  top: 20,
                  bottom: 0,
                  right: 16,
                  left: 16,
                ),
                child: Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          SizedBox(
                            width: Get.width - 50,
                            height: 300,
                            child: Shimmer.fromColors(
                              baseColor: Colors.grey[300],
                              highlightColor: Colors.grey[100],
                              child: Image.asset(
                                "assets/placeholder.png",
                                fit: BoxFit.cover,
                                height: 250,
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              );
            }
            return ListView.builder(
                padding: const EdgeInsets.only(
                  top: 20,
                  bottom: 0,
                  right: 16,
                  left: 16,
                ),
                itemCount: snapSnowBalls.data.docs.length,
                itemBuilder: (context, index) {
                  Snowball snowball = Snowball.fromJsonMap(
                      snapSnowBalls.data.docs[index].data(),
                      snapSnowBalls.data.docs[index].id);
                  return Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            InkWell(
                              onTap: () =>
                                  Get.to(DetailSnowballView(snowball.id)),
                              child: snowball.adjuntos.length > 0
                                  ? snowball.adjuntos.first.video != null
                                      ? Center(
                                          child: CustomVideo(
                                              urlVideo: snowball
                                                  .adjuntos.first.video))
                                      : Center(
                                          child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          child: FadeInImage.assetNetwork(
                                            placeholder:
                                                'assets/snowball_logo.png',
                                            height: 250,
                                            image: snowball.adjuntos[0].image !=
                                                    null
                                                ? snowball.adjuntos[0].image
                                                : controller.placeholder,
                                          ),
                                        ))
                                  : Center(
                                      child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: FadeInImage.assetNetwork(
                                        placeholder: 'assets/snowball_logo.png',
                                        height: 250,
                                        image: snowball.adjuntos.isNotEmpty
                                            ? snowball.adjuntos[0].image
                                            : controller.placeholder,
                                      ),
                                    )),
                            ),
                            Positioned(
                              child: IconButton(
                                  icon: Icon(Icons.more_horiz),
                                  onPressed: () =>
                                      ModalsView.showSnowballOptions(
                                          controller, snowball.autor, context)),
                              right: 0,
                            ),
                          ],
                        ),
                        Container(
                          width: Get.width,
                          child: InkWell(
                            onTap: () =>
                                Get.to(DetailSnowballView(snowball.id)),
                            child: Padding(
                              padding:
                                  EdgeInsets.only(top: 10, left: 15, right: 10),
                              child: Text(snowball.nombre,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(snowball.ciudad ?? ""),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    timeago.format(snowball.fecha,
                                        locale: 'locale'.tr),
                                    style: TextStyle(fontSize: 11),
                                  ),
                                  Text(
                                    controller.getTagsList(snowball.etiquetas),
                                    style: TextStyle(
                                        fontSize: 11,
                                        backgroundColor: Colors.grey.shade100),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: false,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        ToolsSnowBalls(
                          id: snowball.id,
                          onPressedMsj: () =>
                              Get.to(() => DetailSnowballView(snowball.id)),
                        ),
                      ],
                    ),
                  );
                });
          },
        ),
      ),
    );
  }
}
