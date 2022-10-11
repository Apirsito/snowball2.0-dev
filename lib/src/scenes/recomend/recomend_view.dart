import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snowball/src/common/app_constants.dart';
import 'package:snowball/src/controller/recomend/recommended_controller.dart';
import 'package:snowball/src/models/recommend/group_recommend.dart';
import 'package:snowball/src/scenes/home/navigation.dart';
import 'package:snowball/src/scenes/recomend/recommend_list.dart';

class RecomendView extends StatefulWidget {
  @override
  _RecomendViewState createState() => _RecomendViewState();
}

class _RecomendViewState extends State<RecomendView> {
  void gotoRecommendList(GroupRecommend item) async {
    await Get.to(
      () => RecommendListView(
        item,
        isApproved: RecommendedController.to.seeAll.value,
      ),
    );
    RecommendedController.to.clearData();
    RecommendedController.to.getCurrentRecommends();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        irAtras();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                irAtras();
              }),
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
          title: Text("", style: TextStyle(color: Colors.white)),
        ),
        body: GetBuilder<RecommendedController>(
          initState: (_) => RecommendedController.to.getCurrentRecommends(),
          dispose: (_) => RecommendedController.to.clearData(),
          builder: (controller) => Obx(
            () => Stack(
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(
                          'recommendation'.tr,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text('select_recomend'.tr),
                        ),
                      ),
                    ),
                    // Este es el contenedor de los botones tabs,
                    // se podrá cambiar de botones a tabs
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.all(10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                                side: BorderSide(color: AppConstants.blue),
                              ),
                              primary: controller.seeAll.value
                                  ? Colors.white
                                  : AppConstants.blue,
                            ),
                            onPressed: () => controller.seeAll(false),
                            child: Text(
                              'pending'.tr,
                              style: TextStyle(
                                color: controller.seeAll.value
                                    ? AppConstants.blue
                                    : Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 5),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.all(10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                                side: BorderSide(color: AppConstants.blue),
                              ),
                              primary: controller.seeAll.value
                                  ? AppConstants.blue
                                  : Colors.white,
                            ),
                            onPressed: () => controller.seeAll(true),
                            child: Text(
                              'activate'.tr,
                              style: TextStyle(
                                color: controller.seeAll.value
                                    ? Colors.white
                                    : AppConstants.blue,
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        itemCount: controller.seeAll.value
                            ? controller.recommendsAcepted.length
                            : controller.recommends.length,
                        itemBuilder: (context, index) {
                          GroupRecommend item = controller.seeAll.value
                              ? controller.recommendsAcepted[index]
                              : controller.recommends[index];
                          return GestureDetector(
                            onTap: () => gotoRecommendList(item),
                            child: Card(
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    ListTile(
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: FadeInImage.assetNetwork(
                                          placeholder:
                                              "assets/snowball_logo.png",
                                          image: item
                                                  .snowball.adjuntos.isNotEmpty
                                              ? item.snowball.adjuntos.first
                                                          .video !=
                                                      null
                                                  ? AppConstants.logoSnowball
                                                  : item.snowball.adjuntos.first
                                                      .image
                                              : AppConstants.logoSnowball,
                                          height: 50,
                                          width: 50,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      title: Text(item.snowball.nombre),
                                      subtitle: Text(item.descripcion),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void irAtras() {
    Get.to(() => NavigationApp(
          indexIn: 4,
        ));
  }
}
