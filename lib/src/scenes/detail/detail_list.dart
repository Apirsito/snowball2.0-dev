import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snowball/src/scenes/common/toolbar_view.dart';
import 'package:snowball/src/scenes/detail/detail_snowball_view.dart';
import 'package:snowball/src/common/app_constants.dart';
import 'package:snowball/src/controller/detail/detail_list_controller.dart';

class DetailListView extends StatelessWidget {
  const DetailListView({Key key, @required this.type, this.tags, this.idUser})
      : super(key: key);

  final String type;
  final String tags;
  final String idUser;

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
                ])),
          ),
          title: Text(type == "tags" ? "Snowball by tag" : "Snowballs")),
      body: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: GetBuilder<DetailListController>(
              initState: (_) => DetailListController.to
                  .getSnowballs(type, tags, idUser: idUser),
              dispose: (_) => DetailListController.to.clearData(),
              builder: (controller) => Obx(() => ListView.builder(
                    itemCount: controller.snowball.length,
                    itemBuilder: (context, index) {
                      var item = controller.snowball[index];
                      return Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          children: [
                            InkWell(
                              onTap: () => Get.to(DetailSnowballView(item.id)),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4.0),
                                child: FadeInImage.assetNetwork(
                                  placeholder: "assets/snowball_logo.png",
                                  image: item.image,
                                  height: 250,
                                ),
                              ),
                            ),
                            Stack(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 0, right: 8, bottom: 0),
                                  child: Container(
                                    child: InkWell(
                                      onTap: () {
                                        Get.to(DetailSnowballView(item.id));
                                      },
                                      child: ListTile(
                                          dense: true,
                                          title: Text(item.name,
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold)),
                                          subtitle: Text(item.ciudad ?? "")),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            ToolsSnowBalls(id: item.id)
                          ],
                        ),
                      );
                    },
                  )))),
    );
  }
}
