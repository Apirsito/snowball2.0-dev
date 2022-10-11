import 'package:flutter/material.dart';
import 'package:ots/ots.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:snowball/src/common/app_constants.dart';
import 'package:get/get.dart';
import 'package:snowball/src/controller/recomend/list_controller.dart';
import 'package:snowball/src/models/recommend/group_recommend.dart';

import 'widget/slidingPanelInfo.widget.dart';

// ignore: must_be_immutable
class RecommendListView extends StatelessWidget {
  RecommendListView(this.recomends, {this.isApproved = false});
  final GroupRecommend recomends;
  bool isApproved;
  PanelController panelController = new PanelController();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RecommendListController>(
      initState: (_) => RecommendListController.to.getListController(recomends),
      dispose: (_) => RecommendListController.to.clearData(),
      builder: (controller) => Obx(() {
        return Material(
          child: SlidingUpPanel(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(18.0),
              topRight: Radius.circular(18.0),
            ),
            color: Colors.grey[100],
            backdropTapClosesPanel: true,
            backdropEnabled: true,
            parallaxEnabled: true,
            controller: panelController,
            maxHeight: MediaQuery.of(context).size.height / 2,
            minHeight: 0,
            panelBuilder: (sc) => SlidingPanelInfo.info(
              sc,
              controller,
              panelController,
              isApproved,
            ),
            body: Scaffold(
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
                  "recommendation".tr,
                  style: TextStyle(color: Colors.white),
                ),
              ),
              body: SingleChildScrollView(
                controller: ScrollController(),
                child: Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * .85,
                      padding: EdgeInsets.only(top: 18, left: 10, right: 10, bottom: 20),
                      child: ListView.builder(
                        itemCount: controller.listRecommend.value.recommends.length,
                        itemBuilder: (context, index) {
                          final listRecomends = controller.listRecommend.value.recommends;
                          hideLoader();
                          listRecomends.sort((a, b) => b.dateCreation.compareTo(a.dateCreation));
                          final item = listRecomends[index];
                          return GestureDetector(
                              onTap: () {
                                RecommendListController.to.getItemSelected(item);
                                panelController.open();
                              },
                              child: Card(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    SizedBox(height: 10),
                                    ListTile(
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: FadeInImage.assetNetwork(
                                          placeholder:
                                              "assets/snowball_logo.png",
                                          image: (item.imagen != null && item.imagen.isNotEmpty)
                                            ? item.imagen
                                            : controller.listRecommend.value.snowball.adjuntos.isNotEmpty
                                              ? (controller.listRecommend.value.snowball.adjuntos.first.video != null)
                                                ? AppConstants.logoSnowball
                                                : controller.listRecommend.value.snowball.adjuntos.first.image
                                              : AppConstants.logoSnowball,
                                          height: 60,
                                          width: 60,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      title: Text(item.autorName),
                                      subtitle: Text(
                                        item.descripcion,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    (!isApproved)
                                      ? Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: <Widget>[
                                          TextButton(
                                            child: Text('decline'.tr),
                                            onPressed: () => controller.ignoreRecomend(item),
                                          ),
                                          const SizedBox(width: 8),
                                          TextButton(
                                            child: Text('acept'.tr),
                                            onPressed: () => controller.acepRecommend(item, single: true),
                                          ),
                                          const SizedBox(width: 8),
                                        ],
                                      )
                                      : Container(),
                                  ],
                                ),
                              ));
                        },
                      ),
                    ),
                  ],
                ),
              ),
              bottomNavigationBar: (!isApproved)
                ? Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:BorderRadius.all(Radius.circular(20)),
                  ),
                  padding: EdgeInsets.only(top: 8, bottom: 10, left: 20, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 1,
                        child: MaterialButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          onPressed: controller.recommendationAprovalConfirmationAlert,
                          padding: EdgeInsets.all(5),
                          color: AppConstants.blue,
                          child: Text(
                              '${'acept'.tr.toUpperCase()} ${'all'.tr.toUpperCase()}',
                              style: TextStyle(
                                color: Colors.white,
                              )),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        flex: 1,
                        child: MaterialButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          onPressed: controller.ignoreRecomends,
                          padding: EdgeInsets.all(5),
                          child: Text(
                              '${'ignore'.tr} ${'all'.tr.toUpperCase()}',
                              style: TextStyle(
                                color: Colors.grey,
                              )),
                        ),
                      ),
                    ],
                  )) : null,
            ),
          ),
        );
      }),
    );
  }
}
